import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'registrar_glucosa_screen.dart';
import 'historial_glucosa_screen.dart';

import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';

import '../../models/glucosa_registro.dart';
import '../../services/glucosa_service.dart';

import 'medicamentos_screen.dart';
import 'alimentacion_screen.dart';
import 'actividad_fisica_screen.dart';
import 'recordatorios_screen.dart';
import 'estadisticas_screen.dart';
import 'perfil_screen.dart';
import 'configuracion_screen.dart';
import 'recomendaciones_screen.dart';
import 'citas_screen.dart';

import '../../models/medicamento.dart';
import '../../services/medicamento_service.dart';

class PacienteDashboard extends StatefulWidget {
  const PacienteDashboard({super.key});

  @override
  State<PacienteDashboard> createState() => _PacienteDashboardState();
}

class _PacienteDashboardState extends State<PacienteDashboard> {
  final AuthService _authService = AuthService();
  final GlucosaService _glucosaService = GlucosaService();
  final MedicamentoService _medicamentoService = MedicamentoService();

  String nombre = 'Paciente';
  bool cargandoUsuario = true;

  String rangoSeleccionado = 'Hoy';

  String opcionSeleccionada = 'Inicio';

  // ===================================
  // PROMEDIO SEMANAL
  // ===================================

  double calcularPromedioSemanal(List<GlucosaRegistro> registros) {
    final limite = DateTime.now().subtract(const Duration(days: 7));

    final recientes = registros
        .where((registro) => registro.fechaHora.isAfter(limite))
        .toList();

    if (recientes.isEmpty) {
      return 0;
    }

    final suma = recientes.fold<int>(
      0,
      (total, registro) => total + registro.valor,
    );

    return suma / recientes.length;
  }

  @override
  void initState() {
    super.initState();
    cargarUsuario();
  }

  Future<void> cargarUsuario() async {
    try {
      final usuario = FirebaseAuth.instance.currentUser;

      if (usuario == null) return;

      final documento = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuario.uid)
          .get();

      if (!mounted) return;

      if (documento.exists) {
        final datos = documento.data()!;

        setState(() {
          nombre = datos['nombre']?.toString() ?? 'Paciente';

          cargandoUsuario = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cargandoUsuario = false;
      });
    }
  }

  Future<void> cerrarSesion() async {
    Navigator.pop(context);

    await _authService.cerrarSesion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ==============================
      // MENÚ LATERAL
      // ==============================
      drawer: _menuLateral(),

      // Permite abrirlo arrastrando desde la izquierda
      drawerEnableOpenDragGesture: true,

      // Hace más grande la zona donde detecta el dedo
      drawerEdgeDragWidth: 80,

      // Oscurece el dashboard mientras el menú está abierto
      drawerScrimColor: Colors.black.withValues(alpha: 0.35),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,

        title: Image.asset(
          'assets/images/glucovida_horizontal.png',
          height: 48,
          fit: BoxFit.contain,
        ),

        actions: [
          IconButton(
            tooltip: 'Notificaciones',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RecordatoriosScreen()),
              );
            },
            icon: Stack(
              children: [
                const Icon(Icons.notifications_none_rounded),

                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 5),

          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: CircleAvatar(
              radius: 18,

              backgroundColor: AppColors.primary,

              child: Text(
                nombre.isNotEmpty ? nombre[0].toUpperCase() : 'P',

                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: cargarUsuario,

        child: ListView(
          padding: const EdgeInsets.all(18),

          children: [
            // ========================
            // BIENVENIDA
            // ========================

            Text(
              cargandoUsuario ? 'Buenos días ' : 'Buenos días, $nombre ',

              style: const TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              'Este es el resumen de tu salud de hoy.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),

            const SizedBox(height: 22),

            // ========================
            // REGISTRAR GLUCOSA
            // ========================
            Container(
              height: 52,

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 23, 101, 227),
                    Color.fromARGB(255, 43, 182, 108),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),

                borderRadius: BorderRadius.circular(10),

                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),

              child: Material(
                color: Colors.transparent,

                child: InkWell(
                  borderRadius: BorderRadius.circular(13),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegistrarGlucosaScreen(),
                      ),
                    );
                  },

                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      Icon(Icons.add, color: Colors.white),

                      SizedBox(width: 7),

                      Text(
                        'Registrar glucosa',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ========================
            // GLUCOSA ACTUAL
            // ========================
            StreamBuilder<List<GlucosaRegistro>>(
              stream: _glucosaService.obtenerRegistros(),

              builder: (context, snapshot) {
                final registros = snapshot.data ?? [];

                if (registros.isEmpty) {
                  return _tarjetaGlucosa(valor: null);
                }

                return _tarjetaGlucosa(valor: registros.first.valor);
              },
            ),

            const SizedBox(height: 14),

            // ========================
            // PROMEDIO Y MEDICAMENTOS
            // ========================
            StreamBuilder<List<GlucosaRegistro>>(
              stream: _glucosaService.obtenerRegistros(),

              builder: (context, snapshot) {
                final registros = snapshot.data ?? [];

                final promedio = calcularPromedioSemanal(registros);

                return Row(
                  children: [
                    Expanded(child: _tarjetaPromedio(promedio)),

                    const SizedBox(width: 12),

                    Expanded(
                      child: StreamBuilder<List<Medicamento>>(
                        stream: _medicamentoService.obtenerMedicamentos(),

                        builder: (context, snapshot) {
                          final medicamentos = snapshot.data ?? [];

                          final activos = medicamentos
                              .where((m) => m.activo)
                              .toList();

                          final tomados = activos
                              .where((m) => m.tomadoHoy)
                              .length;

                          return _tarjetaMedicamentos(
                            tomados: tomados,
                            total: activos.length,
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(child: _tarjetaActividad()),

                const SizedBox(width: 12),

                Expanded(child: _tarjetaProximaMedicion()),
              ],
            ),

            const SizedBox(height: 20),

            // ========================
            // GRÁFICA
            // ========================
            StreamBuilder<List<GlucosaRegistro>>(
              stream: _glucosaService.obtenerRegistros(),

              builder: (context, snapshot) {
                final registros = snapshot.data ?? [];

                return _graficaGlucosa(registros);
              },
            ),

            const SizedBox(height: 20),

            // ========================
            // LECTURAS RECIENTES
            // ========================
            StreamBuilder<List<GlucosaRegistro>>(
              stream: _glucosaService.obtenerRegistros(),

              builder: (context, snapshot) {
                final registros = snapshot.data ?? [];

                return _lecturasRecientes(registros);
              },
            ),

            const SizedBox(height: 20),

            // ========================
            // MEDICAMENTOS HOY
            // ========================
            _medicamentosHoy(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ===================================
  // MENÚ
  // ===================================

  Widget _menuLateral() {
    return Drawer(
      backgroundColor: Colors.white,

      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(0),

              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16, // izquierda
                      6, // arriba
                      16, // derecha
                      6, // abajo
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Image.asset(
                        'assets/images/glucovida_horizontal.png',
                        width: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 9),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),

                children: [
                  _itemMenu(
                    Icons.home_outlined,
                    'Inicio',
                    activo: opcionSeleccionada == 'Inicio',
                    onTap: () {
                      setState(() {
                        opcionSeleccionada = 'Inicio';
                      });

                      Navigator.pop(context);

                      setState(() {
                        opcionSeleccionada = 'Inicio';
                      });
                    },
                  ),

                  _itemMenu(
                    Icons.water_drop_outlined,
                    'Mi Glucosa',

                    activo: opcionSeleccionada == 'Mi Glucosa',

                    onTap: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HistorialGlucosaScreen(),
                        ),
                      );

                      setState(() {
                        opcionSeleccionada = 'Mi Glucosa';
                      });
                    },
                  ),

                  _itemMenu(
                    Icons.add_circle_outline,
                    'Registrar Glucosa',

                    activo: opcionSeleccionada == 'Registrar Glucosa',

                    onTap: () {
                      // Cierra el menú lateral
                      Navigator.pop(context);

                      // Abre Registrar Glucosa
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegistrarGlucosaScreen(),
                        ),
                      );

                      setState(() {
                        opcionSeleccionada = 'Registrar Glucosa';
                      });
                    },
                  ),

                  _itemMenu(
                    Icons.history,
                    'Historial',

                    activo: opcionSeleccionada == 'Historial',

                    onTap: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HistorialGlucosaScreen(),
                        ),
                      );
                      setState(() {
                        opcionSeleccionada = 'Historial';
                      });
                    },
                  ),

                  _itemMenu(
                    Icons.medication_outlined,
                    'Medicamentos',

                    activo: opcionSeleccionada == 'Medicamentos',

                    onTap: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => MedicamentosScreen()),
                      );

                      setState(() {
                        opcionSeleccionada = 'Medicamentos';
                      });
                    },
                  ),

                  _itemMenu(
                    Icons.restaurant_outlined,
                    'Alimentación',

                    activo: opcionSeleccionada == 'Alimentación',

                    onTap: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AlimentacionScreen(),
                        ),
                      );

                      setState(() {
                        opcionSeleccionada = 'Alimentación';
                      });
                    },
                  ),

                  _itemMenu(
                    Icons.directions_run_outlined,
                    'Actividad Física',

                    activo: opcionSeleccionada == 'Actividad Física',

                    onTap: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ActividadFisicaScreen(),
                        ),
                      );

                      setState(() {
                        opcionSeleccionada = 'Actividad Física';
                      });
                    },
                  ),

                  _itemMenu(
                    Icons.medical_information_outlined,
                    'Mis recomendaciones',

                    activo: opcionSeleccionada == 'Mis recomendaciones',

                    onTap: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RecomendacionesScreen(),
                        ),
                      );

                      setState(() {
                        opcionSeleccionada = 'Mis recomendaciones';
                      });
                    },
                  ),

                  _itemMenu(
                    Icons.calendar_month_outlined,
                    'Citas médicas',

                    activo: opcionSeleccionada == 'Citas médicas',

                    onTap: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CitasScreen()),
                      );

                      setState(() {
                        opcionSeleccionada = 'Citas médicas';
                      });
                    },
                  ),

                  _itemMenu(
                    Icons.notifications_none,
                    'Recordatorios',

                    activo: opcionSeleccionada == 'Recordatorios',

                    onTap: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RecordatoriosScreen(),
                        ),
                      );

                      setState(() {
                        opcionSeleccionada = 'Recordatorios';
                      });
                    },
                  ),

                  _itemMenu(
                    Icons.bar_chart_outlined,
                    'Estadísticas',

                    activo: opcionSeleccionada == 'Estadísticas',

                    onTap: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EstadisticasScreen(),
                        ),
                      );

                      setState(() {
                        opcionSeleccionada = 'Estadísticas';
                      });
                    },
                  ),
                  _itemMenu(
                    Icons.person_outline,
                    'Perfil',

                    activo: opcionSeleccionada == 'Perfil',

                    onTap: () async {
                      Navigator.pop(context);

                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PerfilScreen()),
                      );

                      await cargarUsuario();

                      setState(() {
                        opcionSeleccionada = 'Perfil';
                      });
                    },
                  ),
                  _itemMenu(
                    Icons.settings_outlined,
                    'Configuración',

                    activo: opcionSeleccionada == 'Configuración',

                    onTap: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ConfiguracionScreen(),
                        ),
                      );

                      setState(() {
                        opcionSeleccionada = 'Configuración';
                      });
                    },
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            Padding(
              padding: const EdgeInsets.all(12),

              child: ListTile(
                onTap: cerrarSesion,

                leading: const Icon(Icons.logout, color: AppColors.danger),

                title: const Text(
                  'Cerrar sesión',
                  style: TextStyle(color: AppColors.danger),
                ),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemMenu(
    IconData icon,
    String texto, {
    bool activo = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),

      decoration: BoxDecoration(
        gradient: activo ? AppColors.primaryGradient : null,

        borderRadius: BorderRadius.circular(12),
      ),

      child: ListTile(
        dense: true,

        leading: Icon(
          icon,
          color: activo ? Colors.white : AppColors.textSecondary,
        ),

        title: Text(
          texto,

          style: TextStyle(
            color: activo ? Colors.white : AppColors.textPrimary,

            fontWeight: FontWeight.w500,
          ),
        ),

        onTap:
            onTap ??
            () {
              Navigator.pop(context);
            },
      ),
    );
  }

  // ===================================
  // TARJETA GLUCOSA
  // ===================================

  Widget _tarjetaGlucosa({required int? valor}) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
        ),

        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              const Text(
                'GLUCOSA ACTUAL',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),

              Container(
                padding: const EdgeInsets.all(7),

                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),

                  borderRadius: BorderRadius.circular(8),
                ),

                child: const Icon(
                  Icons.bar_chart_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,

            children: [
              Text(
                valor?.toString() ?? '--',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 37,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Padding(
                padding: EdgeInsets.only(left: 6, bottom: 6),

                child: Text('mg/dL', style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Container(
                width: 21,
                height: 21,

                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),

                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.arrow_forward,
                  size: 13,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 7),

              const Text(
                'Última medición registrada',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tarjetaPromedio(double promedio) {
    return _tarjetaPequena(
      titulo: 'PROM. SEMANAL',
      valor: promedio == 0 ? '--' : promedio.round().toString(),
      unidad: 'mg/dL',
      descripcion: 'Últimos 7 días',
      icono: Icons.show_chart,
      gradient: const LinearGradient(
        colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
      ),
    );
  }

  Widget _tarjetaMedicamentos({required int tomados, required int total}) {
    final pendientes = total - tomados;

    final progreso = total == 0 ? 0.0 : tomados / total;

    return _tarjetaBlanca(
      titulo: 'MEDICAMENTOS',

      valor: tomados.toString(),

      unidad: '/ $total',

      descripcion: pendientes == 0
          ? 'Sin pendientes'
          : '$pendientes pendiente${pendientes == 1 ? '' : 's'}',

      icono: Icons.check_circle_outline,

      colorIcono: AppColors.success,

      progreso: progreso,
    );
  }

  Widget _tarjetaActividad() {
    return _tarjetaBlanca(
      titulo: 'ACTIVIDAD',
      valor: '35',
      unidad: 'min',
      descripcion: 'Meta: 60 min',
      icono: Icons.bolt,
      colorIcono: AppColors.warning,
      progreso: 0.58,
    );
  }

  Widget _tarjetaProximaMedicion() {
    return Container(
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(17),

        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),

      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            'PRÓX. MEDICIÓN',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 13),

          Text(
            '2:30',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          Text(
            'PM',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),

          SizedBox(height: 8),

          Text(
            'Después de comer',
            style: TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaPequena({
    required String titulo,
    required String valor,
    required String unidad,
    required String descripcion,
    required IconData icono,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        gradient: gradient,

        borderRadius: BorderRadius.circular(17),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Flexible(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Icon(icono, size: 17, color: Colors.white),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,

            children: [
              Text(
                valor,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 4),

                child: Text(
                  unidad,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            descripcion,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaBlanca({
    required String titulo,
    required String valor,
    required String unidad,
    required String descripcion,
    required IconData icono,
    required Color colorIcono,
    required double progreso,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(17),

        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Flexible(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Icon(icono, size: 18, color: colorIcono),
            ],
          ),

          const SizedBox(height: 13),

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

              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 4),

                child: Text(
                  unidad,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),

            child: LinearProgressIndicator(
              value: progreso,
              minHeight: 6,
              backgroundColor: const Color(0xFFF1F5F9),
              color: colorIcono,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            descripcion,
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  // ===================================
  // GRÁFICA
  // ===================================

  Widget _graficaGlucosa(List<GlucosaRegistro> registros) {
    if (registros.isEmpty) {
      return _contenedorSeccion(
        titulo: 'Niveles de glucosa',
        child: const SizedBox(
          height: 180,
          child: Center(
            child: Text(
              'Aún no hay mediciones para mostrar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
      );
    }

    // Tomamos máximo 8 registros.
    // Como Firestore los entrega del más reciente
    // al más antiguo, después los invertimos.
    final ultimos = registros.take(8).toList().reversed.toList();

    final puntos = <FlSpot>[];

    for (int i = 0; i < ultimos.length; i++) {
      puntos.add(FlSpot(i.toDouble(), ultimos[i].valor.toDouble()));
    }

    double minimo = ultimos
        .map((e) => e.valor)
        .reduce((a, b) => a < b ? a : b)
        .toDouble();

    double maximo = ultimos
        .map((e) => e.valor)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    minimo = (minimo - 30).clamp(0, 600);
    maximo = (maximo + 30).clamp(30, 600);

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
            'Niveles de glucosa',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 3),

          const Text(
            'Tus últimas mediciones registradas',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),

          const SizedBox(height: 22),

          SizedBox(
            height: 230,

            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (ultimos.length - 1).toDouble(),

                minY: minimo,
                maxY: maximo,

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
                      interval: 1,

                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();

                        if (index < 0 || index >= ultimos.length) {
                          return const SizedBox();
                        }

                        final fecha = ultimos[index].fechaHora;

                        final hora =
                            '${fecha.hour.toString().padLeft(2, '0')}:'
                            '${fecha.minute.toString().padLeft(2, '0')}';

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            hora,
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

  // ===================================
  // LECTURAS
  // ===================================

  Widget _lecturasRecientes(List<GlucosaRegistro> registros) {
    if (registros.isEmpty) {
      return _contenedorSeccion(
        titulo: 'Lecturas recientes',
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 25),
          child: Center(
            child: Text(
              'No tienes registros todavía',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
      );
    }

    final recientes = registros.take(4).toList();

    return _contenedorSeccion(
      titulo: 'Lecturas recientes',

      child: Column(
        children: recientes.map((registro) {
          return _lecturaReal(registro);
        }).toList(),
      ),
    );
  }

  Widget _lecturaReal(GlucosaRegistro registro) {
    final fecha = registro.fechaHora;

    final hora =
        '${fecha.hour.toString().padLeft(2, '0')}:'
        '${fecha.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),

      child: Row(
        children: [
          Container(
            width: 54,
            height: 43,

            alignment: Alignment.center,

            decoration: BoxDecoration(
              color: const Color(0xFFF0FDFA),

              borderRadius: BorderRadius.circular(11),
            ),

            child: Text(
              hora,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  registro.momento,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                Text(
                  '${fecha.day.toString().padLeft(2, '0')}/'
                  '${fecha.month.toString().padLeft(2, '0')}/'
                  '${fecha.year}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

            decoration: BoxDecoration(
              color: const Color(0xFFF0FDFA),

              borderRadius: BorderRadius.circular(20),
            ),

            child: Text(
              '${registro.valor} mg/dL',

              style: const TextStyle(
                color: AppColors.primaryDark,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===================================
  // MEDICAMENTOS
  // ===================================

  Widget _medicamentosHoy() {
    return _contenedorSeccion(
      titulo: 'Medicamentos hoy',

      child: Column(
        children: [
          _medicamento('Metformina 500mg', '08:00', true),

          _medicamento('Glibenclamida 5mg', '13:00', true),

          _medicamento('Metformina 500mg', '20:00', false),
        ],
      ),
    );
  }

  Widget _medicamento(String nombre, String hora, bool tomado) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),

      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,

            decoration: BoxDecoration(
              color: tomado ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),

              borderRadius: BorderRadius.circular(11),
            ),

            child: Icon(
              tomado ? Icons.check_circle_outline : Icons.schedule,

              color: tomado ? AppColors.success : AppColors.warning,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                Text(
                  hora,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),

            decoration: BoxDecoration(
              color: tomado ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),

              borderRadius: BorderRadius.circular(20),
            ),

            child: Text(
              tomado ? 'Tomado' : 'Pendiente',

              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,

                color: tomado
                    ? const Color(0xFF047857)
                    : const Color(0xFFB45309),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contenedorSeccion({required String titulo, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(17),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const Text(
                'Ver todo',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          child,
        ],
      ),
    );
  }
}
