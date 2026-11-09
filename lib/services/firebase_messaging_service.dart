import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'notificacion_service.dart';

class FirebaseMessagingService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static bool _listenersConfigurados = false;

  static Future<void> inicializar() async {
    await _pedirPermisos();

    await guardarToken();

    if (_listenersConfigurados) {
      return;
    }

    _listenersConfigurados = true;

    // ===================================
    // TOKEN CAMBIA
    // ===================================

    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      await _guardarTokenEnFirestore(token);
    });

    // ===================================
    // APP ABIERTA
    // ===================================

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint('FCM RECIBIDO EN FOREGROUND');

      debugPrint('DATA: ${message.data}');

      debugPrint('NOTIFICATION: ${message.notification}');

      final notificacion = message.notification;

      if (notificacion == null) {
        return;
      }

      await NotificacionService.mostrarInstantanea(
        titulo: notificacion.title ?? 'GlucoVida',
        cuerpo: notificacion.body ?? '',
        payload: message.data['tipo'],
      );
    });

    // ===================================
    // USUARIO TOCA NOTIFICACIÓN
    // ===================================

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint(
        'Notificación abierta: '
        '${message.data}',
      );
    });
  }

  static Future<void> _pedirPermisos() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint(
      'Permiso FCM: '
      '${settings.authorizationStatus}',
    );
  }

  static Future<void> guardarToken() async {
    final token = await _messaging.getToken();

    if (token == null) {
      return;
    }

    await _guardarTokenEnFirestore(token);
  }

  static Future<void> _guardarTokenEnFirestore(String token) async {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      return;
    }

    await _firestore.collection('usuarios').doc(usuario.uid).set({
      'fcmToken': token,
      'fechaToken': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    debugPrint('FCM TOKEN GUARDADO');
  }
}
