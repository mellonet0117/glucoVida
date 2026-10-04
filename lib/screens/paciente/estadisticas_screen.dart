import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class EstadisticasScreen extends StatelessWidget {
  const EstadisticasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(title: const Text('Estadísticas')),

      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_rounded, size: 80, color: AppColors.primary),

            SizedBox(height: 15),

            Text(
              'Estadísticas de glucosa',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 8),

            Text(
              'Aquí mostraremos tus gráficas y promedios.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
