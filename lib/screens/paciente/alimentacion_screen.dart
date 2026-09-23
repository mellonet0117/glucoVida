import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/registro_alimentacion.dart';
import '../../services/alimentacion_service.dart';

class AlimentacionScreen extends StatelessWidget {
  AlimentacionScreen({super.key});

  final AlimentacionService service = AlimentacionService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(title: const Text('Alimentación')),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,

        onPressed: () {
          _abrirFormulario(context);
        },

        icon: const Icon(Icons.add),

        label: const Text('Registrar comida'),
      ),

      body: StreamBuilder<List<RegistroAlimentacion>>(
        stream: service.obtenerRegistros(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final registros = snapshot.data ?? [];

          if (registros.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_outlined,
                    size: 75,
                    color: AppColors.textMuted,
                  ),

                  SizedBox(height: 15),

                  Text(
                    'No tienes comidas registradas',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Presiona "Registrar comida" para comenzar.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(18),

            itemCount: registros.length,

            itemBuilder: (context, index) {
              return _tarjeta(context, registros[index]);
            },
          );
        },
      ),
    );
  }

  Widget _tarjeta(BuildContext context, RegistroAlimentacion registro) {
    return Card(
      margin: const EdgeInsets.only(bottom: 13),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Container(
              width: 52,
              height: 52,

              decoration: BoxDecoration(
                color: const Color(0xFFF0FDFA),

                borderRadius: BorderRadius.circular(14),
              ),

              child: Icon(_iconoTipo(registro.tipo), color: AppColors.primary),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    registro.tipo,

                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    registro.alimentos,

                    style: const TextStyle(color: AppColors.textPrimary),
                  ),

                  if (registro.porcion.isNotEmpty) ...[
                    const SizedBox(height: 4),

                    Text(
                      'Porción: ${registro.porcion}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],

                  const SizedBox(height: 5),

                  Text(
                    _fecha(registro.fechaHora),

                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),

                  if (registro.notas.isNotEmpty) ...[
                    const SizedBox(height: 7),

                    Text(
                      registro.notas,

                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'editar') {
                  _abrirFormulario(context, registro: registro);
                }

                if (value == 'eliminar') {
                  _eliminar(context, registro);
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

  IconData _iconoTipo(String tipo) {
    switch (tipo) {
      case 'Desayuno':
        return Icons.free_breakfast_outlined;

      case 'Comida':
        return Icons.lunch_dining_outlined;

      case 'Cena':
        return Icons.dinner_dining_outlined;

      case 'Colación':
        return Icons.apple_outlined;

      default:
        return Icons.restaurant_outlined;
    }
  }

  String _fecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year} · '
        '${fecha.hour.toString().padLeft(2, '0')}:'
        '${fecha.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _eliminar(
    BuildContext context,
    RegistroAlimentacion registro,
  ) async {
    final respuesta = await showDialog<bool>(
      context: context,

      builder: (_) {
        return AlertDialog(
          title: const Text('Eliminar registro'),

          content: Text(
            '¿Deseas eliminar este registro de ${registro.tipo.toLowerCase()}?',
          ),

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

    if (respuesta == true) {
      await service.eliminar(registro.id);
    }
  }

  void _abrirFormulario(
    BuildContext context, {
    RegistroAlimentacion? registro,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,

      builder: (_) {
        return _FormularioAlimentacion(registro: registro);
      },
    );
  }
}

class _FormularioAlimentacion extends StatefulWidget {
  final RegistroAlimentacion? registro;

  const _FormularioAlimentacion({this.registro});

  @override
  State<_FormularioAlimentacion> createState() =>
      _FormularioAlimentacionState();
}

class _FormularioAlimentacionState extends State<_FormularioAlimentacion> {
  final AlimentacionService service = AlimentacionService();

  late TextEditingController alimentosController;

  late TextEditingController porcionController;

  late TextEditingController notasController;

  String tipo = 'Desayuno';

  DateTime fechaHora = DateTime.now();

  bool guardando = false;

  @override
  void initState() {
    super.initState();

    alimentosController = TextEditingController(
      text: widget.registro?.alimentos ?? '',
    );

    porcionController = TextEditingController(
      text: widget.registro?.porcion ?? '',
    );

    notasController = TextEditingController(text: widget.registro?.notas ?? '');

    tipo = widget.registro?.tipo ?? 'Desayuno';

    fechaHora = widget.registro?.fechaHora ?? DateTime.now();
  }

  @override
  void dispose() {
    alimentosController.dispose();
    porcionController.dispose();
    notasController.dispose();

    super.dispose();
  }

  Future<void> seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: fechaHora,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (fecha == null || !mounted) {
      return;
    }

    setState(() {
      fechaHora = DateTime(
        fecha.year,
        fecha.month,
        fecha.day,
        fechaHora.hour,
        fechaHora.minute,
      );
    });
  }

  Future<void> seleccionarHora() async {
    final nuevaHora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(fechaHora),
    );

    if (nuevaHora == null || !mounted) {
      return;
    }

    setState(() {
      fechaHora = DateTime(
        fechaHora.year,
        fechaHora.month,
        fechaHora.day,
        nuevaHora.hour,
        nuevaHora.minute,
      );
    });
  }

  Future<void> guardar() async {
    if (alimentosController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe los alimentos consumidos.')),
      );

      return;
    }

    setState(() {
      guardando = true;
    });

    try {
      if (widget.registro == null) {
        await service.agregar(
          tipo: tipo,
          alimentos: alimentosController.text,
          porcion: porcionController.text,
          notas: notasController.text,
          fechaHora: fechaHora,
        );
      } else {
        await service.actualizar(
          id: widget.registro!.id,
          tipo: tipo,
          alimentos: alimentosController.text,
          porcion: porcionController.text,
          notas: notasController.text,
          fechaHora: fechaHora,
        );
      }

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No se pudo guardar: $e')));
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
              widget.registro == null
                  ? 'Registrar alimentación'
                  : 'Editar alimentación',

              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            DropdownButtonFormField<String>(
              initialValue: tipo,

              decoration: const InputDecoration(labelText: 'Tipo de comida'),

              items: const [
                DropdownMenuItem(value: 'Desayuno', child: Text('Desayuno')),

                DropdownMenuItem(value: 'Comida', child: Text('Comida')),

                DropdownMenuItem(value: 'Cena', child: Text('Cena')),

                DropdownMenuItem(value: 'Colación', child: Text('Colación')),
              ],

              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    tipo = value;
                  });
                }
              },
            ),

            const SizedBox(height: 15),

            TextField(
              controller: alimentosController,

              maxLines: 2,

              decoration: const InputDecoration(
                labelText: 'Alimentos',

                hintText: 'Ej. pollo, arroz, ensalada...',
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: porcionController,

              decoration: const InputDecoration(
                labelText: 'Porción',

                hintText: 'Ej. 1 plato, 250 g...',
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: seleccionarFecha,

                    icon: const Icon(Icons.calendar_month),

                    label: Text(
                      '${fechaHora.day.toString().padLeft(2, '0')}/'
                      '${fechaHora.month.toString().padLeft(2, '0')}/'
                      '${fechaHora.year}',
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: seleccionarHora,

                    icon: const Icon(Icons.schedule),

                    label: Text(
                      '${fechaHora.hour.toString().padLeft(2, '0')}:'
                      '${fechaHora.minute.toString().padLeft(2, '0')}',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            TextField(
              controller: notasController,

              maxLines: 3,

              decoration: const InputDecoration(
                labelText: 'Notas',

                hintText: 'Observaciones opcionales...',
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
