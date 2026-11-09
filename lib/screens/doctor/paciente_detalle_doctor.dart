import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/glucosa_registro.dart';
import 'nueva_recomendacion_screen.dart';
import 'agendar_cita_doctor_screen.dart';

class PacienteDetalleDoctor extends StatelessWidget {
  final String pacienteId;

  const PacienteDetalleDoctor({super.key, required this.pacienteId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(title: const Text('Paciente')),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,

        foregroundColor: Colors.white,

        icon: const Icon(Icons.add_comment_outlined),

        label: const Text('Recomendar'),

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NuevaRecomendacionScreen(pacienteId: pacienteId),
            ),
          );
        },
      ),

      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection('usuarios')
            .doc(pacienteId)
            .get(),

        builder: (context, pacienteSnapshot) {
          // ==============================
          // CARGANDO
          // ==============================
          if (pacienteSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ==============================
          // ERROR FIREBASE
          // ==============================
          if (pacienteSnapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: AppColors.danger,
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      'No se pudo cargar el paciente',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      '${pacienteSnapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            );
          }

          // ==============================
          // DOCUMENTO NO EXISTE
          // ==============================
          if (!pacienteSnapshot.hasData || !pacienteSnapshot.data!.exists) {
            return const Center(
              child: Text('No se encontró la información del paciente.'),
            );
          }

          final paciente = pacienteSnapshot.data!.data();

          if (paciente == null) {
            return const Center(
              child: Text('El paciente no tiene información registrada.'),
            );
          }

          // ==============================
          // GLUCOSA DEL PACIENTE
          // ==============================
          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('usuarios')
                .doc(pacienteId)
                .collection('glucosa')
                .orderBy('fechaHora', descending: true)
                .snapshots(),

            builder: (context, glucosaSnapshot) {
              if (glucosaSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (glucosaSnapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'No se pudo cargar la glucosa:\n'
                      '${glucosaSnapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final registros =
                  glucosaSnapshot.data?.docs
                      .map(GlucosaRegistro.fromFirestore)
                      .toList() ??
                  [];

              final promedio = _promedio(registros);

              return ListView(
                padding: const EdgeInsets.all(18),

                children: [
                  // ==========================
                  // ENCABEZADO
                  // ==========================

                  _encabezado(paciente),

                  const SizedBox(height: 18),

                  // ==========================
                  // DATOS PERSONALES
                  // ==========================
                  const SizedBox(height: 20),

                  // ==========================
                  // GLUCOSA
                  // ==========================
                  Row(
                    children: [
                      Expanded(
                        child: _dato(
                          titulo: 'ÚLTIMA GLUCOSA',

                          valor: registros.isEmpty
                              ? '--'
                              : registros.first.valor.toString(),

                          unidad: 'mg/dL',

                          icono: Icons.water_drop_outlined,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _dato(
                          titulo: 'PROMEDIO',

                          valor: registros.isEmpty
                              ? '--'
                              : promedio.round().toString(),

                          unidad: 'mg/dL',

                          icono: Icons.show_chart,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ==========================
                  // ACCIONES DOCTOR
                  // ==========================
                  const Text(
                    'Acciones del doctor',

                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  _accionesDoctor(
                    context,
                    '${paciente['nombre'] ?? ''} '
                    '${paciente['apellidos'] ?? ''}',
                  ),

                  const SizedBox(height: 25),

                  _seccionMedicamentos(),

                  const SizedBox(height: 18),

                  _seccionProximasCitas(),

                  const SizedBox(height: 18),

                  _seccionRecomendaciones(),

                  const SizedBox(height: 25),

                  // ==========================
                  // HISTORIAL
                  // ==========================
                  const Text(
                    'Historial de glucosa',

                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  if (registros.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(25),

                        child: Center(
                          child: Text('El paciente aún no tiene mediciones.'),
                        ),
                      ),
                    )
                  else
                    ...registros.take(10).map(_registroGlucosa),

                  const SizedBox(height: 90),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _encabezado(Map<String, dynamic> paciente) {
    final nombre = paciente['nombre'] ?? '';

    final apellidos = paciente['apellidos'] ?? '';

    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        children: [
          CircleAvatar(
            radius: 34,

            backgroundColor: AppColors.primary,

            child: Text(
              nombre.isNotEmpty ? nombre[0].toUpperCase() : 'P',

              style: const TextStyle(
                fontSize: 27,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  '$nombre $apellidos'.trim(),

                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  paciente['correo'] ?? '',

                  style: const TextStyle(color: AppColors.textSecondary),
                ),

                if ((paciente['telefono'] ?? '').toString().isNotEmpty)
                  Text(
                    paciente['telefono'],

                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dato({
    required String titulo,
    required String valor,
    required String unidad,
    required IconData icono,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Text(
                titulo,

                style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),

              Icon(icono, size: 18, color: AppColors.primary),
            ],
          ),

          const SizedBox(height: 13),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,

            children: [
              Text(
                valor,

                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 4),

                child: Text(
                  unidad,

                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _registroGlucosa(GlucosaRegistro registro) {
    final fecha = registro.fechaHora;

    return Card(
      margin: const EdgeInsets.only(bottom: 9),

      child: ListTile(
        leading: const Icon(
          Icons.water_drop_outlined,
          color: AppColors.primary,
        ),

        title: Text(
          '${registro.valor} mg/dL',

          style: const TextStyle(fontWeight: FontWeight.w600),
        ),

        subtitle: Text(
          '${registro.momento}\n'
          '${fecha.day.toString().padLeft(2, '0')}/'
          '${fecha.month.toString().padLeft(2, '0')}/'
          '${fecha.year}',

          style: const TextStyle(fontSize: 11),
        ),

        trailing: Text(
          '${fecha.hour.toString().padLeft(2, '0')}:'
          '${fecha.minute.toString().padLeft(2, '0')}',

          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }

  double _promedio(List<GlucosaRegistro> registros) {
    if (registros.isEmpty) return 0;

    final suma = registros.fold<int>(
      0,
      (total, registro) => total + registro.valor,
    );

    return suma / registros.length;
  }

  Widget _accionesDoctor(BuildContext context, String nombrePaciente) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _botonAccion(
                icono: Icons.medication_outlined,

                titulo: 'Medicamento',

                onTap: () {
                  _abrirRecomendacion(context, 'Medicamento');
                },
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _botonAccion(
                icono: Icons.restaurant_outlined,

                titulo: 'Alimentación',

                onTap: () {
                  _abrirRecomendacion(context, 'Alimentación');
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _botonAccion(
                icono: Icons.directions_run_outlined,

                titulo: 'Ejercicio',

                onTap: () {
                  _abrirRecomendacion(context, 'Actividad física');
                },
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _botonAccion(
                icono: Icons.monitor_heart_outlined,

                titulo: 'Seguimiento',

                onTap: () {
                  _abrirRecomendacion(context, 'Seguimiento');
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        SizedBox(
          width: double.infinity,

          child: OutlinedButton.icon(
            onPressed: () {
              _abrirRecomendacion(context, 'General');
            },

            icon: const Icon(Icons.medical_information_outlined),

            label: const Text('Otra recomendación'),
          ),
        ),

        const SizedBox(height: 10),

        Container(
          width: double.infinity,
          height: 52,

          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,

            borderRadius: BorderRadius.circular(13),
          ),

          child: Material(
            color: Colors.transparent,

            child: InkWell(
              borderRadius: BorderRadius.circular(13),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AgendarCitaDoctorScreen(
                      pacienteId: pacienteId,

                      nombrePaciente: nombrePaciente.trim(),
                    ),
                  ),
                );
              },

              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Icon(Icons.calendar_month_outlined, color: Colors.white),

                  SizedBox(width: 8),

                  Text(
                    'Agendar cita',

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
      ],
    );
  }

  Widget _botonAccion({
    required IconData icono,
    required String titulo,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,

      borderRadius: BorderRadius.circular(15),

      child: InkWell(
        borderRadius: BorderRadius.circular(15),

        onTap: onTap,

        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),

            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),

          child: Column(
            children: [
              Container(
                width: 45,
                height: 45,

                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: .10),

                  borderRadius: BorderRadius.circular(12),
                ),

                child: Icon(icono, color: AppColors.primary),
              ),

              const SizedBox(height: 9),

              Text(
                titulo,

                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _abrirRecomendacion(BuildContext context, String tipo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            NuevaRecomendacionScreen(pacienteId: pacienteId, tipoInicial: tipo),
      ),
    );
  }

  Widget _seccionMedicamentos() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .doc(pacienteId)
          .collection('medicamentos')
          .snapshots(),

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _tarjetaVacia(
            icono: Icons.medication_outlined,
            titulo: 'Medicamentos actuales',
            mensaje: 'No se pudieron cargar.',
          );
        }

        final medicamentos =
            snapshot.data?.docs.where((doc) {
              final data = doc.data();

              return data['activo'] != false;
            }).toList() ??
            [];

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _tituloSeccion(
                icono: Icons.medication_outlined,
                titulo: 'Medicamentos actuales',
                cantidad: medicamentos.length,
              ),

              const SizedBox(height: 14),

              if (medicamentos.isEmpty)
                const Text(
                  'El paciente no tiene medicamentos registrados.',
                  style: TextStyle(color: AppColors.textSecondary),
                )
              else
                ...medicamentos.take(3).map((doc) {
                  final data = doc.data();

                  final nombre = data['nombre']?.toString() ?? 'Medicamento';

                  final dosis = data['dosis']?.toString() ?? '';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: .10),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.medication_liquid_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),

                        const SizedBox(width: 11),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nombre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              if (dosis.isNotEmpty)
                                Text(
                                  dosis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  Widget _seccionProximasCitas() {
    final doctorId = FirebaseAuth.instance.currentUser?.uid;

    if (doctorId == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('citas')
          .where('pacienteId', isEqualTo: pacienteId)
          .where('doctorId', isEqualTo: doctorId)
          .snapshots(),

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final ahora = DateTime.now();

        final citas =
            snapshot.data?.docs.where((doc) {
              final data = doc.data();

              final timestamp = data['fechaHora'];

              final estado = data['estado']?.toString() ?? '';

              if (timestamp is! Timestamp) {
                return false;
              }

              final fecha = timestamp.toDate();

              return fecha.isAfter(ahora) && estado != 'cancelada';
            }).toList() ??
            [];

        citas.sort((a, b) {
          final fechaA = (a.data()['fechaHora'] as Timestamp).toDate();

          final fechaB = (b.data()['fechaHora'] as Timestamp).toDate();

          return fechaA.compareTo(fechaB);
        });

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _tituloSeccion(
                icono: Icons.event_outlined,
                titulo: 'Próxima cita',
                cantidad: citas.length,
              ),

              const SizedBox(height: 14),

              if (citas.isEmpty)
                const Text(
                  'No hay citas próximas con este paciente.',
                  style: TextStyle(color: AppColors.textSecondary),
                )
              else
                Builder(
                  builder: (context) {
                    final data = citas.first.data();

                    final fecha = (data['fechaHora'] as Timestamp).toDate();

                    final motivo = data['motivo']?.toString() ?? 'Consulta';

                    return Row(
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: .10),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.calendar_month_outlined,
                            color: AppColors.primary,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                motivo,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 3),

                              Text(
                                '${fecha.day.toString().padLeft(2, '0')}/'
                                '${fecha.month.toString().padLeft(2, '0')}/'
                                '${fecha.year} · '
                                '${fecha.hour.toString().padLeft(2, '0')}:'
                                '${fecha.minute.toString().padLeft(2, '0')}',

                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _seccionRecomendaciones() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .doc(pacienteId)
          .collection('recomendaciones')
          .snapshots(),

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final recomendaciones = snapshot.data?.docs.toList() ?? [];

        recomendaciones.sort((a, b) {
          final fechaA = a.data()['fecha'];

          final fechaB = b.data()['fecha'];

          if (fechaA is! Timestamp || fechaB is! Timestamp) {
            return 0;
          }

          return fechaB.compareTo(fechaA);
        });

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _tituloSeccion(
                icono: Icons.medical_information_outlined,
                titulo: 'Recomendaciones recientes',
                cantidad: recomendaciones.length,
              ),

              const SizedBox(height: 14),

              if (recomendaciones.isEmpty)
                const Text(
                  'Todavía no hay recomendaciones.',
                  style: TextStyle(color: AppColors.textSecondary),
                )
              else
                ...recomendaciones.take(3).map((doc) {
                  final data = doc.data();

                  final titulo = data['titulo']?.toString() ?? 'Recomendación';

                  final tipo = data['tipo']?.toString() ?? 'General';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: AppColors.primary,
                          size: 21,
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                titulo,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              Text(
                                tipo,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  Widget _tituloSeccion({
    required IconData icono,
    required String titulo,
    required int cantidad,
  }) {
    return Row(
      children: [
        Icon(icono, color: AppColors.primary),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            titulo,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$cantidad',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  Widget _tarjetaVacia({
    required IconData icono,
    required String titulo,
    required String mensaje,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tituloSeccion(icono: icono, titulo: titulo, cantidad: 0),

          const SizedBox(height: 12),

          Text(mensaje, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
