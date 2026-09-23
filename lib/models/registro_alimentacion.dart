import 'package:cloud_firestore/cloud_firestore.dart';

class RegistroAlimentacion {
  final String id;
  final String tipo;
  final String alimentos;
  final String porcion;
  final String notas;
  final DateTime fechaHora;

  RegistroAlimentacion({
    required this.id,
    required this.tipo,
    required this.alimentos,
    required this.porcion,
    required this.notas,
    required this.fechaHora,
  });

  factory RegistroAlimentacion.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return RegistroAlimentacion(
      id: doc.id,
      tipo: data['tipo'] ?? '',
      alimentos: data['alimentos'] ?? '',
      porcion: data['porcion'] ?? '',
      notas: data['notas'] ?? '',
      fechaHora: (data['fechaHora'] as Timestamp).toDate(),
    );
  }
}
