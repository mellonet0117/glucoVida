import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../services/glucosa_service.dart';

class RegistrarGlucosaScreen extends StatefulWidget {
  const RegistrarGlucosaScreen({super.key});

  @override
  State<RegistrarGlucosaScreen> createState() => _RegistrarGlucosaScreenState();
}

class _RegistrarGlucosaScreenState extends State<RegistrarGlucosaScreen> {
  final valorController = TextEditingController();

  final notasController = TextEditingController();

  final GlucosaService _glucosaService = GlucosaService();

  String momento = 'En ayunas';

  DateTime fechaHora = DateTime.now();

  bool guardando = false;

  final List<String> momentos = [
    'En ayunas',
    'Antes del desayuno',
    'Después del desayuno',
    'Antes de comer',
    'Después de comer',
    'Antes de cenar',
    'Después de cenar',
    'Antes de dormir',
    'Otro',
  ];

  @override
  void dispose() {
    valorController.dispose();
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

    if (fecha == null || !mounted) return;

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
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(fechaHora),
    );

    if (hora == null || !mounted) return;

    setState(() {
      fechaHora = DateTime(
        fechaHora.year,
        fechaHora.month,
        fechaHora.day,
        hora.hour,
        hora.minute,
      );
    });
  }

  Future<void> guardar() async {
    final valor = int.tryParse(valorController.text);

    if (valor == null) {
      mostrarMensaje('Ingresa un nivel de glucosa válido.');

      return;
    }

    if (valor < 20 || valor > 600) {
      mostrarMensaje('El valor debe estar entre 20 y 600 mg/dL.');

      return;
    }

    setState(() {
      guardando = true;
    });

    try {
      await _glucosaService.registrar(
        valor: valor,
        momento: momento,
        fechaHora: fechaHora,
        notas: notasController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Glucosa registrada correctamente'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      mostrarMensaje('No se pudo guardar: $e');
    } finally {
      if (mounted) {
        setState(() {
          guardando = false;
        });
      }
    }
  }

  void mostrarMensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(title: const Text('Registrar glucosa')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            const Text(
              'Nueva medición',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'Registra tu nivel de glucosa.',
              style: TextStyle(color: AppColors.textSecondary),
            ),

            const SizedBox(height: 28),

            Container(
              padding: const EdgeInsets.all(22),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(18),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,

                children: [
                  const Text(
                    'Nivel de glucosa',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: valorController,

                    keyboardType: TextInputType.number,

                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),

                    decoration: const InputDecoration(
                      hintText: '105',

                      suffixText: 'mg/dL',

                      prefixIcon: Icon(Icons.water_drop_outlined),
                    ),
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    'Momento de la medición',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    initialValue: momento,

                    items: momentos
                        .map(
                          (item) =>
                              DropdownMenuItem(value: item, child: Text(item)),
                        )
                        .toList(),

                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        momento = value;
                      });
                    },
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    'Fecha y hora',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 10),

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

                  const SizedBox(height: 22),

                  const Text(
                    'Notas',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: notasController,

                    maxLines: 3,

                    decoration: const InputDecoration(
                      hintText: 'Agrega alguna observación...',
                    ),
                  ),

                  const SizedBox(height: 28),

                  Container(
                    height: 53,

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
                                  'Guardar medición',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
