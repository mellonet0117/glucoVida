import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'recomendaciones_paciente_doctor_screen.dart';

class RecomendacionesDoctorScreen extends StatefulWidget {
  const RecomendacionesDoctorScreen({super.key});

  @override
  State<RecomendacionesDoctorScreen> createState() =>
      _RecomendacionesDoctorScreenState();
}

class _RecomendacionesDoctorScreenState
    extends State<RecomendacionesDoctorScreen> {
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
    final doctor = _auth.currentUser;

    if (doctor == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('usuarios')
        .where('doctorId', isEqualTo: doctor.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(title: const Text('Recomendaciones')),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: obtenerPacientes(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'No se pudieron cargar los pacientes.\n'
                '${snapshot.error}',
                textAlign: TextAlign.center,
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

            final texto = busqueda.trim().toLowerCase();

            if (texto.isEmpty) {
              return true;
            }

            return nombre.contains(texto) || correo.contains(texto);
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(18),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'Recomendaciones médicas',

                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      'Selecciona un paciente para consultar o enviar recomendaciones.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),

                    const SizedBox(height: 18),

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

              Expanded(
                child: todos.isEmpty
                    ? const Center(
                        child: Text('No tienes pacientes asignados.'),
                      )
                    : pacientes.isEmpty
                    ? const Center(child: Text('No se encontraron pacientes.'))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 25),

                        itemCount: pacientes.length,

                        itemBuilder: (context, index) {
                          final doc = pacientes[index];

                          return _pacienteCard(doc.id, doc.data());
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _pacienteCard(String pacienteId, Map<String, dynamic> datos) {
    final nombre = datos['nombre']?.toString() ?? '';

    final apellidos = datos['apellidos']?.toString() ?? '';

    final nombreCompleto = '$nombre $apellidos'.trim();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),

      child: ListTile(
        contentPadding: const EdgeInsets.all(14),

        leading: CircleAvatar(
          radius: 27,

          backgroundColor: AppColors.primary.withValues(alpha: .12),

          child: Text(
            nombre.isNotEmpty ? nombre[0].toUpperCase() : 'P',

            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 19,
              color: AppColors.primary,
            ),
          ),
        ),

        title: Text(
          nombreCompleto.isEmpty ? 'Paciente' : nombreCompleto,

          style: const TextStyle(fontWeight: FontWeight.w600),
        ),

        subtitle: const Text(
          'Ver recomendaciones',

          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),

        trailing: const Icon(Icons.chevron_right),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RecomendacionesPacienteDoctorScreen(
                pacienteId: pacienteId,

                nombrePaciente: nombreCompleto,
              ),
            ),
          );
        },
      ),
    );
  }
}
