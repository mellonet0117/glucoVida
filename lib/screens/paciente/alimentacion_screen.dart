import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/recomendacion_alimentacion.dart';

class AlimentacionScreen extends StatefulWidget {
  const AlimentacionScreen({super.key});

  @override
  State<AlimentacionScreen> createState() => _AlimentacionScreenState();
}

class _AlimentacionScreenState extends State<AlimentacionScreen> {
  String categoriaSeleccionada = 'Todos';

  final List<String> categorias = [
    'Todos',
    'Desayuno',
    'Comida',
    'Cena',
    'Colación',
  ];

  final List<RecomendacionAlimentacion> recomendaciones = const [
    RecomendacionAlimentacion(
      nombre: 'Avena con fresas y nueces',
      categoria: 'Desayuno',
      descripcion:
          'Una opción con avena natural, fruta entera y grasas saludables.',
      ingredientes: [
        'Avena natural',
        'Fresas',
        'Nueces',
        'Canela',
        'Leche o bebida sin azúcar añadida',
      ],
      beneficios: ['Fuente de fibra', 'Fruta entera', 'Sin azúcar añadida'],
      icono: '🥣',
    ),

    RecomendacionAlimentacion(
      nombre: 'Huevos con verduras',
      categoria: 'Desayuno',
      descripcion: 'Desayuno con proteína y verduras que puede acompañarse con una porción de cereal integral.',
      ingredientes: [
        'Huevos',
        'Espinaca',
        'Tomate',
        'Cebolla',
        'Tortilla integral o de maíz',
      ],
      beneficios: ['Proteína', 'Verduras', 'Opción baja en azúcar añadida'],
      icono: '🍳',
    ),

    RecomendacionAlimentacion(
      nombre: 'Pollo con ensalada',
      categoria: 'Comida',
      descripcion: 'Combinación de proteína magra con verduras frescas.',
      ingredientes: [
        'Pollo a la plancha',
        'Lechuga',
        'Pepino',
        'Tomate',
        'Aguacate',
      ],
      beneficios: ['Proteína', 'Verduras', 'Grasas saludables'],
      icono: '🥗',
    ),

    RecomendacionAlimentacion(
      nombre: 'Lentejas con verduras',
      categoria: 'Comida',
      descripcion: 'Las leguminosas aportan fibra y proteína vegetal.',
      ingredientes: ['Lentejas', 'Zanahoria', 'Tomate', 'Cebolla', 'Calabaza'],
      beneficios: ['Fibra', 'Proteína vegetal', 'Leguminosas'],
      icono: '🥘',
    ),

    RecomendacionAlimentacion(
      nombre: 'Pescado con verduras',
      categoria: 'Cena',
      descripcion: 'Cena sencilla con pescado y verduras cocidas o asadas.',
      ingredientes: ['Pescado', 'Brócoli', 'Calabaza', 'Pimiento', 'Limón'],
      beneficios: ['Proteína', 'Verduras', 'Cena ligera'],
      icono: '🐟',
    ),

    RecomendacionAlimentacion(
      nombre: 'Yogur natural con semillas',
      categoria: 'Colación',
      descripcion: 'Colación sencilla usando yogur natural sin azúcar añadida.',
      ingredientes: ['Yogur natural sin azúcar', 'Chía', 'Nueces', 'Fresas'],
      beneficios: ['Proteína', 'Semillas', 'Sin azúcar añadida'],
      icono: '🥛',
    ),

    RecomendacionAlimentacion(
      nombre: 'Manzana con nueces',
      categoria: 'Colación',
      descripcion: 'Fruta entera acompañada de una pequeña porción de nueces.',
      ingredientes: ['Manzana', 'Nueces o almendras'],
      beneficios: ['Fruta entera', 'Fibra', 'Grasas saludables'],
      icono: '🍎',
    ),
  ];

  List<RecomendacionAlimentacion> get recomendacionesFiltradas {
    if (categoriaSeleccionada == 'Todos') {
      return recomendaciones;
    }

    return recomendaciones
        .where((item) => item.categoria == categoriaSeleccionada)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(title: const Text('Alimentación')),

      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'Ideas para tu alimentación',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Explora opciones que pueden formar parte de una alimentación equilibrada.',
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
                    'Estas sugerencias son informativas. Las necesidades de alimentación pueden variar entre personas.',
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
            'Recomendaciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          ...recomendacionesFiltradas.map((recomendacion) {
            return _tarjeta(context, recomendacion);
          }),
        ],
      ),
    );
  }

  Widget _tarjeta(
    BuildContext context,
    RecomendacionAlimentacion recomendacion,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),

      child: InkWell(
        borderRadius: BorderRadius.circular(16),

        onTap: () {
          _mostrarDetalle(context, recomendacion);
        },

        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,

                alignment: Alignment.center,

                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),

                  borderRadius: BorderRadius.circular(15),
                ),

                child: Text(
                  recomendacion.icono,
                  style: const TextStyle(fontSize: 30),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      recomendacion.nombre,

                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      recomendacion.descripcion,

                      maxLines: 2,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),

                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),

                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Text(
                        recomendacion.categoria,

                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  void _mostrarDetalle(
    BuildContext context,
    RecomendacionAlimentacion recomendacion,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,

      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.55,
          maxChildSize: 0.92,
          expand: false,

          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(22),

              child: ListView(
                controller: scrollController,

                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,

                      decoration: BoxDecoration(
                        color: AppColors.border,

                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Center(
                    child: Text(
                      recomendacion.icono,
                      style: const TextStyle(fontSize: 65),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    recomendacion.nombre,

                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    recomendacion.descripcion,

                    textAlign: TextAlign.center,

                    style: const TextStyle(color: AppColors.textSecondary),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    'Ingredientes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  ...recomendacion.ingredientes.map(
                    (ingrediente) => ListTile(
                      dense: true,

                      contentPadding: EdgeInsets.zero,

                      leading: const Icon(
                        Icons.check_circle_outline,
                        size: 20,
                        color: AppColors.primary,
                      ),

                      title: Text(ingrediente),
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    'Características',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,

                    children: recomendacion.beneficios.map((beneficio) {
                      return Chip(
                        label: Text(beneficio),

                        backgroundColor: const Color(0xFFF0FDFA),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 25),

                  Container(
                    padding: const EdgeInsets.all(14),

                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),

                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: const Text(
                      'Para recomendaciones personalizadas considera las indicaciones de tu médico o profesional de nutrición.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
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
}
