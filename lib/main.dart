import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'services/notificacion_service.dart';
import 'services/firebase_messaging_service.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  debugPrint(
    'Notificación en segundo plano: '
    '${message.messageId}',
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await NotificacionService.inicializar();

  await FirebaseMessagingService.inicializar();

  runApp(const GlucoVidaApp());
}

class GlucoVidaApp extends StatelessWidget {
  const GlucoVidaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GlucoVida',

      theme: AppTheme.lightTheme,

      home: const SplashScreen(),
    );
  }
}
