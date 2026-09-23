import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/glucosa_registro.dart';
import '../../services/glucosa_service.dart';

class HistorialGlucosaScreen extends StatelessWidget {
  HistorialGlucosaScreen({super.key});

  final GlucosaService _service = GlucosaService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(title: const Text('Historial de glucosa')),

      body: StreamBuilder<List<GlucosaRegistro>>(
        stream: _service.obtenerRegistros(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final registros = snapshot.data ?? [];

          if (registros.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Icon(
                    Icons.water_drop_outlined,
                    size: 70,
                    color: AppColors.textMuted,
                  ),

                  SizedBox(height: 15),

                  Text(
                    'Todavía no tienes registros',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(18),

            itemCount: registros.length,

            itemBuilder: (context, index) {
              final registro = registros[index];

              return _tarjeta(context, registro);
            },
          );
        },
      ),
    );
  }

  Widget _tarjeta(BuildContext context, GlucosaRegistro registro) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,

              decoration: BoxDecoration(
                color: const Color(0xFFF0FDFA),

                borderRadius: BorderRadius.circular(14),
              ),

              child: const Icon(
                Icons.water_drop_rounded,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,

                    children: [
                      Text(
                        registro.valor.toString(),

                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 3),

                        child: Text(
                          'mg/dL',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),

                  Text(
                    registro.momento,

                    style: const TextStyle(color: AppColors.textSecondary),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    _fecha(registro.fechaHora),

                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            PopupMenuButton(
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
              ],

              onSelected: (value) async {
                if (value == 'eliminar') {
                  await _confirmarEliminar(context, registro);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmarEliminar(
    BuildContext context,
    GlucosaRegistro registro,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar registro'),

          content: const Text('¿Deseas eliminar esta medición?'),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancelar'),
            ),

            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    await _service.eliminar(registro.id);
  }

  String _fecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year} '
        '${fecha.hour.toString().padLeft(2, '0')}:'
        '${fecha.minute.toString().padLeft(2, '0')}';
  }
}
