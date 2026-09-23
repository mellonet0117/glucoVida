import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

import 'login_screen.dart';

import '../paciente/paciente_dashboard.dart';
import '../doctor/doctor_dashboard.dart';
import '../admin/admin_dashboard.dart';

class AuthGate extends StatelessWidget {
  AuthGate({super.key});

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.cambiosSesion,

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // NO HAY SESIÓN
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // HAY SESIÓN: BUSCAMOS EL ROL
        return FutureBuilder<String>(
          future: _authService.obtenerRolActual(),

          builder: (context, rolSnapshot) {
            if (rolSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (rolSnapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 70,
                          color: Colors.red,
                        ),

                        const SizedBox(height: 20),

                        Text(
                          '${rolSnapshot.error}',
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 20),

                        FilledButton(
                          onPressed: () {
                            _authService.cerrarSesion();
                          },
                          child: const Text('Cerrar sesión'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final rol = rolSnapshot.data;

            switch (rol) {
              case 'paciente':
                return const PacienteDashboard();

              case 'doctor':
                return const DoctorDashboard();

              case 'admin':
                return const AdminDashboard();

              default:
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 70),

                        const SizedBox(height: 20),

                        Text('Rol desconocido: $rol'),

                        const SizedBox(height: 20),

                        FilledButton(
                          onPressed: () {
                            _authService.cerrarSesion();
                          },
                          child: const Text('Cerrar sesión'),
                        ),
                      ],
                    ),
                  ),
                );
            }
          },
        );
      },
    );
  }
}
