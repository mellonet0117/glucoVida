import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class ConfiguracionDoctorScreen extends StatelessWidget {
  const ConfiguracionDoctorScreen({super.key});

  Future<void> cambiarPassword(BuildContext context) async {
    final auth = FirebaseAuth.instance;

    final correo = auth.currentUser?.email;

    if (correo == null || correo.isEmpty) {
      _mensaje(context, 'No se encontró el correo de la cuenta.');

      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,

      builder: (context) => AlertDialog(
        title: const Text('Cambiar contraseña'),

        content: Text(
          'Se enviará un enlace para restablecer la contraseña a:\n\n$correo',
        ),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },

            child: const Text('Cancelar'),
          ),

          FilledButton(
            onPressed: () {
              Navigator.pop(context, true);
            },

            child: const Text('Enviar'),
          ),
        ],
      ),
    );

    if (confirmar != true) {
      return;
    }

    try {
      await auth.sendPasswordResetEmail(email: correo);

      if (!context.mounted) return;

      _mensaje(context, 'Se envió el enlace al correo.');
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;

      _mensaje(context, e.message ?? 'No se pudo enviar el correo.');
    }
  }

  void acercaDe(BuildContext context) {
    showAboutDialog(
      context: context,

      applicationName: 'GlucoVida',

      applicationVersion: '1.0.0',

      applicationIcon: Image.asset(
        'assets/images/glucovida_icon.png',
        width: 60,
        height: 60,
      ),

      children: const [
        Text(
          'Sistema integral para seguimiento y apoyo en el control de glucosa.',
        ),

        SizedBox(height: 10),

        Text('Controla hoy, vive mejor mañana.'),
      ],
    );
  }

  static void _mensaje(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(title: const Text('Configuración')),

      body: ListView(
        padding: const EdgeInsets.all(18),

        children: [
          const Text(
            'Cuenta y seguridad',

            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: const Icon(Icons.lock_outline, color: AppColors.primary),

              title: const Text('Cambiar contraseña'),

              subtitle: const Text('Recibe un enlace en tu correo'),

              trailing: const Icon(Icons.chevron_right),

              onTap: () {
                cambiarPassword(context);
              },
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Aplicación',

            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: Image.asset(
                'assets/images/glucovida_icon.png',
                width: 36,
                height: 36,
              ),

              title: const Text('Acerca de GlucoVida'),

              subtitle: const Text('Versión 1.0.0'),

              trailing: const Icon(Icons.chevron_right),

              onTap: () {
                acercaDe(context);
              },
            ),
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.circular(16),
            ),

            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Icon(Icons.info_outline, color: AppColors.primary),

                SizedBox(width: 12),

                Expanded(
                  child: Text(
                    'Las funciones del Doctor permiten consultar únicamente a los pacientes que tiene asignados.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
