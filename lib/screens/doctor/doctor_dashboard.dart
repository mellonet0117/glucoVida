import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';

import 'citas_doctor_screen.dart';
import 'paciente_detalle_doctor.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final AuthService _authService = AuthService();

  String nombreDoctor = 'Doctor';
  String correoDoctor = '';

  bool cargando = true;

  // Para marcar la opción seleccionada
  String opcionSeleccionada = 'Inicio';

  @override
  void initState() {
    super.initState();
    cargarDoctor();
  }

  // =========================================================
  // CARGAR DATOS DEL DOCTOR
  // =========================================================

  Future<void> cargarDoctor() async {
    final usuario = _auth.currentUser;

    if (usuario == null) return;

    try {
      final doc = await _firestore
          .collection('usuarios')
          .doc(usuario.uid)
          .get();

      final datos = doc.data();

      if (!mounted) return;

      setState(() {
        nombreDoctor = datos?['nombre'] ?? 'Doctor';

        correoDoctor = datos?['correo'] ?? usuario.email ?? '';

        cargando = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        cargando = false;
      });
    }
  }

  // =========================================================
  // PACIENTES ASIGNADOS
  // =========================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> pacientesAsignados() {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('usuarios')
        .where('doctorId', isEqualTo: usuario.uid)
        .snapshots();
  }

  // =========================================================
  // NAVEGACIÓN DEL MENÚ
  // =========================================================

  void seleccionarMenu(String opcion) {
    setState(() {
      opcionSeleccionada = opcion;
    });
  }

  void abrirCitas() {
    seleccionarMenu('Citas médicas');

    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CitasDoctorScreen()),
    ).then((_) {
      if (mounted) {
        setState(() {
          opcionSeleccionada = 'Inicio';
        });
      }
    });
  }

  void moduloProximo(String nombre, {bool cerrarDrawer = false}) {
    seleccionarMenu(nombre);

    if (cerrarDrawer) {
      Navigator.pop(context);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'El módulo "$nombre" será el siguiente en desarrollarse.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          opcionSeleccionada = 'Inicio';
        });
      }
    });
  }

  Future<void> cerrarSesion() async {
    Navigator.pop(context);

    await _authService.cerrarSesion();
  }

  // =========================================================
  // PANTALLA PRINCIPAL
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      drawer: _drawerDoctor(),

      appBar: AppBar(
        elevation: 0,

        title: Image.asset(
          'assets/images/glucovida_horizontal.png',
          height: 38,
          fit: BoxFit.contain,
        ),

        centerTitle: true,

        actions: [
          IconButton(
            tooltip: 'Citas',

            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CitasDoctorScreen()),
              );
            },

            icon: const Icon(Icons.calendar_month_outlined),
          ),

          const SizedBox(width: 5),
        ],
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: pacientesAsignados(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || cargando) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'No se pudieron cargar los pacientes.\n'
                '${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final pacientes = snapshot.data?.docs ?? [];

          return RefreshIndicator(
            onRefresh: cargarDoctor,

            child: ListView(
              padding: const EdgeInsets.all(18),

              children: [
                // ======================
                // SALUDO
                // ======================

                Text(
                  'Hola, Dr. $nombreDoctor 👋',

                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Este es el resumen de tus pacientes.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),

                const SizedBox(height: 22),

                // ======================
                // TARJETAS
                // ======================
                Row(
                  children: [
                    Expanded(
                      child: _resumen(
                        titulo: 'PACIENTES',

                        valor: pacientes.length.toString(),

                        icono: Icons.people_outline,

                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(child: _tarjetaCitasHoy()),
                  ],
                ),

                const SizedBox(height: 26),

                // ======================
                // ACCESOS RÁPIDOS
                // ======================
                const Text(
                  'Accesos rápidos',

                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _accesoRapido(
                        icono: Icons.people_outline,

                        titulo: 'Pacientes',

                        onTap: () {
                          _mostrarPacientes(pacientes);
                        },
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: _accesoRapido(
                        icono: Icons.calendar_month_outlined,

                        titulo: 'Citas',

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CitasDoctorScreen(),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: _accesoRapido(
                        icono: Icons.medical_information_outlined,

                        titulo: 'Seguimiento',

                        onTap: () {
                          moduloProximo('Seguimiento');
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ======================
                // MIS PACIENTES
                // ======================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    const Text(
                      'Mis pacientes',

                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    if (pacientes.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          _mostrarPacientes(pacientes);
                        },

                        child: const Text('Ver todos'),
                      ),
                  ],
                ),

                const SizedBox(height: 10),

                if (pacientes.isEmpty)
                  _sinPacientes()
                else
                  ...pacientes.take(5).map((doc) {
                    return _pacienteCard(uid: doc.id, datos: doc.data());
                  }),

                const SizedBox(height: 35),
              ],
            ),
          );
        },
      ),
    );
  }

  // =========================================================
  // DRAWER
  // =========================================================

  Widget _drawerDoctor() {
    return Drawer(
      backgroundColor: Colors.white,

      child: SafeArea(
        child: Column(
          children: [
            // ======================
            // CABECERA
            // ======================

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),

              child: Column(
                children: [
                  Image.asset(
                    'assets/images/glucovida_horizontal.png',
                    height: 48,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 18),

                  CircleAvatar(
                    radius: 34,

                    backgroundColor: AppColors.primary,

                    child: Text(
                      nombreDoctor.isNotEmpty
                          ? nombreDoctor[0].toUpperCase()
                          : 'D',

                      style: const TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Dr. $nombreDoctor',

                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    correoDoctor,

                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),

                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: .10),

                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: const Text(
                      'DOCTOR',

                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // ======================
            // OPCIONES
            // ======================
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),

                children: [
                  _itemMenu(
                    icono: Icons.home_outlined,

                    iconoActivo: Icons.home,

                    titulo: 'Inicio',

                    onTap: () {
                      seleccionarMenu('Inicio');

                      Navigator.pop(context);
                    },
                  ),

                  _itemMenu(
                    icono: Icons.people_outline,

                    iconoActivo: Icons.people,

                    titulo: 'Mis pacientes',

                    onTap: () async {
                      seleccionarMenu('Mis pacientes');

                      Navigator.pop(context);

                      final snapshot = await _firestore
                          .collection('usuarios')
                          .where('doctorId', isEqualTo: _auth.currentUser?.uid)
                          .get();

                      if (!mounted) {
                        return;
                      }

                      _mostrarPacientes(snapshot.docs);

                      setState(() {
                        opcionSeleccionada = 'Inicio';
                      });
                    },
                  ),

                  _itemMenu(
                    icono: Icons.calendar_month_outlined,

                    iconoActivo: Icons.calendar_month,

                    titulo: 'Citas médicas',

                    onTap: abrirCitas,
                  ),

                  _itemMenu(
                    icono: Icons.medical_information_outlined,

                    iconoActivo: Icons.medical_information,

                    titulo: 'Recomendaciones',

                    onTap: () {
                      moduloProximo('Recomendaciones', cerrarDrawer: true);
                    },
                  ),

                  _itemMenu(
                    icono: Icons.monitor_heart_outlined,

                    iconoActivo: Icons.monitor_heart,

                    titulo: 'Seguimiento',

                    onTap: () {
                      moduloProximo('Seguimiento', cerrarDrawer: true);
                    },
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 7),

                    child: Divider(),
                  ),

                  _itemMenu(
                    icono: Icons.person_outline,

                    iconoActivo: Icons.person,

                    titulo: 'Mi perfil',

                    onTap: () {
                      moduloProximo('Mi perfil', cerrarDrawer: true);
                    },
                  ),

                  _itemMenu(
                    icono: Icons.settings_outlined,

                    iconoActivo: Icons.settings,

                    titulo: 'Configuración',

                    onTap: () {
                      moduloProximo('Configuración', cerrarDrawer: true);
                    },
                  ),
                ],
              ),
            ),

            // ======================
            // CERRAR SESIÓN
            // ======================
            const Divider(height: 1),

            Padding(
              padding: const EdgeInsets.all(10),

              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),

                leading: const Icon(Icons.logout, color: AppColors.danger),

                title: const Text(
                  'Cerrar sesión',

                  style: TextStyle(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                onTap: cerrarSesion,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // ITEM DEL MENÚ CON COLOR SELECCIONADO
  // =========================================================

  Widget _itemMenu({
    required IconData icono,
    required IconData iconoActivo,
    required String titulo,
    required VoidCallback onTap,
  }) {
    final seleccionado = opcionSeleccionada == titulo;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),

      child: Material(
        color: Colors.transparent,

        child: InkWell(
          borderRadius: BorderRadius.circular(12),

          onTap: onTap,

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),

            curve: Curves.easeInOut,

            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),

            decoration: BoxDecoration(
              gradient: seleccionado ? AppColors.primaryGradient : null,

              borderRadius: BorderRadius.circular(12),
            ),

            child: Row(
              children: [
                Icon(
                  seleccionado ? iconoActivo : icono,

                  size: 22,

                  color: seleccionado ? Colors.white : AppColors.textSecondary,
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Text(
                    titulo,

                    style: TextStyle(
                      fontSize: 14,

                      fontWeight: seleccionado
                          ? FontWeight.w600
                          : FontWeight.w500,

                      color: seleccionado
                          ? Colors.white
                          : AppColors.textPrimary,
                    ),
                  ),
                ),

                if (seleccionado)
                  const Icon(
                    Icons.chevron_right,

                    size: 18,
                    color: Colors.white,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // TARJETAS DE RESUMEN
  // =========================================================

  Widget _resumen({
    required String titulo,
    required String valor,
    required IconData icono,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),

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
              Text(
                titulo,

                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),

              Icon(icono, color: color, size: 21),
            ],
          ),

          const SizedBox(height: 15),

          Text(
            valor,

            style: const TextStyle(
              fontSize: 29,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // CITAS DE HOY
  // =========================================================

  Widget _tarjetaCitasHoy() {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      return _resumen(
        titulo: 'CITAS HOY',
        valor: '0',
        icono: Icons.calendar_month_outlined,
        color: AppColors.accent,
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestore
          .collection('citas')
          .where('doctorId', isEqualTo: usuario.uid)
          .snapshots(),

      builder: (context, snapshot) {
        final ahora = DateTime.now();

        int totalHoy = 0;

        if (snapshot.hasData) {
          for (final doc in snapshot.data!.docs) {
            final datos = doc.data();

            final fecha = datos['fechaHora'];

            if (fecha is Timestamp) {
              final f = fecha.toDate();

              if (f.year == ahora.year &&
                  f.month == ahora.month &&
                  f.day == ahora.day &&
                  datos['estado'] != 'cancelada') {
                totalHoy++;
              }
            }
          }
        }

        return _resumen(
          titulo: 'CITAS HOY',

          valor: totalHoy.toString(),

          icono: Icons.calendar_month_outlined,

          color: AppColors.accent,
        );
      },
    );
  }

  // =========================================================
  // ACCESO RÁPIDO
  // =========================================================

  Widget _accesoRapido({
    required IconData icono,
    required String titulo,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,

      borderRadius: BorderRadius.circular(15),

      child: InkWell(
        borderRadius: BorderRadius.circular(15),

        onTap: onTap,

        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),

            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),

          child: Column(
            children: [
              Container(
                width: 43,
                height: 43,

                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: .10),

                  borderRadius: BorderRadius.circular(12),
                ),

                child: Icon(icono, color: AppColors.primary),
              ),

              const SizedBox(height: 8),

              Text(
                titulo,

                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // PACIENTE CARD
  // =========================================================

  Widget _pacienteCard({
    required String uid,
    required Map<String, dynamic> datos,
  }) {
    final nombre = datos['nombre'] ?? '';

    final apellidos = datos['apellidos'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 11),

      child: ListTile(
        contentPadding: const EdgeInsets.all(13),

        leading: CircleAvatar(
          radius: 25,

          backgroundColor: const Color(0xFFF0FDFA),

          child: Text(
            nombre.isNotEmpty ? nombre[0].toUpperCase() : 'P',

            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),

        title: Text(
          '$nombre $apellidos'.trim(),

          style: const TextStyle(fontWeight: FontWeight.w600),
        ),

        subtitle: Text(
          datos['correo'] ?? '',

          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),

        trailing: const Icon(Icons.chevron_right),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PacienteDetalleDoctor(pacienteId: uid),
            ),
          );
        },
      ),
    );
  }

  // =========================================================
  // SIN PACIENTES
  // =========================================================

  Widget _sinPacientes() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 45, horizontal: 20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),
      ),

      child: const Column(
        children: [
          Icon(Icons.people_outline, size: 60, color: AppColors.textMuted),

          SizedBox(height: 13),

          Text(
            'No tienes pacientes asignados',

            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),

          SizedBox(height: 5),

          Text(
            'Los pacientes asignados aparecerán aquí.',

            textAlign: TextAlign.center,

            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // MOSTRAR TODOS LOS PACIENTES
  // =========================================================

  void _mostrarPacientes(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> pacientes,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,

      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: .75,
          minChildSize: .5,
          maxChildSize: .95,

          builder: (context, controller) {
            return Column(
              children: [
                const SizedBox(height: 10),

                Container(
                  width: 45,
                  height: 5,

                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,

                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.all(18),

                  child: Row(
                    children: [
                      Icon(Icons.people_outline, color: AppColors.primary),

                      SizedBox(width: 10),

                      Text(
                        'Mis pacientes',

                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: pacientes.isEmpty
                      ? const Center(
                          child: Text('No tienes pacientes asignados.'),
                        )
                      : ListView.builder(
                          controller: controller,

                          padding: const EdgeInsets.symmetric(horizontal: 15),

                          itemCount: pacientes.length,

                          itemBuilder: (context, index) {
                            final doc = pacientes[index];

                            return _pacienteCard(
                              uid: doc.id,

                              datos: doc.data(),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
