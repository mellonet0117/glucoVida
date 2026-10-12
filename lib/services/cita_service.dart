import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    return _citas.where('doctorId', isEqualTo: uid).snapshots().map((snapshot) {
      final citas = snapshot.docs.map(Cita.fromFirestore).toList();

      citas.sort((a, b) => a.fechaHora.compareTo(b.fechaHora));

      return citas;
    });
  }

  Future<void> cambiarEstado({
    required String citaId,
    required String estado,
    String notasDoctor = '',
  }) async {
    await _citas.doc(citaId).update({
      'estado': estado,
      'notasDoctor': notasDoctor.trim(),
      'fechaActualizacion': FieldValue.serverTimestamp(),
    });
  }

  Future<void> reprogramar({
    required String citaId,
    required DateTime nuevaFecha,
  }) async {
    await _citas.doc(citaId).update({
      'fechaHora': Timestamp.fromDate(nuevaFecha),
      'fechaActualizacion': FieldValue.serverTimestamp(),
    });
  }
}
