import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/medicamento.dart';

class MedicamentoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No hay sesión activa');
    }

    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _coleccion {
    return _firestore
        .collection('usuarios')
        .doc(_uid)
        .collection('medicamentos');
  }

  Stream<List<Medicamento>> obtenerMedicamentos() {
    return _coleccion
        .orderBy('hora')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(Medicamento.fromFirestore).toList(),
        );
  }

  Future<void> agregar({
    required String nombre,
    required String dosis,
    required String hora,
    required String frecuencia,
  }) async {
    await _coleccion.add({
      'nombre': nombre.trim(),
      'dosis': dosis.trim(),
      'hora': hora,
      'frecuencia': frecuencia,
      'activo': true,
      'ultimaToma': null,
      'fechaRegistro': FieldValue.serverTimestamp(),
    });
  }

  Future<void> actualizar({
    required String id,
    required String nombre,
    required String dosis,
    required String hora,
    required String frecuencia,
  }) async {
    await _coleccion.doc(id).update({
      'nombre': nombre.trim(),
      'dosis': dosis.trim(),
      'hora': hora,
      'frecuencia': frecuencia,
    });
  }

  Future<void> marcarTomado(String id) async {
    await _coleccion.doc(id).update({
      'ultimaToma': FieldValue.serverTimestamp(),
    });
  }

  Future<void> eliminar(String id) async {
    await _coleccion.doc(id).delete();
  }
}
