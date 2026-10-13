import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class PerfilDoctorScreen extends StatefulWidget {
  const PerfilDoctorScreen({super.key});

  @override
  State<PerfilDoctorScreen> createState() => _PerfilDoctorScreenState();
}

class _PerfilDoctorScreenState extends State<PerfilDoctorScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final nombreController = TextEditingController();
  final apellidosController = TextEditingController();
  final telefonoController = TextEditingController();
  final especialidadController = TextEditingController();
  final cedulaController = TextEditingController();

  String correo = '';

  bool cargando = true;
  bool editando = false;
  bool guardando = false;

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
    especialidadController.dispose();
    cedulaController.dispose();

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

      final datos = doc.data();

      if (datos == null) return;

      nombreController.text = datos['nombre'] ?? '';

      apellidosController.text = datos['apellidos'] ?? '';

      telefonoController.text = datos['telefono'] ?? '';

      especialidadController.text = datos['especialidad'] ?? '';

      cedulaController.text = datos['cedulaProfesional'] ?? '';

      correo = datos['correo'] ?? usuario.email ?? '';
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
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

        'especialidad': especialidadController.text.trim(),

        'cedulaProfesional': cedulaController.text.trim(),

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
              width: 105,
              height: 105,

              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),

              child: Center(
                child: Text(
                  nombreController.text.isNotEmpty
                      ? nombreController.text[0].toUpperCase()
                      : 'D',

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 43,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          Text(
            'Dr. ${nombreController.text} '
                    '${apellidosController.text}'
                .trim(),

            textAlign: TextAlign.center,

            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            correo,

            textAlign: TextAlign.center,

            style: const TextStyle(color: AppColors.textSecondary),
          ),

          if (especialidadController.text.isNotEmpty) ...[
            const SizedBox(height: 4),

            Text(
              especialidadController.text,

              textAlign: TextAlign.center,

              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],

          const SizedBox(height: 30),

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

          _campo(
            titulo: 'Especialidad',
            controller: especialidadController,
            icono: Icons.medical_services_outlined,
            hint: 'Ej. Medicina general',
          ),

          _campo(
            titulo: 'Cédula profesional',
            controller: cedulaController,
            icono: Icons.workspace_premium_outlined,
            hint: 'Ej. 12345678',
          ),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.verified_user_outlined,
                color: AppColors.primary,
              ),

              title: const Text('Tipo de cuenta'),

              subtitle: const Text('Doctor'),
            ),
          ),

          if (editando) ...[
            const SizedBox(height: 22),

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
                            width: 23,
                            height: 23,

                            child: CircularProgressIndicator(
                              strokeWidth: 2,
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

            const SizedBox(height: 8),

            TextButton(
              onPressed: () async {
                setState(() {
                  editando = false;
                  cargando = true;
                });

                await cargarPerfil();
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
    String? hint,
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
              hintText: hint,

              prefixIcon: Icon(icono, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
