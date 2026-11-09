import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PushService {
  static const String _url =
      'https://glucovida-notificaciones.vercel.app/api/notificar';

  static Future<bool> enviar({
    required String tipo,
    String? citaId,
    String? pacienteId,
    String? recomendacionId,
  }) async {
    try {
      final usuario = FirebaseAuth.instance.currentUser;

      if (usuario == null) {
        debugPrint('PUSH: No hay usuario autenticado.');

        return false;
      }

      final idToken = await usuario.getIdToken();

      final datos = <String, dynamic>{'tipo': tipo};

      if (citaId != null) {
        datos['citaId'] = citaId;
      }

      if (pacienteId != null) {
        datos['pacienteId'] = pacienteId;
      }

      if (recomendacionId != null) {
        datos['recomendacionId'] = recomendacionId;
      }

      final respuesta = await http.post(
        Uri.parse(_url),

        headers: {
          'Content-Type': 'application/json',

          'Authorization': 'Bearer $idToken',
        },

        body: jsonEncode(datos),
      );

      debugPrint(
        'PUSH STATUS: '
        '${respuesta.statusCode}',
      );

      debugPrint(
        'PUSH RESPONSE: '
        '${respuesta.body}',
      );

      if (respuesta.statusCode >= 200 && respuesta.statusCode < 300) {
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('ERROR PUSH: $e');

      return false;
    }
  }
}
