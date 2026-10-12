import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/glucosa_registro.dart';
import 'nueva_recomendacion_screen.dart';

class PacienteDetalleDoctor extends StatelessWidget {
  final String pacienteId;

  const PacienteDetalleDoctor({super.key, required this.pacienteId});

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(title: const Text('Paciente')),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,

        foregroundColor: Colors.white,

        icon: const Icon(Icons.add_comment_outlined),

        label: const Text('Recomendar'),

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NuevaRecomendacionScreen(pacienteId: pacienteId),
            ),
          );
        },
      ),

      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: firestore.collection('usuarios').doc(pacienteId).get(),

        builder: (context, pacienteSnapshot) {
          if (!pacienteSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!pacienteSnapshot.data!.exists) {
            return const Center(child: Text('Paciente no encontrado'));
          }

          final paciente = pacienteSnapshot.data!.data()!;

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: firestore
                .collection('usuarios')
                .doc(pacienteId)
                .collection('glucosa')
                .orderBy('fechaHora', descending: true)
                .snapshots(),

            builder: (context, glucosaSnapshot) {
              if (glucosaSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final registros =
                  glucosaSnapshot.data?.docs
                      .map(GlucosaRegistro.fromFirestore)
                      .toList() ??
                  [];

              final promedio = _promedio(registros);

              return ListView(
                padding: const EdgeInsets.all(18),

                children: [
                  _encabezado(paciente),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(
                        child: _dato(
                          titulo: 'ÚLTIMA GLUCOSA',

                          valor: registros.isEmpty
                              ? '--'
                              : registros.first.valor.toString(),

                          unidad: 'mg/dL',

                          icono: Icons.water_drop_outlined,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _dato(
                          titulo: 'PROMEDIO',

                          valor: registros.isEmpty
                              ? '--'
                              : promedio.round().toString(),

                          unidad: 'mg/dL',

                          icono: Icons.show_chart,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Historial de glucosa',

                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  if (registros.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(25),
                        child: Center(
                          child: Text('El paciente aún no tiene mediciones.'),
                        ),
                      ),
                    )
                  else
                    ...registros.take(10).map(_registroGlucosa),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _encabezado(Map<String, dynamic> paciente) {
    final nombre = paciente['nombre'] ?? '';

    final apellidos = paciente['apellidos'] ?? '';

    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        children: [
          CircleAvatar(
            radius: 34,

            backgroundColor: AppColors.primary,

            child: Text(
              nombre.isNotEmpty ? nombre[0].toUpperCase() : 'P',

              style: const TextStyle(
                fontSize: 27,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  '$nombre $apellidos'.trim(),

                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  paciente['correo'] ?? '',

                  style: const TextStyle(color: AppColors.textSecondary),
                ),

                if ((paciente['telefono'] ?? '').toString().isNotEmpty)
                  Text(
                    paciente['telefono'],

                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dato({
    required String titulo,
    required String valor,
    required String unidad,
    required IconData icono,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Text(
                titulo,

                style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),

              Icon(icono, size: 18, color: AppColors.primary),
            ],
          ),

          const SizedBox(height: 13),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,

            children: [
              Text(
                valor,

                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 4),

                child: Text(
                  unidad,

                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _registroGlucosa(GlucosaRegistro registro) {
    final fecha = registro.fechaHora;

    return Card(
      margin: const EdgeInsets.only(bottom: 9),

      child: ListTile(
        leading: const Icon(
          Icons.water_drop_outlined,
          color: AppColors.primary,
        ),

        title: Text(
          '${registro.valor} mg/dL',

          style: const TextStyle(fontWeight: FontWeight.w600),
        ),

        subtitle: Text(
          '${registro.momento}\n'
          '${fecha.day.toString().padLeft(2, '0')}/'
          '${fecha.month.toString().padLeft(2, '0')}/'
          '${fecha.year}',

          style: const TextStyle(fontSize: 11),
        ),

        trailing: Text(
          '${fecha.hour.toString().padLeft(2, '0')}:'
          '${fecha.minute.toString().padLeft(2, '0')}',

          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }

  double _promedio(List<GlucosaRegistro> registros) {
    if (registros.isEmpty) return 0;

    final suma = registros.fold<int>(
      0,
      (total, registro) => total + registro.valor,
    );

    return suma / registros.length;
  }
}
