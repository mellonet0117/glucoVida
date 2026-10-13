import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/cita.dart';
import '../../services/cita_service.dart';

class CitasDoctorScreen extends StatelessWidget {
  CitasDoctorScreen({super.key});

  final CitaService service = CitaService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(title: const Text('Citas médicas')),

      body: StreamBuilder<List<Cita>>(
        stream: service.citasDoctor(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final citas = snapshot.data ?? [];

          if (citas.isEmpty) {
            return const Center(child: Text('No tienes citas programadas.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(18),

            itemCount: citas.length,

            itemBuilder: (context, index) {
              return _CitaDoctorCard(cita: citas[index], service: service);
            },
          );
        },
      ),
    );
  }
}

class _CitaDoctorCard extends StatelessWidget {
  final Cita cita;
  final CitaService service;

  const _CitaDoctorCard({required this.cita, required this.service});

  Future<String> nombrePaciente() async {
    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(cita.pacienteId)
        .get();

    final datos = doc.data();

    if (datos == null) {
      return 'Paciente';
    }

    return '${datos['nombre'] ?? ''} '
            '${datos['apellidos'] ?? ''}'
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final fecha = cita.fechaHora;

    return Card(
      margin: const EdgeInsets.only(bottom: 13),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            FutureBuilder<String>(
              future: nombrePaciente(),

              builder: (context, snapshot) {
                return Text(
                  snapshot.data ?? 'Paciente',

                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),

            const SizedBox(height: 8),

            Text(cita.motivo),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  size: 17,
                  color: AppColors.primary,
                ),

                const SizedBox(width: 5),

                Text(
                  '${fecha.day.toString().padLeft(2, '0')}/'
                  '${fecha.month.toString().padLeft(2, '0')}/'
                  '${fecha.year}  '
                  '${fecha.hour.toString().padLeft(2, '0')}:'
                  '${fecha.minute.toString().padLeft(2, '0')}',
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              'Estado: ${cita.estado}',

              style: const TextStyle(fontWeight: FontWeight.w600),
            ),

            if (cita.estado == 'pendiente') ...[
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        await service.cambiarEstado(
                          citaId: cita.id,

                          estado: 'cancelada',
                        );
                      },

                      child: const Text('Cancelar'),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        await service.cambiarEstado(
                          citaId: cita.id,

                          estado: 'confirmada',
                        );
                      },

                      child: const Text('Confirmar'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
