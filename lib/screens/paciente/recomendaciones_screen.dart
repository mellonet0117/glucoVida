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
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // CABECERA
            // =========================

            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _icono(recomendacion.tipo),
                    color: AppColors.primary,
                    size: 26,
                  ),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recomendacion.titulo,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: .08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          recomendacion.tipo,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // =========================
            // DATOS ESPECÍFICOS
            // =========================
            if (recomendacion.tipo == 'Medicamento')
              _detallesMedicamento(recomendacion),

            if (recomendacion.tipo == 'Actividad física')
              _detallesEjercicio(recomendacion),

            // =========================
            // INDICACIONES
            // =========================
            if (recomendacion.descripcion.trim().isNotEmpty) ...[
              const SizedBox(height: 16),

              const Text(
                'Indicaciones',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                recomendacion.descripcion,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
            ],

            const SizedBox(height: 15),

            const Divider(),

            const SizedBox(height: 6),

            // =========================
            // PIE
            // =========================
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
                    'Recomendación del doctor',
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

  Widget _detallesMedicamento(RecomendacionDoctor recomendacion) {
    final detalles = recomendacion.detalles;

    final dosis = detalles['dosis']?.toString().trim() ?? '';

    final frecuencia = detalles['frecuencia']?.toString().trim() ?? '';

    if (dosis.isEmpty && frecuencia.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          if (dosis.isNotEmpty)
            _detalleFila(
              icono: Icons.science_outlined,
              titulo: 'Dosis',
              valor: dosis,
            ),

          if (dosis.isNotEmpty && frecuencia.isNotEmpty)
            const Divider(height: 22),

          if (frecuencia.isNotEmpty)
            _detalleFila(
              icono: Icons.schedule,
              titulo: 'Frecuencia',
              valor: frecuencia,
            ),
        ],
      ),
    );
  }

  Widget _detallesEjercicio(RecomendacionDoctor recomendacion) {
    final detalles = recomendacion.detalles;

    final duracion = detalles['duracion']?.toString().trim() ?? '';

    final frecuencia = detalles['frecuencia']?.toString().trim() ?? '';

    if (duracion.isEmpty && frecuencia.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          if (duracion.isNotEmpty)
            _detalleFila(
              icono: Icons.timer_outlined,
              titulo: 'Duración',
              valor: duracion,
            ),

          if (duracion.isNotEmpty && frecuencia.isNotEmpty)
            const Divider(height: 22),

          if (frecuencia.isNotEmpty)
            _detalleFila(
              icono: Icons.calendar_month_outlined,
              titulo: 'Frecuencia',
              valor: frecuencia,
            ),
        ],
      ),
    );
  }

  Widget _detalleFila({
    required IconData icono,
    required String titulo,
    required String valor,
  }) {
    return Row(
      children: [
        Container(
          width: 37,
          height: 37,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icono, size: 19, color: AppColors.primary),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                valor,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _icono(String tipo) {
    switch (tipo) {
      case 'Medicamento':
        return Icons.medication_outlined;

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
