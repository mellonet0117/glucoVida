class RecomendacionEjercicio {
  final String nombre;
  final String categoria;
  final String descripcion;
  final String duracion;
  final String intensidad;
  final List<String> recomendaciones;
  final List<String> beneficios;
  final String icono;

  const RecomendacionEjercicio({
    required this.nombre,
    required this.categoria,
    required this.descripcion,
    required this.duracion,
    required this.intensidad,
    required this.recomendaciones,
    required this.beneficios,
    required this.icono,
  });
}
