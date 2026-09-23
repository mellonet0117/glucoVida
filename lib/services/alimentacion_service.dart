import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/registro_alimentacion.dart';

class AlimentacionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No existe una sesión activa');
    }

    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _coleccion {
    return _firestore
        .collection('usuarios')
        .doc(_uid)
        .collection('alimentacion');
  }

  Stream<List<RegistroAlimentacion>> obtenerRegistros() {
    return _coleccion
        .orderBy('fechaHora', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(RegistroAlimentacion.fromFirestore).toList(),
        );
  }

  Future<void> agregar({
    required String tipo,
    required String alimentos,
    required String porcion,
    required String notas,
    required DateTime fechaHora,
  }) async {
    await _coleccion.add({
      'tipo': tipo,
      'alimentos': alimentos.trim(),
      'porcion': porcion.trim(),
      'notas': notas.trim(),
      'fechaHora': Timestamp.fromDate(fechaHora),
      'fechaRegistro': FieldValue.serverTimestamp(),
    });
  }

  Future<void> actualizar({
    required String id,
    required String tipo,
    required String alimentos,
    required String porcion,
    required String notas,
    required DateTime fechaHora,
  }) async {
    await _coleccion.doc(id).update({
      'tipo': tipo,
      'alimentos': alimentos.trim(),
      'porcion': porcion.trim(),
      'notas': notas.trim(),
      'fechaHora': Timestamp.fromDate(fechaHora),
    });
  }

  Future<void> eliminar(String id) async {
    await _coleccion.doc(id).delete();
  }
}
