import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'push_service.dart';

import '../models/cita.dart';

class CitaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get uid {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw Exception('No existe una sesión activa.');
    }

    return usuario.uid;
  }

  CollectionReference<Map<String, dynamic>> get _citas {
    return _firestore.collection('citas');
  }

  Future<String?> obtenerDoctorPaciente() async {
    final doc = await _firestore.collection('usuarios').doc(uid).get();

    return doc.data()?['doctorId'];
  }

  Future<void> crearCita({
    required DateTime fechaHora,
    required String motivo,
  }) async {
    final doctorId = await obtenerDoctorPaciente();

    if (doctorId == null || doctorId.isEmpty) {
      throw Exception('No tienes un doctor asignado.');
    }

    await _citas.add({
      'pacienteId': uid,
      'doctorId': doctorId,
      'fechaHora': Timestamp.fromDate(fechaHora),
      'motivo': motivo.trim(),
      'estado': 'pendiente',
      'notasDoctor': '',
      'fechaCreacion': FieldValue.serverTimestamp(),
    });
  }

  Future<void> solicitarCitaPaciente({
    required String doctorId,
    required DateTime fechaHora,
    required String motivo,
  }) async {
    final paciente = FirebaseAuth.instance.currentUser;

    if (paciente == null) {
      throw Exception('No hay una sesión activa.');
    }

    if (doctorId.trim().isEmpty) {
      throw Exception('Selecciona un doctor.');
    }

    final cita = await FirebaseFirestore.instance.collection('citas').add({
      'pacienteId': paciente.uid,

      'doctorId': doctorId,

      'fechaHora': Timestamp.fromDate(fechaHora),

      'motivo': motivo.trim(),

      'estado': 'pendiente',

      'notasDoctor': '',

      'creadaPor': 'paciente',

      'fechaCreacion': FieldValue.serverTimestamp(),
    });

    // La cita YA quedó guardada.
    // Si la notificación falla,
    // no afecta la cita.
    await PushService.enviar(tipo: 'solicitud_cita', citaId: cita.id);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> doctores() {
    return FirebaseFirestore.instance
        .collection('usuarios')
        .where('rol', isEqualTo: 'doctor')
        .snapshots();
  }

  Stream<List<Cita>> citasPaciente() {
    return _citas.where('pacienteId', isEqualTo: uid).snapshots().map((
      snapshot,
    ) {
      final citas = snapshot.docs.map(Cita.fromFirestore).toList();

      citas.sort((a, b) => a.fechaHora.compareTo(b.fechaHora));

      return citas;
    });
  }

  Stream<List<Cita>> citasDoctor() {
    final doctor = FirebaseAuth.instance.currentUser;

    if (doctor == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('citas')
        .where('doctorId', isEqualTo: doctor.uid)
        .snapshots()
        .map((snapshot) {
          final citas = snapshot.docs
              .map((doc) => Cita.fromFirestore(doc))
              .toList();

          citas.sort((a, b) => a.fechaHora.compareTo(b.fechaHora));

          return citas;
        });
  }

  Future<void> cambiarEstado({
    required String citaId,
    required String estado,
  }) async {
    await FirebaseFirestore.instance.collection('citas').doc(citaId).update({
      'estado': estado,

      'fechaActualizacion': FieldValue.serverTimestamp(),
    });

    if (estado == 'confirmada') {
      await PushService.enviar(tipo: 'cita_confirmada', citaId: citaId);
    }

    if (estado == 'cancelada') {
      await PushService.enviar(tipo: 'cita_cancelada', citaId: citaId);
    }
  }

  Future<void> reprogramar({
    required String citaId,
    required DateTime nuevaFecha,
  }) async {
    await FirebaseFirestore.instance.collection('citas').doc(citaId).update({
      'fechaHora': Timestamp.fromDate(nuevaFecha),

      'fechaActualizacion': FieldValue.serverTimestamp(),
    });

    await PushService.enviar(tipo: 'cita_reprogramada', citaId: citaId);
  }

  Future<void> crearCitaDoctor({
    required String pacienteId,
    required DateTime fechaHora,
    required String motivo,
    String notas = '',
  }) async {
    final doctor = FirebaseAuth.instance.currentUser;

    if (doctor == null) {
      throw Exception('No hay una sesión activa.');
    }

    debugPrint('DOCTOR UID: ${doctor.uid}');

    debugPrint('PACIENTE UID: $pacienteId');

    final pacienteDoc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(pacienteId)
        .get();

    if (!pacienteDoc.exists) {
      throw Exception('El paciente no existe.');
    }

    debugPrint(
      'ROL PACIENTE: '
      '${pacienteDoc.data()?['rol']}',
    );

    final doctorDoc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(doctor.uid)
        .get();

    debugPrint(
      'ROL DOCTOR: '
      '${doctorDoc.data()?['rol']}',
    );

    if (doctorDoc.data()?['rol'] != 'doctor') {
      throw Exception('La cuenta actual no tiene rol doctor.');
    }

    if (pacienteDoc.data()?['rol'] != 'paciente') {
      throw Exception('El usuario seleccionado no tiene rol paciente.');
    }

    final datos = {
      'pacienteId': pacienteId,
      'doctorId': doctor.uid,
      'fechaHora': Timestamp.fromDate(fechaHora),
      'motivo': motivo.trim(),
      'estado': 'confirmada',
      'notasDoctor': notas.trim(),
      'creadaPor': 'doctor',
      'fechaCreacion': FieldValue.serverTimestamp(),
    };

    debugPrint('CREANDO CITA: $datos');

    final doc = await FirebaseFirestore.instance.collection('citas').add(datos);

    debugPrint('CITA CREADA: ${doc.id}');
  }

  Future<void> eliminarCita(String citaId) async {
    // Primero avisa
    await PushService.enviar(tipo: 'cita_eliminada', citaId: citaId);

    // Después elimina
    await FirebaseFirestore.instance.collection('citas').doc(citaId).delete();
  }
}
