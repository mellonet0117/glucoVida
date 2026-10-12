import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/recomendacion_doctor.dart';
import '../../services/recomendacion_doctor_service.dart';

class RecomendacionesScreen extends StatelessWidget {
  RecomendacionesScreen({super.key});

  final RecomendacionDoctorService service = RecomendacionDoctorService();

  @override
  Widget build(BuildContext context) {
    final paciente = FirebaseAuth.instance.currentUser;

    if (paciente == null) {
      return const Scaffold(
        body: Center(child: Text('No existe una sesión activa.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(title: const Text('Mis recomendaciones')),

      body: StreamBuilder<List<RecomendacionDoctor>>(
        stream: service.obtener(paciente.uid),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'No se pudieron cargar las recomendaciones.\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final recomendaciones = snapshot.data ?? [];

          if (recomendaciones.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Icon(
                    Icons.medical_information_outlined,
                    size: 75,
                    color: AppColors.textMuted,
                  ),

                  SizedBox(height: 14),

                  Text(
                    'Sin recomendaciones',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Las recomendaciones de tu médico aparecerán aquí.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(18),

            itemCount: recomendaciones.length,

            itemBuilder: (context, index) {
              return _tarjeta(recomendaciones[index]);
            },
          );
        },
      ),
    );
  }

  Widget _tarjeta(RecomendacionDoctor recomendacion) {
    final fecha = recomendacion.fecha;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),

      child: Padding(
        padding: const EdgeInsets.all(17),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                Container(
                  width: 45,
                  height: 45,

                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDFA),

                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: Icon(
                    _icono(recomendacion.tipo),

                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        recomendacion.titulo,

                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      Text(
                        recomendacion.tipo,

                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Text(
              recomendacion.descripcion,

              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 13),

            const Divider(),

            const SizedBox(height: 6),

            Row(
              children: [
                const Icon(
                  Icons.medical_services_outlined,
                  size: 16,
                  color: AppColors.textMuted,
                ),

                const SizedBox(width: 5),

                const Expanded(
                  child: Text(
                    'Recomendación médica',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ),

                Text(
                  '${fecha.day.toString().padLeft(2, '0')}/'
                  '${fecha.month.toString().padLeft(2, '0')}/'
                  '${fecha.year}',

                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _icono(String tipo) {
    switch (tipo) {
      case 'Alimentación':
        return Icons.restaurant_outlined;

      case 'Actividad física':
        return Icons.directions_run_outlined;

      case 'Seguimiento':
        return Icons.monitor_heart_outlined;

      default:
        return Icons.medical_information_outlined;
    }
  }
}
