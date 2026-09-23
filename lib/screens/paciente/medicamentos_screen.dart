import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/medicamento.dart';
import '../../services/medicamento_service.dart';

class MedicamentosScreen extends StatelessWidget {
  MedicamentosScreen({super.key});

  final MedicamentoService service = MedicamentoService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(title: const Text('Medicamentos')),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,

        onPressed: () {
          _abrirFormulario(context);
        },

        icon: const Icon(Icons.add),

        label: const Text('Agregar'),
      ),

      body: StreamBuilder<List<Medicamento>>(
        stream: service.obtenerMedicamentos(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }

          final medicamentos = snapshot.data ?? [];

          if (medicamentos.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Icon(
                    Icons.medication_outlined,
                    size: 75,
                    color: AppColors.textMuted,
                  ),

                  SizedBox(height: 15),

                  Text(
                    'No tienes medicamentos registrados',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(18),

            itemCount: medicamentos.length,

            itemBuilder: (context, index) {
              final medicamento = medicamentos[index];

              return _tarjeta(context, medicamento);
            },
          );
        },
      ),
    );
  }

  Widget _tarjeta(BuildContext context, Medicamento medicamento) {
    final tomado = medicamento.tomadoHoy;

    return Card(
      margin: const EdgeInsets.only(bottom: 13),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,

              decoration: BoxDecoration(
                color: tomado
                    ? const Color(0xFFECFDF5)
                    : const Color(0xFFFFFBEB),

                borderRadius: BorderRadius.circular(14),
              ),

              child: Icon(
                Icons.medication_rounded,

                color: tomado ? AppColors.success : AppColors.warning,
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    medicamento.nombre,

                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    medicamento.dosis,

                    style: const TextStyle(color: AppColors.textSecondary),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '${medicamento.hora} · ${medicamento.frecuencia}',

                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            Column(
              children: [
                if (!tomado)
                  IconButton(
                    tooltip: 'Marcar como tomado',

                    onPressed: () {
                      service.marcarTomado(medicamento.id);
                    },

                    icon: const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.success,
                    ),
                  )
                else
                  const Icon(Icons.check_circle, color: AppColors.success),

                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'editar') {
                      _abrirFormulario(context, medicamento: medicamento);
                    }

                    if (value == 'eliminar') {
                      _eliminar(context, medicamento);
                    }
                  },

                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'editar', child: Text('Editar')),

                    const PopupMenuItem(
                      value: 'eliminar',
                      child: Text('Eliminar'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _eliminar(BuildContext context, Medicamento medicamento) async {
    final respuesta = await showDialog<bool>(
      context: context,

      builder: (_) => AlertDialog(
        title: const Text('Eliminar medicamento'),

        content: Text('¿Deseas eliminar ${medicamento.nombre}?'),

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
      await service.eliminar(medicamento.id);
    }
  }

  void _abrirFormulario(BuildContext context, {Medicamento? medicamento}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,

      builder: (_) {
        return _FormularioMedicamento(medicamento: medicamento);
      },
    );
  }
}

class _FormularioMedicamento extends StatefulWidget {
  final Medicamento? medicamento;

  const _FormularioMedicamento({this.medicamento});

  @override
  State<_FormularioMedicamento> createState() => _FormularioMedicamentoState();
}

class _FormularioMedicamentoState extends State<_FormularioMedicamento> {
  final service = MedicamentoService();

  late TextEditingController nombreController;

  late TextEditingController dosisController;

  String frecuencia = 'Diario';

  TimeOfDay hora = TimeOfDay.now();

  bool guardando = false;

  @override
  void initState() {
    super.initState();

    nombreController = TextEditingController(
      text: widget.medicamento?.nombre ?? '',
    );

    dosisController = TextEditingController(
      text: widget.medicamento?.dosis ?? '',
    );

    frecuencia = widget.medicamento?.frecuencia ?? 'Diario';

    if (widget.medicamento != null) {
      final partes = widget.medicamento!.hora.split(':');

      if (partes.length == 2) {
        hora = TimeOfDay(
          hour: int.tryParse(partes[0]) ?? 8,
          minute: int.tryParse(partes[1]) ?? 0,
        );
      }
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    dosisController.dispose();

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
    if (nombreController.text.trim().isEmpty ||
        dosisController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      guardando = true;
    });

    final horaTexto =
        '${hora.hour.toString().padLeft(2, '0')}:'
        '${hora.minute.toString().padLeft(2, '0')}';

    try {
      if (widget.medicamento == null) {
        await service.agregar(
          nombre: nombreController.text,
          dosis: dosisController.text,
          hora: horaTexto,
          frecuencia: frecuencia,
        );
      } else {
        await service.actualizar(
          id: widget.medicamento!.id,
          nombre: nombreController.text,
          dosis: dosisController.text,
          hora: horaTexto,
          frecuencia: frecuencia,
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
              widget.medicamento == null
                  ? 'Nuevo medicamento'
                  : 'Editar medicamento',

              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 25),

            TextField(
              controller: nombreController,

              decoration: const InputDecoration(
                labelText: 'Medicamento',
                prefixIcon: Icon(Icons.medication_outlined),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: dosisController,

              decoration: const InputDecoration(
                labelText: 'Dosis',
                hintText: 'Ej. 500 mg',
              ),
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              initialValue: frecuencia,

              decoration: const InputDecoration(labelText: 'Frecuencia'),

              items: const [
                DropdownMenuItem(value: 'Diario', child: Text('Diario')),

                DropdownMenuItem(
                  value: 'Cada 12 horas',
                  child: Text('Cada 12 horas'),
                ),

                DropdownMenuItem(
                  value: 'Cada 8 horas',
                  child: Text('Cada 8 horas'),
                ),

                DropdownMenuItem(
                  value: 'Según indicación',
                  child: Text('Según indicación'),
                ),
              ],

              onChanged: (value) {
                if (value != null) {
                  frecuencia = value;
                }
              },
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
                        ? const CircularProgressIndicator(color: Colors.white)
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
