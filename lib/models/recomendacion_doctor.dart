import 'package:cloud_firestore/cloud_firestore.dart';

class RecomendacionDoctor {
  final String id;
  final String doctorId;
  final String tipo;
  final String titulo;
  final String descripcion;
  final DateTime fecha;

  const RecomendacionDoctor({
    required this.id,
    required this.doctorId,
    required this.tipo,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
  });

  factory RecomendacionDoctor.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return RecomendacionDoctor(
      id: doc.id,
      doctorId: data['doctorId'] ?? '',
      tipo: data['tipo'] ?? 'General',
      titulo: data['titulo'] ?? '',
      descripcion: data['descripcion'] ?? '',
      fecha: data['fecha'] is Timestamp
          ? (data['fecha'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
