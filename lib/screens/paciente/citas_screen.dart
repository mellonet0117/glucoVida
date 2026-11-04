import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/cita.dart';
import '../../services/cita_service.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class CitasScreen extends StatefulWidget {
  const CitasScreen({super.key});

  @override
  State<CitasScreen> createState() => _CitasScreenState();
}

class _CitasScreenState extends State<CitasScreen> {
  final CitaService service = CitaService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(title: const Text('Mis citas')),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,

        icon: const Icon(Icons.add),

        label: const Text('Solicitar cita'),

        onPressed: abrirNuevaCita,
      ),

      body: StreamBuilder<List<Cita>>(
        stream: service.citasPaciente(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final citas = snapshot.data ?? [];

          if (citas.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 75,
                    color: AppColors.textMuted,
                  ),

                  SizedBox(height: 15),

                  Text(
                    'No tienes citas',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Solicita una cita con tu doctor.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(18),

            itemCount: citas.length,

            itemBuilder: (context, index) {
              return tarjetaCita(citas[index]);
            },
          );
        },
      ),
    );
  }

  Widget tarjetaCita(Cita cita) {
    final fecha = cita.fechaHora;

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
                  width: 50,
                  height: 50,

                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDFA),

                    borderRadius: BorderRadius.circular(13),
                  ),

                  child: const Icon(
                    Icons.calendar_month_outlined,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        cita.motivo,

                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        '${fecha.day.toString().padLeft(2, '0')}/'
                        '${fecha.month.toString().padLeft(2, '0')}/'
                        '${fecha.year} · '
                        '${fecha.hour.toString().padLeft(2, '0')}:'
                        '${fecha.minute.toString().padLeft(2, '0')}',

                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),

                estadoChip(cita.estado),
              ],
            ),

            if (cita.notasDoctor.isNotEmpty) ...[
              const SizedBox(height: 13),

              const Divider(),

              const SizedBox(height: 5),

              const Text(
                'Observaciones del doctor',

                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 4),

              Text(
                cita.notasDoctor,

                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget estadoChip(String estado) {
    Color color;

    switch (estado) {
      case 'confirmada':
        color = AppColors.success;
        break;

      case 'cancelada':
        color = AppColors.danger;
        break;

      default:
        color = AppColors.warning;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),

      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),

        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(
        estado[0].toUpperCase() + estado.substring(1),

        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> abrirNuevaCita() async {
    DateTime fecha = DateTime.now().add(const Duration(days: 1));

    TimeOfDay hora = const TimeOfDay(hour: 10, minute: 0);

    final motivoController = TextEditingController();

    String? doctorSeleccionado;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,

      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> seleccionarFecha() async {
              final resultado = await showDatePicker(
                context: context,
                initialDate: fecha,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );

              if (resultado != null) {
                setModalState(() {
                  fecha = resultado;
                });
              }
            }

            Future<void> seleccionarHora() async {
              final resultado = await showTimePicker(
                context: context,
                initialTime: hora,
              );

              if (resultado != null) {
                setModalState(() {
                  hora = resultado;
                });
              }
            }

            return Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),

              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 18,

                  bottom: MediaQuery.of(context).viewInsets.bottom + 25,
                ),

                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,

                    children: [
                      Center(
                        child: Container(
                          width: 45,
                          height: 5,

                          decoration: BoxDecoration(
                            color: const Color(0xFFCBD5E1),

                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Solicitar cita',

                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 5),

                      const Text(
                        'Selecciona un doctor y agenda la fecha que prefieras.',

                        style: TextStyle(color: AppColors.textSecondary),
                      ),

                      const SizedBox(height: 22),

                      // =====================
                      // DOCTOR
                      // =====================
                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('usuarios')
                            .where('rol', isEqualTo: 'doctor')
                            .snapshots(),

                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError) {
                            return Text(
                              'Error al cargar doctores: ${snapshot.error}',
                            );
                          }

                          final doctores = snapshot.data?.docs ?? [];

                          if (doctores.isEmpty) {
                            return const Text('No hay doctores disponibles.');
                          }

                          return DropdownButtonFormField<String>(
                            initialValue: doctorSeleccionado,

                            isExpanded: true,

                            decoration: const InputDecoration(
                              labelText: 'Seleccionar doctor',

                              prefixIcon: Icon(
                                Icons.medical_services_outlined,

                                color: AppColors.primary,
                              ),
                            ),

                            items: doctores.map((doc) {
                              final data = doc.data();

                              String nombre =
                                  data['nombreCompleto']?.toString().trim() ??
                                  '';

                              if (nombre.isEmpty) {
                                final nombres =
                                    data['nombre']?.toString() ?? '';

                                final apellidos =
                                    data['apellidos']?.toString() ?? '';

                                nombre = '$nombres $apellidos'.trim();
                              }

                              if (nombre.isEmpty) {
                                nombre = 'Doctor';
                              }

                              return DropdownMenuItem<String>(
                                value: doc.id,

                                child: Text(
                                  nombre,

                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),

                            onChanged: (value) {
                              setModalState(() {
                                doctorSeleccionado = value;
                              });
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 17),

                      // =====================
                      // MOTIVO
                      // =====================
                      TextField(
                        controller: motivoController,

                        maxLines: 3,

                        decoration: const InputDecoration(
                          labelText: 'Motivo de la cita',

                          hintText: 'Ej. Revisión de seguimiento',

                          prefixIcon: Padding(
                            padding: EdgeInsets.only(bottom: 45),

                            child: Icon(
                              Icons.description_outlined,

                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // =====================
                      // FECHA Y HORA
                      // =====================
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: seleccionarFecha,

                              icon: const Icon(Icons.calendar_today_outlined),

                              label: Text(
                                '${fecha.day.toString().padLeft(2, '0')}/'
                                '${fecha.month.toString().padLeft(2, '0')}/'
                                '${fecha.year}',
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: seleccionarHora,

                              icon: const Icon(Icons.schedule),

                              label: Text(
                                '${hora.hour.toString().padLeft(2, '0')}:'
                                '${hora.minute.toString().padLeft(2, '0')}',
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      // =====================
                      // BOTÓN
                      // =====================
                      Container(
                        height: 53,

                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,

                          borderRadius: BorderRadius.circular(14),
                        ),

                        child: Material(
                          color: Colors.transparent,

                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),

                            onTap: () async {
                              if (doctorSeleccionado == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Selecciona un doctor.'),
                                  ),
                                );

                                return;
                              }

                              if (motivoController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Escribe el motivo de la cita.',
                                    ),
                                  ),
                                );

                                return;
                              }

                              final fechaHora = DateTime(
                                fecha.year,
                                fecha.month,
                                fecha.day,
                                hora.hour,
                                hora.minute,
                              );

                              if (fechaHora.isBefore(DateTime.now())) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Selecciona una fecha y hora futuras.',
                                    ),
                                  ),
                                );

                                return;
                              }

                              try {
                                final navigator = Navigator.of(context);

                                final messenger = ScaffoldMessenger.of(
                                  this.context,
                                );

                                await service.solicitarCitaPaciente(
                                  doctorId: doctorSeleccionado!,

                                  fechaHora: fechaHora,

                                  motivo: motivoController.text,
                                );

                                if (!mounted || !context.mounted) {
                                  return;
                                }

                                navigator.pop();

                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Solicitud enviada correctamente.',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              } catch (e) {
                                if (!context.mounted) {
                                  return;
                                }

                                Navigator.pop(context);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      e.toString().replaceFirst(
                                        'Exception: ',
                                        '',
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },

                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,

                              children: [
                                Icon(Icons.send_outlined, color: Colors.white),

                                SizedBox(width: 8),

                                Text(
                                  'Enviar solicitud',

                                  style: TextStyle(
                                    color: Colors.white,

                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
