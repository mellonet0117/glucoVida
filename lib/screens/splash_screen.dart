import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';
import '../services/notificacion_service.dart';
import 'auth/auth_gate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? error;

  @override
  void initState() {
    super.initState();

    // Esperar a que aparezca el primer fotograma
    WidgetsBinding.instance.addPostFrameCallback((_) {
      iniciarAplicacion();
    });
  }

  Future<void> configurarServicios() async {
    // Inicializar Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Inicializar notificaciones
    try {
      await NotificacionService.inicializar();
    } catch (e) {
      debugPrint('Error en notificaciones: $e');
    }
  }

  Future<void> iniciarAplicacion() async {
    try {
      // Reproducir GIF e inicializar servicios
      await Future.wait<void>([
        configurarServicios(),
        Future<void>.delayed(const Duration(milliseconds: 5000)),
      ]);

      if (!mounted) return;

      // Continuar al sistema de autenticacion
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthGate()),
      );
    } catch (e) {
      debugPrint('Error al iniciar: $e');

      if (!mounted) return;

      setState(() {
        error = 'No se pudo iniciar GlucoVida';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/animations/glucovida_intro.gif',
              fit: BoxFit.contain,
              gaplessPlayback: true,
            ),
          ),

          if (error != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  error!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
