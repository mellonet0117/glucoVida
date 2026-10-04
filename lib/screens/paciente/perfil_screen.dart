import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      return const Scaffold(body: Center(child: Text('No hay sesión activa')));
    }

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(title: const Text('Mi perfil')),

      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection('usuarios')
            .doc(usuario.uid)
            .get(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final datos = snapshot.data!.data() ?? {};

          final nombre = datos['nombre'] ?? '';

          final apellidos = datos['apellidos'] ?? '';

          final correo = datos['correo'] ?? usuario.email ?? '';

          return ListView(
            padding: const EdgeInsets.all(20),

            children: [
              const Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.person, size: 55, color: Colors.white),
                ),
              ),

              const SizedBox(height: 25),

              _dato('Nombre', nombre, Icons.person_outline),

              _dato('Apellidos', apellidos, Icons.badge_outlined),

              _dato('Correo electrónico', correo, Icons.email_outlined),

              _dato(
                'Tipo de cuenta',
                'Paciente',
                Icons.health_and_safety_outlined,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _dato(String titulo, String valor, IconData icono) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icono, color: AppColors.primary),
        title: Text(titulo),
        subtitle: Text(valor.isEmpty ? 'Sin información' : valor),
      ),
    );
  }
}
