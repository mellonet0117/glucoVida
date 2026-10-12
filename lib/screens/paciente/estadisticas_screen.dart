import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/glucosa_registro.dart';
import '../../services/glucosa_service.dart';

class EstadisticasScreen extends StatefulWidget {
  const EstadisticasScreen({super.key});

  @override
  State<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  final GlucosaService _service = GlucosaService();

  String periodo = '7 días';

  final List<String> periodos = ['Hoy', '7 días', '30 días'];

  List<GlucosaRegistro> filtrar(List<GlucosaRegistro> registros) {
    final ahora = DateTime.now();

    if (periodo == 'Hoy') {
      return registros.where((r) {
        return r.fechaHora.year == ahora.year &&
            r.fechaHora.month == ahora.month &&
            r.fechaHora.day == ahora.day;
      }).toList();
    }

    final dias = periodo == '7 días' ? 7 : 30;

    final limite = ahora.subtract(Duration(days: dias));

    return registros.where((r) {
      return r.fechaHora.isAfter(limite);
    }).toList();
  }

  double promedio(List<GlucosaRegistro> registros) {
    if (registros.isEmpty) return 0;

    final suma = registros.fold<int>(
      0,
      (total, registro) => total + registro.valor,
    );

    return suma / registros.length;
  }

  int minimo(List<GlucosaRegistro> registros) {
    if (registros.isEmpty) return 0;

    return registros.map((e) => e.valor).reduce((a, b) => a < b ? a : b);
  }

  int maximo(List<GlucosaRegistro> registros) {
    if (registros.isEmpty) return 0;

    return registros.map((e) => e.valor).reduce((a, b) => a > b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(title: const Text('Estadísticas')),

      body: StreamBuilder<List<GlucosaRegistro>>(
        stream: _service.obtenerRegistros(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final todos = snapshot.data ?? [];

          final registros = filtrar(todos);

          final prom = promedio(registros);

          final min = minimo(registros);

          final max = maximo(registros);

          return ListView(
            padding: const EdgeInsets.all(18),

            children: [
              const Text(
                'Resumen de glucosa',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Consulta el comportamiento de tus mediciones registradas.',
                style: TextStyle(color: AppColors.textSecondary),
              ),

              const SizedBox(height: 22),

              // ======================
              // PERIODOS
              // ======================
              Row(
                children: periodos.map((item) {
                  final seleccionado = periodo == item;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),

                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            periodo = item;
                          });
                        },

                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),

                          decoration: BoxDecoration(
                            gradient: seleccionado
                                ? AppColors.primaryGradient
                                : null,

                            color: seleccionado ? null : Colors.white,

                            borderRadius: BorderRadius.circular(10),
                          ),

                          child: Text(
                            item,
                            textAlign: TextAlign.center,

                            style: TextStyle(
                              color: seleccionado
                                  ? Colors.white
                                  : AppColors.textPrimary,

                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // ======================
              // TARJETAS
              // ======================
              Row(
                children: [
                  Expanded(
                    child: _tarjetaDato(
                      'PROMEDIO',
                      registros.isEmpty ? '--' : prom.round().toString(),
                      'mg/dL',
                      Icons.show_chart,
                      AppColors.primary,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _tarjetaDato(
                      'MEDICIONES',
                      registros.length.toString(),
                      '',
                      Icons.water_drop_outlined,
                      AppColors.accent,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _tarjetaDato(
                      'MÍNIMO',
                      registros.isEmpty ? '--' : min.toString(),
                      'mg/dL',
                      Icons.south_east_rounded,
                      AppColors.success,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _tarjetaDato(
                      'MÁXIMO',
                      registros.isEmpty ? '--' : max.toString(),
                      'mg/dL',
                      Icons.north_east_rounded,
                      AppColors.warning,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // ======================
              // GRÁFICA
              // ======================
              _grafica(registros),

              const SizedBox(height: 22),

              _ultimosRegistros(registros),

              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }

  Widget _tarjetaDato(
    String titulo,
    String valor,
    String unidad,
    IconData icono,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Text(
                titulo,

                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),

              Icon(icono, size: 18, color: color),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,

            children: [
              Text(
                valor,

                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              if (unidad.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 4),

                  child: Text(
                    unidad,

                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _grafica(List<GlucosaRegistro> registros) {
    if (registros.isEmpty) {
      return Container(
        height: 230,

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),

        child: const Center(
          child: Text(
            'No hay mediciones para este periodo.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final ordenados = [...registros]
      ..sort((a, b) => a.fechaHora.compareTo(b.fechaHora));

    final puntos = <FlSpot>[];

    for (int i = 0; i < ordenados.length; i++) {
      puntos.add(FlSpot(i.toDouble(), ordenados[i].valor.toDouble()));
    }

    final valores = ordenados.map((e) => e.valor.toDouble()).toList();

    double minY = valores.reduce((a, b) => a < b ? a : b) - 20;

    double maxY = valores.reduce((a, b) => a > b ? a : b) + 20;

    if (minY < 0) {
      minY = 0;
    }

    if (maxY <= minY) {
      maxY = minY + 40;
    }

    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Comportamiento de glucosa',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 3),

          Text(
            periodo,

            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 22),

          SizedBox(
            height: 240,

            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (ordenados.length - 1).toDouble(),

                minY: minY,
                maxY: maxY,

                gridData: FlGridData(show: true, drawVerticalLine: false),

                borderData: FlBorderData(show: false),

                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),

                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),

                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 38,

                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.round().toString(),

                          style: const TextStyle(
                            fontSize: 9,

                            color: AppColors.textMuted,
                          ),
                        );
                      },
                    ),
                  ),

                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,

                      interval: ordenados.length > 7 ? 2 : 1,

                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();

                        if (index < 0 || index >= ordenados.length) {
                          return const SizedBox();
                        }

                        final fecha = ordenados[index].fechaHora;

                        String texto;

                        if (periodo == 'Hoy') {
                          texto =
                              '${fecha.hour.toString().padLeft(2, '0')}:'
                              '${fecha.minute.toString().padLeft(2, '0')}';
                        } else {
                          texto = '${fecha.day}/${fecha.month}';
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),

                          child: Text(
                            texto,

                            style: const TextStyle(
                              fontSize: 8,

                              color: AppColors.textMuted,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                lineBarsData: [
                  LineChartBarData(
                    spots: puntos,

                    isCurved: true,

                    color: AppColors.primary,

                    barWidth: 3,

                    dotData: FlDotData(show: true),

                    belowBarData: BarAreaData(
                      show: true,

                      color: AppColors.primary.withValues(alpha: 0.10),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ultimosRegistros(List<GlucosaRegistro> registros) {
    if (registros.isEmpty) {
      return const SizedBox.shrink();
    }

    final recientes = registros.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(17),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Mediciones del periodo',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          ...recientes.map((registro) {
            final fecha = registro.fechaHora;

            return ListTile(
              contentPadding: EdgeInsets.zero,

              leading: Container(
                width: 42,
                height: 42,

                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),

                  borderRadius: BorderRadius.circular(11),
                ),

                child: const Icon(
                  Icons.water_drop_outlined,

                  color: AppColors.primary,
                ),
              ),

              title: Text(
                '${registro.valor} mg/dL',

                style: const TextStyle(fontWeight: FontWeight.w600),
              ),

              subtitle: Text(
                '${registro.momento} · '
                '${fecha.day.toString().padLeft(2, '0')}/'
                '${fecha.month.toString().padLeft(2, '0')}/'
                '${fecha.year}',

                style: const TextStyle(fontSize: 11),
              ),

              trailing: Text(
                '${fecha.hour.toString().padLeft(2, '0')}:'
                '${fecha.minute.toString().padLeft(2, '0')}',

                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
