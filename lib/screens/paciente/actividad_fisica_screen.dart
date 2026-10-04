import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/recomendacion_ejercicio.dart';

class ActividadFisicaScreen extends StatefulWidget {
  const ActividadFisicaScreen({super.key});

  @override
  State<ActividadFisicaScreen> createState() => _ActividadFisicaScreenState();
}

class _ActividadFisicaScreenState extends State<ActividadFisicaScreen> {
  String categoriaSeleccionada = 'Todos';

  final List<String> categorias = ['Todos', 'Aeróbico', 'Fuerza', 'Movilidad'];

  final List<RecomendacionEjercicio> ejercicios = const [
    RecomendacionEjercicio(
      nombre: 'Caminata',
      categoria: 'Aeróbico',
      descripcion: 'Una actividad sencilla que puede formar parte de una rutina para mejorar la salud general y apoyar el control de la glucosa.',
      duracion: '10 - 30 min',
      intensidad: 'Suave a moderada',
      recomendaciones: [
        'Comienza a un ritmo cómodo',
        'Utiliza calzado adecuado',
        'Mantente hidratado',
        'Puedes aumentar el tiempo gradualmente',
      ],
      beneficios: [
        'Actividad cardiovascular',
        'Movimiento diario',
        'Bajo impacto',
      ],
      icono: '🚶',
    ),

    RecomendacionEjercicio(
      nombre: 'Bicicleta',
      categoria: 'Aeróbico',
      descripcion: 'La bicicleta permite realizar actividad cardiovascular con poco impacto sobre las articulaciones.',
      duracion: '15 - 30 min',
      intensidad: 'Suave a moderada',
      recomendaciones: [
        'Mantén un ritmo cómodo',
        'Evita comenzar con resistencia alta',
        'Usa casco si sales al exterior',
        'Descansa si sientes fatiga excesiva',
      ],
      beneficios: ['Cardiovascular', 'Piernas', 'Bajo impacto'],
      icono: '🚴',
    ),

    RecomendacionEjercicio(
      nombre: 'Baile',
      categoria: 'Aeróbico',
      descripcion: 'Una alternativa dinámica para mantenerse activo mediante movimientos continuos.',
      duracion: '10 - 30 min',
      intensidad: 'Suave a moderada',
      recomendaciones: [
        'Elige música y movimientos cómodos',
        'Realiza pausas cuando sea necesario',
        'Mantente hidratado',
      ],
      beneficios: ['Movimiento', 'Coordinación', 'Actividad cardiovascular'],
      icono: '💃',
    ),

    RecomendacionEjercicio(
      nombre: 'Natación',
      categoria: 'Aeróbico',
      descripcion: 'Actividad de bajo impacto que involucra diferentes grupos musculares.',
      duracion: '15 - 30 min',
      intensidad: 'Suave a moderada',
      recomendaciones: [
        'Comienza lentamente',
        'Realiza descansos entre vueltas',
        'Evita entrenar solo si no tienes experiencia',
      ],
      beneficios: ['Cuerpo completo', 'Bajo impacto', 'Cardiovascular'],
      icono: '🏊',
    ),

    RecomendacionEjercicio(
      nombre: 'Sentarse y levantarse',
      categoria: 'Fuerza',
      descripcion: 'Ejercicio sencillo para trabajar piernas utilizando una silla estable.',
      duracion: '2 - 3 series',
      intensidad: 'Suave',
      recomendaciones: [
        'Utiliza una silla firme',
        'Realiza el movimiento lentamente',
        'Mantén los pies apoyados',
        'Detente si tienes dolor',
      ],
      beneficios: ['Piernas', 'Fuerza', 'Movilidad funcional'],
      icono: '🪑',
    ),

    RecomendacionEjercicio(
      nombre: 'Fuerza con peso ligero',
      categoria: 'Fuerza',
      descripcion: 'Ejercicios básicos con poco peso para trabajar distintos grupos musculares.',
      duracion: '15 - 25 min',
      intensidad: 'Suave',
      recomendaciones: [
        'Comienza con poco peso',
        'Cuida la técnica',
        'No contengas la respiración',
        'Descansa entre ejercicios',
      ],
      beneficios: ['Fuerza muscular', 'Movilidad', 'Condición física'],
      icono: '💪',
    ),

    RecomendacionEjercicio(
      nombre: 'Estiramientos suaves',
      categoria: 'Movilidad',
      descripcion: 'Movimientos suaves para mantener la movilidad y complementar otras actividades.',
      duracion: '5 - 15 min',
      intensidad: 'Suave',
      recomendaciones: [
        'No rebotes durante el estiramiento',
        'Mantén movimientos suaves',
        'No fuerces una articulación',
      ],
      beneficios: ['Movilidad', 'Flexibilidad', 'Recuperación'],
      icono: '🧘',
    ),
  ];

  List<RecomendacionEjercicio> get ejerciciosFiltrados {
    if (categoriaSeleccionada == 'Todos') {
      return ejercicios;
    }

    return ejercicios
        .where((ejercicio) => ejercicio.categoria == categoriaSeleccionada)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(title: const Text('Actividad física')),

      body: ListView(
        padding: const EdgeInsets.all(18),

        children: [
          const Text(
            'Mantente activo',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Explora actividades que pueden formar parte de un estilo de vida saludable.',
            style: TextStyle(color: AppColors.textSecondary),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(14),

            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),

              borderRadius: BorderRadius.circular(14),
            ),

            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Icon(Icons.info_outline, color: AppColors.warning),

                SizedBox(width: 10),

                Expanded(
                  child: Text(
                    'La actividad adecuada puede variar entre personas. Si tienes indicaciones médicas específicas, sigue las recomendaciones de tu profesional de salud.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          SizedBox(
            height: 42,

            child: ListView.separated(
              scrollDirection: Axis.horizontal,

              itemCount: categorias.length,

              separatorBuilder: (_, _) => const SizedBox(width: 8),

              itemBuilder: (context, index) {
                final categoria = categorias[index];

                final seleccionada = categoriaSeleccionada == categoria;

                return ChoiceChip(
                  label: Text(categoria),

                  selected: seleccionada,

                  selectedColor: AppColors.primary,

                  labelStyle: TextStyle(
                    color: seleccionada ? Colors.white : AppColors.textPrimary,

                    fontWeight: FontWeight.w500,
                  ),

                  onSelected: (_) {
                    setState(() {
                      categoriaSeleccionada = categoria;
                    });
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Ejercicios sugeridos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          ...ejerciciosFiltrados.map(
            (ejercicio) => _tarjetaEjercicio(context, ejercicio),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaEjercicio(
    BuildContext context,
    RecomendacionEjercicio ejercicio,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),

      child: InkWell(
        borderRadius: BorderRadius.circular(16),

        onTap: () {
          _mostrarDetalle(context, ejercicio);
        },

        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,

                alignment: Alignment.center,

                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),

                  borderRadius: BorderRadius.circular(16),
                ),

                child: Text(
                  ejercicio.icono,

                  style: const TextStyle(fontSize: 31),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      ejercicio.nombre,

                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      ejercicio.descripcion,

                      maxLines: 2,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 14,
                          color: AppColors.primary,
                        ),

                        const SizedBox(width: 4),

                        Text(
                          ejercicio.duracion,

                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDetalle(BuildContext context, RecomendacionEjercicio ejercicio) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,

      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.78,
          minChildSize: 0.55,
          maxChildSize: 0.92,
          expand: false,

          builder: (context, controller) {
            return Padding(
              padding: const EdgeInsets.all(22),

              child: ListView(
                controller: controller,

                children: [
                  Center(
                    child: Text(
                      ejercicio.icono,

                      style: const TextStyle(fontSize: 70),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    ejercicio.nombre,

                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    ejercicio.descripcion,

                    textAlign: TextAlign.center,

                    style: const TextStyle(color: AppColors.textSecondary),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: _datoDetalle(
                          Icons.schedule,
                          'Duración',
                          ejercicio.duracion,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _datoDetalle(
                          Icons.speed,
                          'Intensidad',
                          ejercicio.intensidad,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    'Cómo realizarlo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  ...ejercicio.recomendaciones.map(
                    (recomendacion) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,

                      leading: const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.primary,
                        size: 20,
                      ),

                      title: Text(recomendacion),
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    'Características',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,

                    children: ejercicio.beneficios
                        .map(
                          (beneficio) => Chip(
                            label: Text(beneficio),

                            backgroundColor: const Color(0xFFF0FDFA),
                          ),
                        )
                        .toList(),
                  ),

                  const SizedBox(height: 25),

                  Container(
                    padding: const EdgeInsets.all(14),

                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),

                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Icon(
                          Icons.health_and_safety_outlined,
                          color: AppColors.warning,
                        ),

                        SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            'Detén la actividad si presentas mareo, debilidad, dolor u otro malestar. Las recomendaciones personalizadas deben ser indicadas por un profesional de salud.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _datoDetalle(IconData icono, String titulo, String valor) {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: const Color(0xFFF0FDFA),

        borderRadius: BorderRadius.circular(13),
      ),

      child: Column(
        children: [
          Icon(icono, color: AppColors.primary),

          const SizedBox(height: 6),

          Text(
            titulo,

            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            valor,

            textAlign: TextAlign.center,

            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
