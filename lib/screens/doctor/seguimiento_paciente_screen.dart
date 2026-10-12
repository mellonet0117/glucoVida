import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/glucosa_registro.dart';
import 'nueva_recomendacion_screen.dart';

class SeguimientoPacienteScreen extends StatefulWidget {
  final String pacienteId;
  final String nombrePaciente;

  const SeguimientoPacienteScreen({
    super.key,
    required this.pacienteId,
    required this.nombrePaciente,
  });

  @override
  State<SeguimientoPacienteScreen> createState() =>
      _SeguimientoPacienteScreenState();
}

class _SeguimientoPacienteScreenState extends State<SeguimientoPacienteScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String periodo = '7 días';

  Stream<List<GlucosaRegistro>> obtenerRegistros() {
    return _firestore
        .collection('usuarios')
        .doc(widget.pacienteId)
        .collection('glucosa')
        .orderBy('fechaHora', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(GlucosaRegistro.fromFirestore).toList(),
        );
  }

  List<GlucosaRegistro> filtrar(List<GlucosaRegistro> registros) {
    final ahora = DateTime.now();

    final dias = periodo == '7 días' ? 7 : 30;

    final limite = ahora.subtract(Duration(days: dias));

    return registros
        .where((registro) => registro.fechaHora.isAfter(limite))
        .toList();
  }

  double promedio(List<GlucosaRegistro> registros) {
    if (registros.isEmpty) {
      return 0;
    }

    final suma = registros.fold<int>(
      0,
      (total, registro) => total + registro.valor,
    );

    return suma / registros.length;
  }

  int minimo(List<GlucosaRegistro> registros) {
    if (registros.isEmpty) {
      return 0;
    }

    return registros.map((e) => e.valor).reduce((a, b) => a < b ? a : b);
  }

  int maximo(List<GlucosaRegistro> registros) {
    if (registros.isEmpty) {
      return 0;
    }

    return registros.map((e) => e.valor).reduce((a, b) => a > b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text('Seguimiento'),

        actions: [
          IconButton(
            tooltip: 'Enviar recomendación',

            icon: const Icon(Icons.add_comment_outlined),

            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      NuevaRecomendacionScreen(pacienteId: widget.pacienteId),
                ),
              );
            },
          ),
        ],
      ),

      body: StreamBuilder<List<GlucosaRegistro>>(
        stream: obtenerRegistros(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'No se pudo cargar el seguimiento.\n'
                '${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final todos = snapshot.data ?? [];

          final registros = filtrar(todos);

          final prom = promedio(registros);

          final min = minimo(registros);

          final max = maximo(registros);

          return ListView(
            padding: const EdgeInsets.all(18),

            children: [
              Text(
                widget.nombrePaciente.isEmpty
                    ? 'Paciente'
                    : widget.nombrePaciente,

                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Seguimiento de las mediciones registradas.',
                style: TextStyle(color: AppColors.textSecondary),
              ),

              const SizedBox(height: 20),

              // =====================
              // FILTRO
              // =====================
              Row(
                children: [
                  Expanded(child: _botonPeriodo('7 días')),

                  const SizedBox(width: 10),

                  Expanded(child: _botonPeriodo('30 días')),
                ],
              ),

              const SizedBox(height: 20),

              // =====================
              // ESTADÍSTICAS
              // =====================
              Row(
                children: [
                  Expanded(
                    child: _tarjetaDato(
                      titulo: 'PROMEDIO',

                      valor: registros.isEmpty ? '--' : prom.round().toString(),

                      unidad: 'mg/dL',

                      icono: Icons.show_chart,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _tarjetaDato(
                      titulo: 'MEDICIONES',

                      valor: registros.length.toString(),

                      unidad: '',

                      icono: Icons.water_drop_outlined,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _tarjetaDato(
                      titulo: 'MÍNIMO',

                      valor: registros.isEmpty ? '--' : min.toString(),

                      unidad: 'mg/dL',

                      icono: Icons.south_east,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _tarjetaDato(
                      titulo: 'MÁXIMO',

                      valor: registros.isEmpty ? '--' : max.toString(),

                      unidad: 'mg/dL',

                      icono: Icons.north_east,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              _grafica(registros),

              const SizedBox(height: 22),

              _historial(registros),

              const SizedBox(height: 90),
            ],
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,

        foregroundColor: Colors.white,

        icon: const Icon(Icons.add_comment_outlined),

        label: const Text('Recomendar'),

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  NuevaRecomendacionScreen(pacienteId: widget.pacienteId),
            ),
          );
        },
      ),
    );
  }

  Widget _botonPeriodo(String texto) {
    final seleccionado = periodo == texto;

    return InkWell(
      borderRadius: BorderRadius.circular(12),

      onTap: () {
        setState(() {
          periodo = texto;
        });
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),

        padding: const EdgeInsets.symmetric(vertical: 12),

        decoration: BoxDecoration(
          gradient: seleccionado ? AppColors.primaryGradient : null,

          color: seleccionado ? null : Colors.white,

          borderRadius: BorderRadius.circular(12),
        ),

        child: Text(
          texto,

          textAlign: TextAlign.center,

          style: TextStyle(
            fontWeight: FontWeight.w600,

            color: seleccionado ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _tarjetaDato({
    required String titulo,
    required String valor,
    required String unidad,
    required IconData icono,
  }) {
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

              Icon(icono, size: 18, color: AppColors.primary),
            ],
          ),

          const SizedBox(height: 13),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,

            children: [
              Text(
                valor,

                style: const TextStyle(
                  fontSize: 26,
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
                      fontSize: 9,
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
            'No existen mediciones para este periodo.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final ordenados = [...registros]
      ..sort((a, b) => a.fechaHora.compareTo(b.fechaHora));

    final spots = <FlSpot>[];

    for (int i = 0; i < ordenados.length; i++) {
      spots.add(FlSpot(i.toDouble(), ordenados[i].valor.toDouble()));
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

    final maxX = ordenados.length == 1
        ? 1.0
        : (ordenados.length - 1).toDouble();

    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),
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

          const SizedBox(height: 20),

          SizedBox(
            height: 240,

            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: maxX,

                minY: minY,
                maxY: maxY,

                borderData: FlBorderData(show: false),

                gridData: FlGridData(show: true, drawVerticalLine: false),

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

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),

                          child: Text(
                            '${fecha.day}/${fecha.month}',

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
                    spots: spots,

                    isCurved: true,

                    color: AppColors.primary,

                    barWidth: 3,

                    dotData: FlDotData(show: true),

                    belowBarData: BarAreaData(
                      show: true,

                      color: AppColors.primary.withValues(alpha: .10),
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

  Widget _historial(List<GlucosaRegistro> registros) {
    if (registros.isEmpty) {
      return const SizedBox.shrink();
    }

    final recientes = registros.take(10).toList();

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
            'Mediciones recientes',

            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          ...recientes.map((registro) {
            final fecha = registro.fechaHora;

            return ListTile(
              contentPadding: EdgeInsets.zero,

              leading: const CircleAvatar(
                backgroundColor: Color(0xFFF0FDFA),

                child: Icon(
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
