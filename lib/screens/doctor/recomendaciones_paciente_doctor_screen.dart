import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/recomendacion_doctor.dart';
import '../../services/recomendacion_doctor_service.dart';
import 'nueva_recomendacion_screen.dart';

class RecomendacionesPacienteDoctorScreen extends StatelessWidget {
  final String pacienteId;
  final String nombrePaciente;

  RecomendacionesPacienteDoctorScreen({
    super.key,
    required this.pacienteId,
    required this.nombrePaciente,
  });

  final RecomendacionDoctorService service = RecomendacionDoctorService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(title: const Text('Recomendaciones')),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,

        foregroundColor: Colors.white,

        icon: const Icon(Icons.add_comment_outlined),

        label: const Text('Nueva'),

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NuevaRecomendacionScreen(pacienteId: pacienteId),
            ),
          );
        },
      ),

      body: StreamBuilder<List<RecomendacionDoctor>>(
        stream: service.obtener(pacienteId),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'No se pudieron cargar las recomendaciones.\n'
                '${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final recomendaciones = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(18),

            children: [
              Text(
                nombrePaciente.isEmpty ? 'Paciente' : nombrePaciente,

                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                recomendaciones.length == 1
                    ? '1 recomendación enviada'
                    : '${recomendaciones.length} recomendaciones enviadas',

                style: const TextStyle(color: AppColors.textSecondary),
              ),

              const SizedBox(height: 20),

              if (recomendaciones.isEmpty)
                _sinRecomendaciones()
              else
                ...recomendaciones.map((recomendacion) {
                  return _tarjeta(context, recomendacion);
                }),

              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }

  Widget _tarjeta(BuildContext context, RecomendacionDoctor recomendacion) {
    final fecha = recomendacion.fecha;

    return Card(
      margin: const EdgeInsets.only(bottom: 13),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                Container(
                  width: 47,
                  height: 47,

                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: .10),

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

                      const SizedBox(height: 2),

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

                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'editar') {
                      _editar(context, recomendacion);
                    }

                    if (value == 'eliminar') {
                      _eliminar(context, recomendacion);
                    }
                  },

                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'editar',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 19),

                          SizedBox(width: 8),

                          Text('Editar'),
                        ],
                      ),
                    ),

                    const PopupMenuItem(
                      value: 'eliminar',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 19,
                            color: AppColors.danger,
                          ),

                          SizedBox(width: 8),

                          Text('Eliminar'),
                        ],
                      ),
                    ),
                  ],
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

            const SizedBox(height: 12),

            const Divider(),

            const SizedBox(height: 5),

            Row(
              children: [
                const Icon(
                  Icons.schedule,
                  size: 15,
                  color: AppColors.textMuted,
                ),

                const SizedBox(width: 5),

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

  Widget _sinRecomendaciones() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),
      ),

      child: const Column(
        children: [
          Icon(
            Icons.medical_information_outlined,
            size: 65,
            color: AppColors.textMuted,
          ),

          SizedBox(height: 14),

          Text(
            'Sin recomendaciones',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),

          SizedBox(height: 5),

          Text(
            'Todavía no has enviado recomendaciones a este paciente.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminar(
    BuildContext context,
    RecomendacionDoctor recomendacion,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar recomendación'),

          content: Text('¿Deseas eliminar "${recomendacion.titulo}"?'),

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

              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    try {
      await service.eliminar(
        pacienteId: pacienteId,

        recomendacionId: recomendacion.id,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Recomendación eliminada.')));
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No se pudo eliminar: $e')));
    }
  }

  void _editar(BuildContext context, RecomendacionDoctor recomendacion) {
    final tituloController = TextEditingController(text: recomendacion.titulo);

    final descripcionController = TextEditingController(
      text: recomendacion.descripcion,
    );

    String tipo = recomendacion.tipo;

    bool guardando = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,

      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 25,

                bottom: MediaQuery.of(context).viewInsets.bottom + 25,
              ),

              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,

                  children: [
                    const Text(
                      'Editar recomendación',

                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    DropdownButtonFormField<String>(
                      initialValue: tipo,

                      decoration: const InputDecoration(labelText: 'Tipo'),

                      items: const [
                        DropdownMenuItem(
                          value: 'General',
                          child: Text('General'),
                        ),

                        DropdownMenuItem(
                          value: 'Alimentación',
                          child: Text('Alimentación'),
                        ),

                        DropdownMenuItem(
                          value: 'Actividad física',
                          child: Text('Actividad física'),
                        ),

                        DropdownMenuItem(
                          value: 'Seguimiento',
                          child: Text('Seguimiento'),
                        ),
                      ],

                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() {
                            tipo = value;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: tituloController,

                      decoration: const InputDecoration(labelText: 'Título'),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: descripcionController,

                      minLines: 4,
                      maxLines: 7,

                      decoration: const InputDecoration(
                        labelText: 'Recomendación',
                      ),
                    ),

                    const SizedBox(height: 25),

                    FilledButton(
                      onPressed: guardando
                          ? null
                          : () async {
                              if (tituloController.text.trim().isEmpty ||
                                  descripcionController.text.trim().isEmpty) {
                                return;
                              }

                              setModalState(() {
                                guardando = true;
                              });

                              try {
                                await service.actualizar(
                                  pacienteId: pacienteId,

                                  recomendacionId: recomendacion.id,

                                  tipo: tipo,

                                  titulo: tituloController.text,

                                  descripcion: descripcionController.text,
                                );

                                if (!context.mounted) {
                                  return;
                                }

                                Navigator.pop(context);
                              } finally {
                                if (context.mounted) {
                                  setModalState(() {
                                    guardando = false;
                                  });
                                }
                              }
                            },

                      child: guardando
                          ? const SizedBox(
                              width: 22,
                              height: 22,

                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Guardar cambios'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      tituloController.dispose();
      descripcionController.dispose();
    });
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
