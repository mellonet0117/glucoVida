import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class RecordatoriosScreen extends StatelessWidget {
  const RecordatoriosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(title: const Text('Recordatorios')),

      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_outlined,
              size: 75,
              color: AppColors.primary,
            ),

            SizedBox(height: 15),

            Text(
              'Recordatorios',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 8),

            Text(
              'Aquí configuraremos tus recordatorios.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
