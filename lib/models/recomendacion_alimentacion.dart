class RecomendacionAlimentacion {
  final String nombre;
  final String categoria;
  final String descripcion;
  final List<String> ingredientes;
  final List<String> beneficios;
  final String icono;

  const RecomendacionAlimentacion({
    required this.nombre,
    required this.categoria,
    required this.descripcion,
    required this.ingredientes,
    required this.beneficios,
    required this.icono,
  });
}
