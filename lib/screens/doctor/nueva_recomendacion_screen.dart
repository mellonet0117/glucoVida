import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../services/recomendacion_doctor_service.dart';

class NuevaRecomendacionScreen extends StatefulWidget {
  final String pacienteId;
  final String? tipoInicial;

  const NuevaRecomendacionScreen({
    super.key,
    required this.pacienteId,
    this.tipoInicial,
  });

  @override
  State<NuevaRecomendacionScreen> createState() =>
      _NuevaRecomendacionScreenState();
}

class _NuevaRecomendacionScreenState extends State<NuevaRecomendacionScreen> {
  final RecomendacionDoctorService service = RecomendacionDoctorService();

  final tituloController = TextEditingController();

  final descripcionController = TextEditingController();

  final medicamentoController = TextEditingController();

  final dosisController = TextEditingController();

  final frecuenciaController = TextEditingController();

  final actividadController = TextEditingController();

  final duracionController = TextEditingController();

  String tipo = 'General';

  bool guardando = false;

  @override
  void initState() {
    super.initState();

    tipo = widget.tipoInicial ?? 'General';
  }

  @override
  void dispose() {
    tituloController.dispose();
    descripcionController.dispose();

    medicamentoController.dispose();
    dosisController.dispose();
    frecuenciaController.dispose();

    actividadController.dispose();
    duracionController.dispose();

    super.dispose();
  }

  Future<void> guardar() async {
    String titulo = '';
    String descripcion = '';
    Map<String, dynamic> detalles = {};

    // ======================================
    // MEDICAMENTO
    // ======================================

    if (tipo == 'Medicamento') {
      if (medicamentoController.text.trim().isEmpty ||
          dosisController.text.trim().isEmpty ||
          frecuenciaController.text.trim().isEmpty) {
        mensaje('Completa medicamento, dosis y frecuencia.');

        return;
      }

      titulo = medicamentoController.text.trim();

      descripcion = descripcionController.text.trim();

      detalles = {
        'medicamento': medicamentoController.text.trim(),

        'dosis': dosisController.text.trim(),

        'frecuencia': frecuenciaController.text.trim(),
      };
    }
    // ======================================
    // ACTIVIDAD FÍSICA
    // ======================================
    else if (tipo == 'Actividad física') {
      if (actividadController.text.trim().isEmpty ||
          duracionController.text.trim().isEmpty) {
        mensaje('Completa actividad y duración.');

        return;
      }

      titulo = actividadController.text.trim();

      descripcion = descripcionController.text.trim();

      detalles = {
        'actividad': actividadController.text.trim(),

        'duracion': duracionController.text.trim(),

        'frecuencia': frecuenciaController.text.trim(),
      };
    }
    // ======================================
    // OTROS
    // ======================================
    else {
      if (tituloController.text.trim().isEmpty ||
          descripcionController.text.trim().isEmpty) {
        mensaje('Completa título y recomendación.');

        return;
      }

      titulo = tituloController.text.trim();

      descripcion = descripcionController.text.trim();
    }

    setState(() {
      guardando = true;
    });

    try {
      await service.crear(
        pacienteId: widget.pacienteId,

        tipo: tipo,

        titulo: titulo,

        descripcion: descripcion,

        detalles: detalles,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recomendación enviada correctamente.')),
      );

      Navigator.pop(context);
    } catch (e) {
      mensaje('No se pudo enviar la recomendación.');
    } finally {
      if (mounted) {
        setState(() {
          guardando = false;
        });
      }
    }
  }

  void mensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(title: const Text('Nueva recomendación')),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [
          const Text(
            'Recomendación médica',

            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 5),

          const Text(
            'Selecciona el tipo de recomendación que deseas enviar.',
            style: TextStyle(color: AppColors.textSecondary),
          ),

          const SizedBox(height: 22),

          DropdownButtonFormField<String>(
            initialValue: tipo,

            decoration: const InputDecoration(
              labelText: 'Tipo de recomendación',

              prefixIcon: Icon(Icons.medical_information_outlined),
            ),

            items: const [
              DropdownMenuItem(
                value: 'Medicamento',
                child: Text('Medicamento'),
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

              DropdownMenuItem(value: 'General', child: Text('General')),
            ],

            onChanged: (value) {
              if (value == null) return;

              setState(() {
                tipo = value;
              });
            },
          ),

          const SizedBox(height: 20),

          // ==================================
          // MEDICAMENTO
          // ==================================
          if (tipo == 'Medicamento') ...[
            _campo(
              controller: medicamentoController,

              titulo: 'Medicamento',

              hint: 'Ej. Metformina',

              icono: Icons.medication_outlined,
            ),

            _campo(
              controller: dosisController,

              titulo: 'Dosis',

              hint: 'Ej. 500 mg',

              icono: Icons.science_outlined,
            ),

            _campo(
              controller: frecuenciaController,

              titulo: 'Frecuencia',

              hint: 'Ej. Cada 12 horas',

              icono: Icons.schedule,
            ),
          ],

          // ==================================
          // EJERCICIO
          // ==================================
          if (tipo == 'Actividad física') ...[
            _campo(
              controller: actividadController,

              titulo: 'Actividad',

              hint: 'Ej. Caminata',

              icono: Icons.directions_walk_outlined,
            ),

            _campo(
              controller: duracionController,

              titulo: 'Duración',

              hint: 'Ej. 30 minutos',

              icono: Icons.timer_outlined,
            ),

            _campo(
              controller: frecuenciaController,

              titulo: 'Frecuencia',

              hint: 'Ej. 5 días por semana',

              icono: Icons.calendar_month_outlined,
            ),
          ],

          // ==================================
          // ALIMENTACIÓN / SEGUIMIENTO / GENERAL
          // ==================================
          if (tipo != 'Medicamento' && tipo != 'Actividad física')
            _campo(
              controller: tituloController,

              titulo: tipo == 'Alimentación'
                  ? 'Recomendación alimentaria'
                  : 'Título',

              hint: tipo == 'Alimentación'
                  ? 'Ej. Mejorar distribución de alimentos'
                  : 'Ej. Seguimiento semanal',

              icono: tipo == 'Alimentación'
                  ? Icons.restaurant_outlined
                  : Icons.edit_note_outlined,
            ),

          const Text(
            'Indicaciones',

            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 7),

          TextField(
            controller: descripcionController,

            minLines: 4,
            maxLines: 7,

            decoration: InputDecoration(
              hintText: _hintIndicaciones(),

              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 75),

                child: Icon(
                  Icons.description_outlined,

                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 27),

          Container(
            height: 53,

            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,

              borderRadius: BorderRadius.circular(13),
            ),

            child: Material(
              color: Colors.transparent,

              child: InkWell(
                borderRadius: BorderRadius.circular(13),

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
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            Icon(Icons.send_outlined, color: Colors.white),

                            SizedBox(width: 8),

                            Text(
                              'Enviar recomendación',

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
          ),

          const SizedBox(height: 20),

          const Text(
            'La recomendación quedará registrada con el médico que la realizó.',
            textAlign: TextAlign.center,

            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String titulo,
    required String hint,
    required IconData icono,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),

      child: TextField(
        controller: controller,

        decoration: InputDecoration(
          labelText: titulo,
          hintText: hint,

          prefixIcon: Icon(icono, color: AppColors.primary),
        ),
      ),
    );
  }

  String _hintIndicaciones() {
    switch (tipo) {
      case 'Medicamento':
        return 'Escribe indicaciones adicionales sobre el medicamento.';

      case 'Actividad física':
        return 'Indicaciones o consideraciones para realizar la actividad.';

      case 'Alimentación':
        return 'Describe las recomendaciones de alimentación.';

      case 'Seguimiento':
        return 'Escribe las indicaciones para el seguimiento.';

      default:
        return 'Escribe la recomendación para el paciente.';
    }
  }
}
