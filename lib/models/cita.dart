import 'package:cloud_firestore/cloud_firestore.dart';

class Cita {
  final String id;
  final String pacienteId;
  final String doctorId;
  final DateTime fechaHora;
  final String motivo;
  final String estado;
  final String notasDoctor;

  const Cita({
    required this.id,
    required this.pacienteId,
    required this.doctorId,
    required this.fechaHora,
    required this.motivo,
    required this.estado,
    required this.notasDoctor,
  });

  factory Cita.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return Cita(
      id: doc.id,
      pacienteId: data['pacienteId'] ?? '',
      doctorId: data['doctorId'] ?? '',
      fechaHora: data['fechaHora'] is Timestamp
          ? (data['fechaHora'] as Timestamp).toDate()
          : DateTime.now(),
      motivo: data['motivo'] ?? '',
      estado: data['estado'] ?? 'pendiente',
      notasDoctor: data['notasDoctor'] ?? '',
    );
  }
}
