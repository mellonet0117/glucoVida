import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  bool notificaciones = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(title: const Text('Configuración')),

      body: ListView(
        padding: const EdgeInsets.all(18),

        children: [
          const Text(
            'Preferencias',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          Card(
            child: SwitchListTile(
              value: notificaciones,

              activeThumbColor: AppColors.primary,

              onChanged: (value) {
                setState(() {
                  notificaciones = value;
                });
              },

              secondary: const Icon(
                Icons.notifications_outlined,
                color: AppColors.primary,
              ),

              title: const Text('Notificaciones'),

              subtitle: const Text('Permitir recordatorios y avisos'),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.lock_outline, color: AppColors.primary),

              title: const Text('Cambiar contraseña'),

              trailing: const Icon(Icons.chevron_right),

              onTap: () {},
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline, color: AppColors.primary),

              title: const Text('Acerca de GlucoVida'),

              subtitle: const Text('Versión 1.0'),
            ),
          ),
        ],
      ),
    );
  }
}
