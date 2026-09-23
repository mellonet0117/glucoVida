import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

class DoctorDashboard extends StatelessWidget {
  const DoctorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('GlucoVida Médico'),
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
            'Panel médico',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          _opcion(
            Icons.people_outline,
            'Mis pacientes',
            'Consulta los pacientes asignados',
          ),

          _opcion(
            Icons.warning_amber,
            'Alertas',
            'Pacientes con registros importantes',
          ),

          _opcion(
            Icons.calendar_month,
            'Citas',
            'Consulta tus citas programadas',
          ),

          _opcion(
            Icons.note_alt_outlined,
            'Observaciones',
            'Seguimiento de pacientes',
          ),
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
