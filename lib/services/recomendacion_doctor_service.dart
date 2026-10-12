import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  }) async {
    await coleccion(pacienteId).add({
      'doctorId': doctorId,
      'tipo': tipo,
      'titulo': titulo.trim(),
      'descripcion': descripcion.trim(),
      'fecha': FieldValue.serverTimestamp(),
    });
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

  Future<void> eliminar({
    required String pacienteId,
    required String recomendacionId,
  }) async {
    await coleccion(pacienteId).doc(recomendacionId).delete();
  }
}
