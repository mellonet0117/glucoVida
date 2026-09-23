import 'package:cloud_firestore/cloud_firestore.dart';

class GlucosaRegistro {
  final String id;
  final int valor;
  final String momento;
  final DateTime fechaHora;
  final String notas;

  const GlucosaRegistro({
    required this.id,
    required this.valor,
    required this.momento,
    required this.fechaHora,
    required this.notas,
  });

  factory GlucosaRegistro.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> documento,
  ) {
    final datos = documento.data()!;

    return GlucosaRegistro(
      id: documento.id,
      valor: datos['valor'] ?? 0,
      momento: datos['momento'] ?? 'Otro',
      fechaHora: (datos['fechaHora'] as Timestamp).toDate(),
      notas: datos['notas'] ?? '',
    );
  }
}
