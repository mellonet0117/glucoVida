import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/recordatorio.dart';
import '../../services/recordatorio_service.dart';

class RecordatoriosScreen extends StatelessWidget {
  RecordatoriosScreen({super.key});

  final RecordatorioService service = RecordatorioService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(title: const Text('Recordatorios')),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,

        onPressed: () {
          _abrirFormulario(context);
        },

        icon: const Icon(Icons.add),

        label: const Text('Nuevo recordatorio'),
      ),

      body: StreamBuilder<List<Recordatorio>>(
        stream: service.obtenerRecordatorios(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final recordatorios = snapshot.data ?? [];

          if (recordatorios.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    size: 75,
                    color: AppColors.textMuted,
                  ),

                  SizedBox(height: 15),

                  Text(
                    'No tienes recordatorios',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),

                  SizedBox(height: 6),

                  Text(
                    'Crea uno para comenzar.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(18),

            itemCount: recordatorios.length,

            itemBuilder: (context, index) {
              return _tarjeta(context, recordatorios[index]);
            },
          );
        },
      ),
    );
  }

  Widget _tarjeta(BuildContext context, Recordatorio recordatorio) {
    return Card(
      margin: const EdgeInsets.only(bottom: 13),

      child: Padding(
        padding: const EdgeInsets.all(15),

        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,

              decoration: BoxDecoration(
                color: const Color(0xFFF0FDFA),

                borderRadius: BorderRadius.circular(14),
              ),

              child: Icon(_icono(recordatorio.tipo), color: AppColors.primary),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recordatorio.titulo,

                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    recordatorio.descripcion,

                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 15,
                        color: AppColors.primary,
                      ),

                      const SizedBox(width: 4),

                      Text(
                        recordatorio.hora,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Switch(
              value: recordatorio.activo,

              activeThumbColor: AppColors.primary,

              onChanged: (value) {
                service.cambiarEstado(recordatorio, value);
              },
            ),

            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'editar') {
                  _abrirFormulario(context, recordatorio: recordatorio);
                }

                if (value == 'eliminar') {
                  _eliminar(context, recordatorio);
                }
              },

              itemBuilder: (_) => [
                const PopupMenuItem(value: 'editar', child: Text('Editar')),

                const PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _icono(String tipo) {
    switch (tipo) {
      case 'Glucosa':
        return Icons.water_drop_outlined;

      case 'Medicamento':
        return Icons.medication_outlined;

      case 'Actividad física':
        return Icons.directions_run_outlined;

      case 'Cita médica':
        return Icons.calendar_month_outlined;

      default:
        return Icons.notifications_outlined;
    }
  }

  Future<void> _eliminar(
    BuildContext context,
    Recordatorio recordatorio,
  ) async {
    final respuesta = await showDialog<bool>(
      context: context,

      builder: (_) => AlertDialog(
        title: const Text('Eliminar recordatorio'),

        content: Text('¿Deseas eliminar "${recordatorio.titulo}"?'),

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
      ),
    );

    if (respuesta == true) {
      await service.eliminar(recordatorio);
    }
  }

  void _abrirFormulario(BuildContext context, {Recordatorio? recordatorio}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,

      builder: (_) => _FormularioRecordatorio(recordatorio: recordatorio),
    );
  }
}

class _FormularioRecordatorio extends StatefulWidget {
  final Recordatorio? recordatorio;

  const _FormularioRecordatorio({this.recordatorio});

  @override
  State<_FormularioRecordatorio> createState() =>
      _FormularioRecordatorioState();
}

class _FormularioRecordatorioState extends State<_FormularioRecordatorio> {
  final RecordatorioService service = RecordatorioService();

  late TextEditingController tituloController;

  late TextEditingController descripcionController;

  String tipo = 'Glucosa';

  TimeOfDay hora = TimeOfDay.now();

  bool guardando = false;

  @override
  void initState() {
    super.initState();

    tituloController = TextEditingController(
      text: widget.recordatorio?.titulo ?? '',
    );

    descripcionController = TextEditingController(
      text: widget.recordatorio?.descripcion ?? '',
    );

    tipo = widget.recordatorio?.tipo ?? 'Glucosa';

    if (widget.recordatorio != null) {
      final partes = widget.recordatorio!.hora.split(':');

      hora = TimeOfDay(
        hour: int.parse(partes[0]),
        minute: int.parse(partes[1]),
      );
    }
  }

  @override
  void dispose() {
    tituloController.dispose();
    descripcionController.dispose();

    super.dispose();
  }

  Future<void> seleccionarHora() async {
    final resultado = await showTimePicker(context: context, initialTime: hora);

    if (resultado == null) return;

    setState(() {
      hora = resultado;
    });
  }

  Future<void> guardar() async {
    if (tituloController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Escribe un título.')));

      return;
    }

    setState(() {
      guardando = true;
    });

    try {
      if (widget.recordatorio == null) {
        await service.agregar(
          tipo: tipo,
          titulo: tituloController.text,
          descripcion: descripcionController.text,
          hora: hora.hour,
          minuto: hora.minute,
        );
      } else {
        await service.actualizar(
          recordatorio: widget.recordatorio!,
          tipo: tipo,
          titulo: tituloController.text,
          descripcion: descripcionController.text,
          hora: hora.hour,
          minuto: hora.minute,
        );
      }

      if (!mounted) return;

      Navigator.pop(context);
    } finally {
      if (mounted) {
        setState(() {
          guardando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            Text(
              widget.recordatorio == null
                  ? 'Nuevo recordatorio'
                  : 'Editar recordatorio',

              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            DropdownButtonFormField<String>(
              initialValue: tipo,

              decoration: const InputDecoration(labelText: 'Tipo'),

              items: const [
                DropdownMenuItem(value: 'Glucosa', child: Text('Glucosa')),

                DropdownMenuItem(
                  value: 'Medicamento',
                  child: Text('Medicamento'),
                ),

                DropdownMenuItem(
                  value: 'Actividad física',
                  child: Text('Actividad física'),
                ),

                DropdownMenuItem(
                  value: 'Cita médica',
                  child: Text('Cita médica'),
                ),
              ],

              onChanged: (value) {
                if (value != null) {
                  tipo = value;
                }
              },
            ),

            const SizedBox(height: 15),

            TextField(
              controller: tituloController,

              decoration: const InputDecoration(
                labelText: 'Título',

                hintText: 'Ej. Medir glucosa',
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: descripcionController,

              maxLines: 2,

              decoration: const InputDecoration(
                labelText: 'Descripción',

                hintText: 'Ej. Medición después del desayuno',
              ),
            ),

            const SizedBox(height: 15),

            OutlinedButton.icon(
              onPressed: seleccionarHora,

              icon: const Icon(Icons.schedule),

              label: Text(
                '${hora.hour.toString().padLeft(2, '0')}:'
                '${hora.minute.toString().padLeft(2, '0')}',
              ),
            ),

            const SizedBox(height: 25),

            Container(
              height: 52,

              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,

                borderRadius: BorderRadius.circular(12),
              ),

              child: Material(
                color: Colors.transparent,

                child: InkWell(
                  borderRadius: BorderRadius.circular(12),

                  onTap: guardando ? null : guardar,

                  child: Center(
                    child: guardando
                        ? const SizedBox(
                            width: 24,
                            height: 24,

                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Guardar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
