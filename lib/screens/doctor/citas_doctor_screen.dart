import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/cita.dart';
import '../../services/cita_service.dart';

class CitasDoctorScreen extends StatefulWidget {
  const CitasDoctorScreen({super.key});

  @override
  State<CitasDoctorScreen> createState() => _CitasDoctorScreenState();
}

class _CitasDoctorScreenState extends State<CitasDoctorScreen> {
  final CitaService service = CitaService();

  String filtro = 'Todas';

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

          final todas = snapshot.data ?? [];

          final citas = _filtrar(todas);

          return Column(
            children: [
              // ======================
              // ENCABEZADO
              // ======================

              Container(
                width: double.infinity,

                margin: const EdgeInsets.all(18),

                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,

                  borderRadius: BorderRadius.circular(20),

                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: .15),
                      blurRadius: 18,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),

                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,

                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .18),

                        borderRadius: BorderRadius.circular(15),
                      ),

                      child: const Icon(
                        Icons.calendar_month_outlined,

                        color: Colors.white,

                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          const Text(
                            'Agenda médica',

                            style: TextStyle(
                              color: Colors.white,

                              fontSize: 19,

                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            '${todas.length} cita${todas.length == 1 ? '' : 's'} registrada${todas.length == 1 ? '' : 's'}',

                            style: const TextStyle(
                              color: Colors.white70,

                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ======================
              // FILTROS
              // ======================
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,

                padding: const EdgeInsets.symmetric(horizontal: 18),

                child: Row(
                  children: [
                    _filtro('Todas'),

                    _filtro('Pendientes'),

                    _filtro('Confirmadas'),

                    _filtro('Canceladas'),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // ======================
              // CITAS
              // ======================
              Expanded(
                child: citas.isEmpty
                    ? _vacio()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 25),

                        itemCount: citas.length,

                        itemBuilder: (context, index) {
                          return _tarjeta(citas[index]);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ==========================================
  // FILTRAR
  // ==========================================

  List<Cita> _filtrar(List<Cita> citas) {
    switch (filtro) {
      case 'Pendientes':
        return citas.where((c) => c.estado == 'pendiente').toList();

      case 'Confirmadas':
        return citas.where((c) => c.estado == 'confirmada').toList();

      case 'Canceladas':
        return citas.where((c) => c.estado == 'cancelada').toList();

      default:
        return citas;
    }
  }

  // ==========================================
  // BOTÓN FILTRO
  // ==========================================

  Widget _filtro(String texto) {
    final seleccionado = filtro == texto;

    return Padding(
      padding: const EdgeInsets.only(right: 8),

      child: ChoiceChip(
        label: Text(texto),

        selected: seleccionado,

        onSelected: (_) {
          setState(() {
            filtro = texto;
          });
        },

        selectedColor: AppColors.primary,

        labelStyle: TextStyle(
          color: seleccionado ? Colors.white : AppColors.textSecondary,

          fontWeight: FontWeight.w600,
        ),

        side: BorderSide(
          color: seleccionado ? AppColors.primary : const Color(0xFFE2E8F0),
        ),
      ),
    );
  }

  // ==========================================
  // TARJETA CITA
  // ==========================================

  Widget _tarjeta(Cita cita) {
    final fecha = cita.fechaHora;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),

      padding: const EdgeInsets.all(17),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,

                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: .10),

                  borderRadius: BorderRadius.circular(14),
                ),

                child: const Icon(
                  Icons.person_outline,

                  color: AppColors.primary,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  future: FirebaseFirestore.instance
                      .collection('usuarios')
                      .doc(cita.pacienteId)
                      .get(),

                  builder: (context, snapshot) {
                    String nombre = 'Paciente';

                    if (snapshot.hasData && snapshot.data!.exists) {
                      final data = snapshot.data!.data() ?? {};

                      nombre = data['nombreCompleto']?.toString().trim() ?? '';

                      if (nombre.isEmpty) {
                        nombre =
                            '${data['nombre'] ?? ''} '
                                    '${data['apellidos'] ?? ''}'
                                .trim();
                      }

                      if (nombre.isEmpty) {
                        nombre = 'Paciente';
                      }
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          nombre,

                          style: const TextStyle(
                            fontSize: 16,

                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          cita.motivo,

                          maxLines: 1,

                          overflow: TextOverflow.ellipsis,

                          style: const TextStyle(
                            color: AppColors.textSecondary,

                            fontSize: 12,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _estadoChip(cita.estado),

                  const SizedBox(height: 3),

                  PopupMenuButton<String>(
                    tooltip: 'Opciones',

                    icon: const Icon(
                      Icons.more_vert,
                      color: AppColors.textSecondary,
                    ),

                    onSelected: (opcion) {
                      if (opcion == 'reprogramar') {
                        _reprogramarCita(cita);
                      }

                      if (opcion == 'eliminar') {
                        _confirmarEliminar(cita);
                      }
                    },

                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'reprogramar',

                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_calendar_outlined,
                              color: AppColors.primary,
                            ),

                            SizedBox(width: 10),

                            Text('Reprogramar'),
                          ],
                        ),
                      ),

                      const PopupMenuItem(
                        value: 'eliminar',

                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: AppColors.danger),

                            SizedBox(width: 10),

                            Text(
                              'Eliminar cita',

                              style: TextStyle(color: AppColors.danger),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(13),

            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),

              borderRadius: BorderRadius.circular(13),
            ),

            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,

                  color: AppColors.primary,

                  size: 18,
                ),

                const SizedBox(width: 7),

                Text(
                  '${fecha.day.toString().padLeft(2, '0')}/'
                  '${fecha.month.toString().padLeft(2, '0')}/'
                  '${fecha.year}',

                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),

                const Spacer(),

                const Icon(Icons.schedule, color: AppColors.primary, size: 18),

                const SizedBox(width: 6),

                Text(
                  '${fecha.hour.toString().padLeft(2, '0')}:'
                  '${fecha.minute.toString().padLeft(2, '0')}',

                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          // ============================
          // PENDIENTE
          // ============================
          if (cita.estado == 'pendiente') ...[
            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _cambiarEstado(cita, 'cancelada');
                    },

                    icon: const Icon(Icons.close),

                    label: const Text('Cancelar'),

                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,

                      side: const BorderSide(color: AppColors.danger),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      _cambiarEstado(cita, 'confirmada');
                    },

                    icon: const Icon(Icons.check),

                    label: const Text('Confirmar'),

                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // Método para reprogramar
  // ==========================================

  Future<void> _reprogramarCita(Cita cita) async {
    DateTime nuevaFecha = cita.fechaHora;

    TimeOfDay nuevaHora = TimeOfDay.fromDateTime(cita.fechaHora);

    final resultado = await showDialog<bool>(
      context: context,

      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),

              title: const Row(
                children: [
                  Icon(Icons.edit_calendar_outlined, color: AppColors.primary),

                  SizedBox(width: 10),

                  Text('Reprogramar cita'),
                ],
              ),

              content: Column(
                mainAxisSize: MainAxisSize.min,

                children: [
                  const Text(
                    'Selecciona la nueva fecha y hora de la cita.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),

                  const SizedBox(height: 20),

                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),

                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),

                    leading: const Icon(
                      Icons.calendar_today_outlined,
                      color: AppColors.primary,
                    ),

                    title: const Text('Fecha'),

                    subtitle: Text(
                      '${nuevaFecha.day.toString().padLeft(2, '0')}/'
                      '${nuevaFecha.month.toString().padLeft(2, '0')}/'
                      '${nuevaFecha.year}',
                    ),

                    onTap: () async {
                      final fecha = await showDatePicker(
                        context: context,

                        initialDate: nuevaFecha,

                        firstDate: DateTime.now(),

                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );

                      if (fecha != null) {
                        setDialogState(() {
                          nuevaFecha = fecha;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 10),

                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),

                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),

                    leading: const Icon(
                      Icons.schedule,
                      color: AppColors.primary,
                    ),

                    title: const Text('Hora'),

                    subtitle: Text(
                      '${nuevaHora.hour.toString().padLeft(2, '0')}:'
                      '${nuevaHora.minute.toString().padLeft(2, '0')}',
                    ),

                    onTap: () async {
                      final hora = await showTimePicker(
                        context: context,

                        initialTime: nuevaHora,
                      );

                      if (hora != null) {
                        setDialogState(() {
                          nuevaHora = hora;
                        });
                      }
                    },
                  ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },

                  child: const Text('Cancelar'),
                ),

                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(dialogContext, true);
                  },

                  icon: const Icon(Icons.check),

                  label: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (resultado != true) {
      return;
    }

    final fechaHora = DateTime(
      nuevaFecha.year,
      nuevaFecha.month,
      nuevaFecha.day,
      nuevaHora.hour,
      nuevaHora.minute,
    );

    if (fechaHora.isBefore(DateTime.now())) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La nueva fecha debe ser futura.')),
      );

      return;
    }

    try {
      await service.reprogramar(citaId: cita.id, nuevaFecha: fechaHora);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cita reprogramada correctamente.'),

          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No se pudo reprogramar: $e')));
    }
  }

  // ==========================================
  // CAMBIAR ESTADO
  // ==========================================

  Future<void> _cambiarEstado(Cita cita, String nuevoEstado) async {
    try {
      await service.cambiarEstado(citaId: cita.id, estado: nuevoEstado);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nuevoEstado == 'confirmada'
                ? 'Cita confirmada.'
                : 'Cita cancelada.',
          ),

          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar la cita: $e')),
      );
    }
  }

  // ==========================================
  // ELIMINAR
  // ==========================================

  Future<void> _confirmarEliminar(Cita cita) async {
    final eliminar = await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),

          icon: Container(
            width: 60,
            height: 60,

            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: .10),

              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.delete_outline,

              color: AppColors.danger,

              size: 30,
            ),
          ),

          title: const Text('¿Eliminar cita?', textAlign: TextAlign.center),

          content: const Text(
            'Esta cita se eliminará definitivamente.',
            textAlign: TextAlign.center,

            style: TextStyle(color: AppColors.textSecondary),
          ),

          actionsAlignment: MainAxisAlignment.center,

          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context, false);
              },

              child: const Text('Cancelar'),
            ),

            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: AppColors.danger),

              onPressed: () {
                Navigator.pop(context, true);
              },

              icon: const Icon(Icons.delete_outline),

              label: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (eliminar != true) {
      return;
    }

    try {
      await service.eliminarCita(cita.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cita eliminada correctamente.'),

          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar la cita: $e')),
      );
    }
  }

  // ==========================================
  // ESTADO
  // ==========================================

  Widget _estadoChip(String estado) {
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

    final texto = estado.isEmpty
        ? 'Pendiente'
        : '${estado[0].toUpperCase()}${estado.substring(1)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),

      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),

        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(
        texto,

        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ==========================================
  // VACÍO
  // ==========================================

  Widget _vacio() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(
              Icons.event_available_outlined,

              size: 70,

              color: AppColors.textMuted,
            ),

            SizedBox(height: 15),

            Text(
              'No hay citas',

              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),

            SizedBox(height: 5),

            Text(
              'Las solicitudes de los pacientes aparecerán aquí.',

              textAlign: TextAlign.center,

              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
