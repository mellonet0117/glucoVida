import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final nombreController = TextEditingController();

  final apellidosController = TextEditingController();

  final telefonoController = TextEditingController();

  final emergenciaController = TextEditingController();

  DateTime? fechaNacimiento;

  String correo = '';
  String rol = '';

  bool cargando = true;
  bool guardando = false;
  bool editando = false;

  @override
  void initState() {
    super.initState();
    cargarPerfil();
  }

  @override
  void dispose() {
    nombreController.dispose();
    apellidosController.dispose();
    telefonoController.dispose();
    emergenciaController.dispose();

    super.dispose();
  }

  Future<void> cargarPerfil() async {
    final usuario = _auth.currentUser;

    if (usuario == null) return;

    try {
      final doc = await _firestore
          .collection('usuarios')
          .doc(usuario.uid)
          .get();

      if (!doc.exists) return;

      final datos = doc.data()!;

      nombreController.text = datos['nombre'] ?? '';

      apellidosController.text = datos['apellidos'] ?? '';

      telefonoController.text = datos['telefono'] ?? '';

      emergenciaController.text = datos['contactoEmergencia'] ?? '';

      correo = datos['correo'] ?? usuario.email ?? '';

      rol = datos['rol'] ?? 'paciente';

      if (datos['fechaNacimiento'] is Timestamp) {
        fechaNacimiento = (datos['fechaNacimiento'] as Timestamp).toDate();
      }
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  Future<void> seleccionarFecha() async {
    final hoy = DateTime.now();

    final resultado = await showDatePicker(
      context: context,

      initialDate: fechaNacimiento ?? DateTime(hoy.year - 20),

      firstDate: DateTime(1920),

      lastDate: hoy,
    );

    if (resultado == null) return;

    setState(() {
      fechaNacimiento = resultado;
    });
  }

  Future<void> guardarPerfil() async {
    final usuario = _auth.currentUser;

    if (usuario == null) return;

    if (nombreController.text.trim().isEmpty) {
      mostrarMensaje('El nombre es obligatorio.');

      return;
    }

    setState(() {
      guardando = true;
    });

    try {
      final nombreCompleto =
          '${nombreController.text.trim()} '
                  '${apellidosController.text.trim()}'
              .trim();

      await _firestore.collection('usuarios').doc(usuario.uid).update({
        'nombre': nombreController.text.trim(),

        'apellidos': apellidosController.text.trim(),

        'nombreCompleto': nombreCompleto,

        'telefono': telefonoController.text.trim(),

        'contactoEmergencia': emergenciaController.text.trim(),

        'fechaNacimiento': fechaNacimiento != null
            ? Timestamp.fromDate(fechaNacimiento!)
            : null,

        'fechaActualizacion': FieldValue.serverTimestamp(),
      });

      await usuario.updateDisplayName(nombreCompleto);

      if (!mounted) return;

      setState(() {
        editando = false;
      });

      mostrarMensaje('Perfil actualizado correctamente.');
    } catch (e) {
      mostrarMensaje('No se pudo actualizar el perfil.');
    } finally {
      if (mounted) {
        setState(() {
          guardando = false;
        });
      }
    }
  }

  void mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), behavior: SnackBarBehavior.floating),
    );
  }

  String mostrarFecha() {
    if (fechaNacimiento == null) {
      return 'Seleccionar fecha';
    }

    return '${fechaNacimiento!.day.toString().padLeft(2, '0')}/'
        '${fechaNacimiento!.month.toString().padLeft(2, '0')}/'
        '${fechaNacimiento!.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text('Mi perfil'),

        actions: [
          if (!editando)
            IconButton(
              tooltip: 'Editar perfil',

              onPressed: () {
                setState(() {
                  editando = true;
                });
              },

              icon: const Icon(Icons.edit_outlined),
            ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [
          Center(
            child: Container(
              width: 100,
              height: 100,

              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,

                shape: BoxShape.circle,
              ),

              child: Center(
                child: Text(
                  nombreController.text.isEmpty
                      ? 'P'
                      : nombreController.text[0].toUpperCase(),

                  style: const TextStyle(
                    fontSize: 42,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          Text(
            '${nombreController.text} '
                    '${apellidosController.text}'
                .trim(),

            textAlign: TextAlign.center,

            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 4),

          Text(
            correo,

            textAlign: TextAlign.center,

            style: const TextStyle(color: AppColors.textSecondary),
          ),

          const SizedBox(height: 28),

          _campo(
            titulo: 'Nombre',
            controller: nombreController,
            icono: Icons.person_outline,
          ),

          _campo(
            titulo: 'Apellidos',
            controller: apellidosController,
            icono: Icons.badge_outlined,
          ),

          _campo(
            titulo: 'Teléfono',
            controller: telefonoController,
            icono: Icons.phone_outlined,
            teclado: TextInputType.phone,
          ),

          const SizedBox(height: 4),

          const Text(
            'Fecha de nacimiento',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 7),

          InkWell(
            onTap: editando ? seleccionarFecha : null,

            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(12),

                border: Border.all(color: AppColors.border),
              ),

              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month_outlined,

                    color: AppColors.primary,
                  ),

                  const SizedBox(width: 12),

                  Text(mostrarFecha()),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          _campo(
            titulo: 'Contacto de emergencia',

            controller: emergenciaController,

            icono: Icons.emergency_outlined,

            teclado: TextInputType.phone,
          ),

          const SizedBox(height: 10),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.verified_user_outlined,
                color: AppColors.primary,
              ),

              title: const Text('Tipo de cuenta'),

              subtitle: Text(rol == 'paciente' ? 'Paciente' : rol),
            ),
          ),

          if (editando) ...[
            const SizedBox(height: 20),

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

                  onTap: guardando ? null : guardarPerfil,

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
                            'Guardar cambios',

                            style: TextStyle(
                              color: Colors.white,

                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            TextButton(
              onPressed: () {
                setState(() {
                  editando = false;
                });

                cargarPerfil();
              },

              child: const Text('Cancelar'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _campo({
    required String titulo,
    required TextEditingController controller,
    required IconData icono,
    TextInputType? teclado,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            titulo,

            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 7),

          TextField(
            controller: controller,
            enabled: editando,
            keyboardType: teclado,

            decoration: InputDecoration(
              prefixIcon: Icon(icono, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
