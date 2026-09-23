import 'package:cloud_firestore/cloud_firestore.dart';

class Medicamento {
  final String id;
  final String nombre;
  final String dosis;
  final String hora;
  final String frecuencia;
  final bool activo;
  final DateTime? ultimaToma;

  Medicamento({
    required this.id,
    required this.nombre,
    required this.dosis,
    required this.hora,
    required this.frecuencia,
    required this.activo,
    this.ultimaToma,
  });

  factory Medicamento.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return Medicamento(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      dosis: data['dosis'] ?? '',
      hora: data['hora'] ?? '',
      frecuencia: data['frecuencia'] ?? '',
      activo: data['activo'] ?? true,
      ultimaToma: data['ultimaToma'] != null
          ? (data['ultimaToma'] as Timestamp).toDate()
          : null,
    );
  }

  bool get tomadoHoy {
    if (ultimaToma == null) return false;

    final hoy = DateTime.now();

    return ultimaToma!.year == hoy.year &&
        ultimaToma!.month == hoy.month &&
        ultimaToma!.day == hoy.day;
  }
}
