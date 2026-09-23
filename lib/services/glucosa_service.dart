import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/glucosa_registro.dart';

class GlucosaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw Exception('No existe una sesión activa.');
    }

    return usuario.uid;
  }

  CollectionReference<Map<String, dynamic>> get _coleccion {
    return _firestore.collection('usuarios').doc(_uid).collection('glucosa');
  }

  // ======================================
  // GUARDAR
  // ======================================

  Future<void> registrar({
    required int valor,
    required String momento,
    required DateTime fechaHora,
    String notas = '',
  }) async {
    await _coleccion.add({
      'valor': valor,
      'momento': momento,
      'fechaHora': Timestamp.fromDate(fechaHora),
      'notas': notas.trim(),
      'fechaRegistro': FieldValue.serverTimestamp(),
    });
  }

  // ======================================
  // LISTA EN TIEMPO REAL
  // ======================================

  Stream<List<GlucosaRegistro>> obtenerRegistros() {
    return _coleccion
        .orderBy('fechaHora', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(GlucosaRegistro.fromFirestore).toList(),
        );
  }

  // ======================================
  // ELIMINAR
  // ======================================

  Future<void> eliminar(String id) async {
    await _coleccion.doc(id).delete();
  }
}
