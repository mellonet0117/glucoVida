import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'paciente_detalle_doctor.dart';

class MisPacientesScreen extends StatefulWidget {
  const MisPacientesScreen({super.key});

  @override
  State<MisPacientesScreen> createState() => _MisPacientesScreenState();
}

class _MisPacientesScreenState extends State<MisPacientesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _buscarController = TextEditingController();

  String busqueda = '';

  @override
  void dispose() {
    _buscarController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> obtenerPacientes() {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('usuarios')
        .where('doctorId', isEqualTo: usuario.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(title: const Text('Mis pacientes')),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: obtenerPacientes(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Text(
                  'No se pudieron cargar los pacientes.\n\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final todos = snapshot.data?.docs ?? [];

          final pacientes = todos.where((doc) {
            final datos = doc.data();

            final nombre =
                '${datos['nombre'] ?? ''} '
                        '${datos['apellidos'] ?? ''}'
                    .toLowerCase();

            final correo = (datos['correo'] ?? '').toString().toLowerCase();

            final texto = busqueda.toLowerCase().trim();

            if (texto.isEmpty) {
              return true;
            }

            return nombre.contains(texto) || correo.contains(texto);
          }).toList();

          return Column(
            children: [
              // =========================
              // CABECERA
              // =========================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'Pacientes asignados',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      todos.length == 1
                          ? 'Tienes 1 paciente asignado.'
                          : 'Tienes ${todos.length} pacientes asignados.',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),

                    const SizedBox(height: 18),

                    // =========================
                    // BUSCADOR
                    // =========================
                    TextField(
                      controller: _buscarController,

                      onChanged: (value) {
                        setState(() {
                          busqueda = value;
                        });
                      },

                      decoration: InputDecoration(
                        hintText: 'Buscar paciente...',

                        prefixIcon: const Icon(Icons.search),

                        suffixIcon: busqueda.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _buscarController.clear();

                                  setState(() {
                                    busqueda = '';
                                  });
                                },
                                icon: const Icon(Icons.close),
                              )
                            : null,

                        filled: true,
                        fillColor: Colors.white,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),

                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // =========================
              // LISTADO
              // =========================
              Expanded(
                child: todos.isEmpty
                    ? _sinPacientes()
                    : pacientes.isEmpty
                    ? _sinResultados()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 25),

                        itemCount: pacientes.length,

                        itemBuilder: (context, index) {
                          final doc = pacientes[index];

                          return _tarjetaPaciente(doc.id, doc.data());
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _tarjetaPaciente(String pacienteId, Map<String, dynamic> datos) {
    final nombre = datos['nombre']?.toString() ?? '';

    final apellidos = datos['apellidos']?.toString() ?? '';

    final nombreCompleto = '$nombre $apellidos'.trim();

    final correo = datos['correo']?.toString() ?? '';

    final telefono = datos['telefono']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),

      child: InkWell(
        borderRadius: BorderRadius.circular(16),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PacienteDetalleDoctor(pacienteId: pacienteId),
            ),
          );
        },

        child: Padding(
          padding: const EdgeInsets.all(15),

          child: Row(
            children: [
              // FOTO / INICIAL

              CircleAvatar(
                radius: 29,

                backgroundColor: AppColors.primary.withValues(alpha: 0.12),

                child: Text(
                  nombre.isNotEmpty ? nombre[0].toUpperCase() : 'P',

                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      nombreCompleto.isEmpty ? 'Paciente' : nombreCompleto,

                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    if (correo.isNotEmpty) ...[
                      const SizedBox(height: 4),

                      Row(
                        children: [
                          const Icon(
                            Icons.mail_outline,
                            size: 14,
                            color: AppColors.textMuted,
                          ),

                          const SizedBox(width: 5),

                          Expanded(
                            child: Text(
                              correo,

                              overflow: TextOverflow.ellipsis,

                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (telefono.isNotEmpty) ...[
                      const SizedBox(height: 3),

                      Row(
                        children: [
                          const Icon(
                            Icons.phone_outlined,
                            size: 14,
                            color: AppColors.textMuted,
                          ),

                          const SizedBox(width: 5),

                          Text(
                            telefono,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),

                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: .08),

                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: const Text(
                        'Ver expediente',

                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sinPacientes() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(Icons.people_outline, size: 75, color: AppColors.textMuted),

            SizedBox(height: 15),

            Text(
              'No tienes pacientes asignados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),

            SizedBox(height: 6),

            Text(
              'Cuando el administrador te asigne pacientes, aparecerán aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sinResultados() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(Icons.search_off, size: 65, color: AppColors.textMuted),

            SizedBox(height: 12),

            Text(
              'No encontramos pacientes',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),

            SizedBox(height: 5),

            Text(
              'Prueba buscando por nombre o correo.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
