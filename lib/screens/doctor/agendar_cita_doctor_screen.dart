import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../services/cita_service.dart';

class AgendarCitaDoctorScreen extends StatefulWidget {
  final String pacienteId;
  final String nombrePaciente;

  const AgendarCitaDoctorScreen({
    super.key,
    required this.pacienteId,
    required this.nombrePaciente,
  });

  @override
  State<AgendarCitaDoctorScreen> createState() =>
      _AgendarCitaDoctorScreenState();
}

class _AgendarCitaDoctorScreenState extends State<AgendarCitaDoctorScreen> {
  final CitaService _service = CitaService();

  final TextEditingController _motivoController = TextEditingController();

  final TextEditingController _notasController = TextEditingController();

  DateTime fecha = DateTime.now().add(const Duration(days: 1));

  TimeOfDay hora = const TimeOfDay(hour: 10, minute: 0);

  bool guardando = false;

  @override
  void dispose() {
    _motivoController.dispose();
    _notasController.dispose();

    super.dispose();
  }

  Future<void> seleccionarFecha() async {
    final resultado = await showDatePicker(
      context: context,
      initialDate: fecha,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (resultado == null) return;

    setState(() {
      fecha = resultado;
    });
  }

  Future<void> seleccionarHora() async {
    final resultado = await showTimePicker(context: context, initialTime: hora);

    if (resultado == null) return;

    setState(() {
      hora = resultado;
    });
  }

  Future<void> guardar() async {
    if (_motivoController.text.trim().isEmpty) {
      _mensaje('Escribe el motivo de la cita.');
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
      _mensaje('Selecciona una fecha y hora futuras.');
      return;
    }

    setState(() {
      guardando = true;
    });

    try {
      await _service.crearCitaDoctor(
        pacienteId: widget.pacienteId,
        fechaHora: fechaHora,
        motivo: _motivoController.text,
        notas: _notasController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cita agendada correctamente.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (e, stackTrace) {
      debugPrint('ERROR AL CREAR CITA: $e');

      debugPrint('$stackTrace');

      if (!mounted) return;

      _mensaje('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          guardando = false;
        });
      }
    }
  }

  void _mensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), behavior: SnackBarBehavior.floating),
    );
  }

  String _fechaTexto() {
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
  }

  String _horaTexto() {
    return '${hora.hour.toString().padLeft(2, '0')}:'
        '${hora.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(title: const Text('Agendar cita')),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // =========================
          // PACIENTE
          // =========================

          Container(
            padding: const EdgeInsets.all(18),

            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,

              borderRadius: BorderRadius.circular(20),

              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: .20),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),

            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,

                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .18),
                    shape: BoxShape.circle,
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
                        'Nueva cita para',

                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        widget.nombrePaciente.isEmpty
                            ? 'Paciente'
                            : widget.nombrePaciente,

                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            'Información de la cita',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: _motivoController,

            decoration: const InputDecoration(
              labelText: 'Motivo de la cita',

              hintText: 'Ej. Revisión de seguimiento',

              prefixIcon: Icon(
                Icons.medical_information_outlined,
                color: AppColors.primary,
              ),
            ),
          ),

          const SizedBox(height: 18),

          // =========================
          // FECHA / HORA
          // =========================
          Row(
            children: [
              Expanded(
                child: _selector(
                  icono: Icons.calendar_today_outlined,

                  titulo: 'Fecha',

                  valor: _fechaTexto(),

                  onTap: seleccionarFecha,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _selector(
                  icono: Icons.schedule,

                  titulo: 'Hora',

                  valor: _horaTexto(),

                  onTap: seleccionarHora,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          TextField(
            controller: _notasController,

            minLines: 3,
            maxLines: 5,

            decoration: const InputDecoration(
              labelText: 'Observaciones',

              hintText: 'Indicaciones adicionales para la cita...',

              alignLabelWithHint: true,

              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 55),

                child: Icon(
                  Icons.description_outlined,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // =========================
          // RESUMEN
          // =========================
          Container(
            padding: const EdgeInsets.all(17),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.circular(17),

              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.event_available_outlined,
                      color: AppColors.primary,
                    ),

                    SizedBox(width: 8),

                    Text(
                      'Resumen',

                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                _resumen('Paciente', widget.nombrePaciente),

                _resumen('Fecha', _fechaTexto()),

                _resumen('Hora', _horaTexto()),

                _resumen('Estado', 'Confirmada', ultimo: true),
              ],
            ),
          ),

          const SizedBox(height: 27),

          // =========================
          // BOTÓN
          // =========================
          Container(
            height: 54,

            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,

              borderRadius: BorderRadius.circular(14),

              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: .18),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),

            child: Material(
              color: Colors.transparent,

              child: InkWell(
                borderRadius: BorderRadius.circular(14),

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
                            Icon(Icons.event_available, color: Colors.white),

                            SizedBox(width: 8),

                            Text(
                              'Agendar cita',

                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 25),
        ],
      ),
    );
  }

  Widget _selector({
    required IconData icono,
    required String titulo,
    required String valor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,

      borderRadius: BorderRadius.circular(15),

      child: InkWell(
        borderRadius: BorderRadius.circular(15),

        onTap: onTap,

        child: Container(
          padding: const EdgeInsets.all(15),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),

            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                children: [
                  Icon(icono, size: 18, color: AppColors.primary),

                  const SizedBox(width: 6),

                  Text(
                    titulo,

                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                valor,

                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resumen(String titulo, String valor, {bool ultimo = false}) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                titulo,

                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),

            Text(
              valor.isEmpty ? 'Paciente' : valor,

              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),

        if (!ultimo) ...[
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
