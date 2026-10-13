import 'package:cloud_firestore/cloud_firestore.dart';

class Recordatorio {
  final String id;
  final int notificationId;
  final String tipo;
  final String titulo;
  final String descripcion;
  final String hora;
  final bool activo;

  const Recordatorio({
    required this.id,
    required this.notificationId,
    required this.tipo,
    required this.titulo,
    required this.descripcion,
    required this.hora,
    required this.activo,
  });

  factory Recordatorio.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return Recordatorio(
      id: doc.id,
      notificationId: data['notificationId'] ?? 0,
      tipo: data['tipo'] ?? 'Glucosa',
      titulo: data['titulo'] ?? '',
      descripcion: data['descripcion'] ?? '',
      hora: data['hora'] ?? '08:00',
      activo: data['activo'] ?? true,
    );
  }
}
