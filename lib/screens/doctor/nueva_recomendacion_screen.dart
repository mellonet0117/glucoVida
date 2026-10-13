import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../services/recomendacion_doctor_service.dart';

class NuevaRecomendacionScreen extends StatefulWidget {
  final String pacienteId;

  const NuevaRecomendacionScreen({super.key, required this.pacienteId});

  @override
  State<NuevaRecomendacionScreen> createState() =>
      _NuevaRecomendacionScreenState();
}

class _NuevaRecomendacionScreenState extends State<NuevaRecomendacionScreen> {
  final tituloController = TextEditingController();

  final descripcionController = TextEditingController();

  final RecomendacionDoctorService service = RecomendacionDoctorService();

  String tipo = 'General';

  bool guardando = false;

  @override
  void dispose() {
    tituloController.dispose();
    descripcionController.dispose();

    super.dispose();
  }

  Future<void> guardar() async {
    if (tituloController.text.trim().isEmpty ||
        descripcionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa título y recomendación.')),
      );

      return;
    }

    setState(() {
      guardando = true;
    });

    try {
      await service.crear(
        pacienteId: widget.pacienteId,

        tipo: tipo,

        titulo: tituloController.text,

        descripcion: descripcionController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Recomendación enviada.')));

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No se pudo enviar: $e')));
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
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(title: const Text('Nueva recomendación')),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [
          const Text(
            'Recomendación para el paciente',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          const Text(
            'Agrega indicaciones u observaciones para el seguimiento.',
            style: TextStyle(color: AppColors.textSecondary),
          ),

          const SizedBox(height: 25),

          DropdownButtonFormField<String>(
            initialValue: tipo,

            decoration: const InputDecoration(
              labelText: 'Tipo de recomendación',
            ),

            items: const [
              DropdownMenuItem(value: 'General', child: Text('General')),

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
                setState(() {
                  tipo = value;
                });
              }
            },
          ),

          const SizedBox(height: 17),

          TextField(
            controller: tituloController,

            decoration: const InputDecoration(
              labelText: 'Título',
              hintText: 'Ej. Actividad recomendada',
            ),
          ),

          const SizedBox(height: 17),

          TextField(
            controller: descripcionController,

            minLines: 5,
            maxLines: 8,

            decoration: const InputDecoration(
              labelText: 'Recomendación',

              hintText: 'Escribe las indicaciones para el paciente...',
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
                          'Enviar recomendación',

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
    );
  }
}
