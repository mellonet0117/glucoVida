import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/recordatorio.dart';
import 'notificacion_service.dart';

class RecordatorioService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No existe una sesión activa.');
    }

    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _coleccion {
    return _firestore
        .collection('usuarios')
        .doc(_uid)
        .collection('recordatorios');
  }

  Stream<List<Recordatorio>> obtenerRecordatorios() {
    return _coleccion
        .orderBy('hora')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(Recordatorio.fromFirestore).toList(),
        );
  }

  Future<void> agregar({
    required String tipo,
    required String titulo,
    required String descripcion,
    required int hora,
    required int minuto,
  }) async {
    final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(
      2147483647,
    );

    final horaTexto =
        '${hora.toString().padLeft(2, '0')}:'
        '${minuto.toString().padLeft(2, '0')}';

    await _coleccion.add({
      'notificationId': notificationId,
      'tipo': tipo,
      'titulo': titulo.trim(),
      'descripcion': descripcion.trim(),
      'hora': horaTexto,
      'activo': true,
      'fechaRegistro': FieldValue.serverTimestamp(),
    });

    await NotificacionService.programarDiario(
      id: notificationId,
      titulo: titulo,
      cuerpo: descripcion,
      hora: hora,
      minuto: minuto,
    );
  }

  Future<void> actualizar({
    required Recordatorio recordatorio,
    required String tipo,
    required String titulo,
    required String descripcion,
    required int hora,
    required int minuto,
  }) async {
    final horaTexto =
        '${hora.toString().padLeft(2, '0')}:'
        '${minuto.toString().padLeft(2, '0')}';

    await NotificacionService.cancelar(recordatorio.notificationId);

    await _coleccion.doc(recordatorio.id).update({
      'tipo': tipo,
      'titulo': titulo.trim(),
      'descripcion': descripcion.trim(),
      'hora': horaTexto,
    });

    if (recordatorio.activo) {
      await NotificacionService.programarDiario(
        id: recordatorio.notificationId,
        titulo: titulo,
        cuerpo: descripcion,
        hora: hora,
        minuto: minuto,
      );
    }
  }

  Future<void> cambiarEstado(Recordatorio recordatorio, bool activo) async {
    await _coleccion.doc(recordatorio.id).update({'activo': activo});

    if (!activo) {
      await NotificacionService.cancelar(recordatorio.notificationId);

      return;
    }

    final partes = recordatorio.hora.split(':');

    final hora = int.parse(partes[0]);

    final minuto = int.parse(partes[1]);

    await NotificacionService.programarDiario(
      id: recordatorio.notificationId,
      titulo: recordatorio.titulo,
      cuerpo: recordatorio.descripcion,
      hora: hora,
      minuto: minuto,
    );
  }

  Future<void> reprogramarRecordatoriosActivos() async {
    final snapshot = await _coleccion.get();

    for (final doc in snapshot.docs) {
      final recordatorio = Recordatorio.fromFirestore(doc);

      if (!recordatorio.activo) {
        continue;
      }

      final partes = recordatorio.hora.split(':');

      if (partes.length != 2) {
        continue;
      }

      final hora = int.tryParse(partes[0]);

      final minuto = int.tryParse(partes[1]);

      if (hora == null || minuto == null) {
        continue;
      }

      await NotificacionService.programarDiario(
        id: recordatorio.notificationId,
        titulo: recordatorio.titulo,
        cuerpo: recordatorio.descripcion,
        hora: hora,
        minuto: minuto,
      );
    }
  }

  Future<void> eliminar(Recordatorio recordatorio) async {
    await NotificacionService.cancelar(recordatorio.notificationId);

    await _coleccion.doc(recordatorio.id).delete();
  }
}
