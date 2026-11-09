import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'push_service.dart';

import '../models/recomendacion_doctor.dart';

class RecomendacionDoctorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get doctorId {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw Exception('No existe una sesión activa.');
    }

    return usuario.uid;
  }

  CollectionReference<Map<String, dynamic>> coleccion(String pacienteId) {
    return _firestore
        .collection('usuarios')
        .doc(pacienteId)
        .collection('recomendaciones');
  }

  Future<void> crear({
    required String pacienteId,
    required String tipo,
    required String titulo,
    required String descripcion,
    Map<String, dynamic>? detalles,
  }) async {
    final doctor = FirebaseAuth.instance.currentUser;

    if (doctor == null) {
      throw Exception('No hay una sesión activa.');
    }

    final recomendacion = await coleccion(pacienteId).add({
      'doctorId': doctor.uid,

      'tipo': tipo,

      'titulo': titulo.trim(),

      'descripcion': descripcion.trim(),

      'detalles': detalles ?? {},

      'fecha': FieldValue.serverTimestamp(),
    });

    await PushService.enviar(
      tipo: 'recomendacion_nueva',

      pacienteId: pacienteId,

      recomendacionId: recomendacion.id,
    );
  }

  Stream<List<RecomendacionDoctor>> obtener(String pacienteId) {
    return coleccion(pacienteId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(RecomendacionDoctor.fromFirestore).toList(),
        );
  }

  Future<void> actualizar({
    required String pacienteId,
    required String recomendacionId,
    required String tipo,
    required String titulo,
    required String descripcion,
  }) async {
    await coleccion(pacienteId).doc(recomendacionId).update({
      'tipo': tipo,
      'titulo': titulo.trim(),
      'descripcion': descripcion.trim(),
      'fechaActualizacion': FieldValue.serverTimestamp(),
    });
  }

  Future<void> eliminar({
    required String pacienteId,
    required String recomendacionId,
  }) async {
    await coleccion(pacienteId).doc(recomendacionId).delete();
  }
}
