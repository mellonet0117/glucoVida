import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración GlucoVida'),
        actions: [
          IconButton(
            onPressed: () {
              authService.cerrarSesion();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Panel administrativo',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          _opcion(Icons.people, 'Usuarios', 'Administrar cuentas del sistema'),

          _opcion(
            Icons.medical_services_outlined,
            'Doctores',
            'Administrar personal médico',
          ),

          _opcion(
            Icons.person_outline,
            'Pacientes',
            'Consultar pacientes registrados',
          ),

          _opcion(
            Icons.assignment_ind_outlined,
            'Asignaciones',
            'Asignar pacientes a doctores',
          ),

          _opcion(
            Icons.analytics_outlined,
            'Estadísticas',
            'Información general del sistema',
          ),

          _opcion(Icons.history, 'Bitácora', 'Actividad del sistema'),
        ],
      ),
    );
  }

  Widget _opcion(IconData icon, String titulo, String descripcion) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: Icon(icon, size: 32, color: const Color(0xFF00A99D)),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(descripcion),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
