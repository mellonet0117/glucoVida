import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final AuthService _authService = AuthService();

  String nombreAdmin = 'Administrador';
  String correoAdmin = '';

  String opcionSeleccionada = 'Inicio';

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarAdministrador();
  }

  Future<void> cargarAdministrador() async {
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
        nombreAdmin = datos?['nombre'] ?? 'Administrador';

        correoAdmin = datos?['correo'] ?? usuario.email ?? '';

        cargando = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        cargando = false;
      });
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> usuariosStream() {
    return _firestore.collection('usuarios').snapshots();
  }

  void seleccionarMenu(String opcion) {
    setState(() {
      opcionSeleccionada = opcion;
    });
  }

  void moduloProximo(String nombre, {bool cerrarDrawer = false}) {
    seleccionarMenu(nombre);

    if (cerrarDrawer) {
      Navigator.pop(context);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ahora vamos a desarrollar el módulo "$nombre".'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> cerrarSesion() async {
    Navigator.pop(context);

    await _authService.cerrarSesion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      drawer: _drawerAdmin(),

      appBar: AppBar(
        elevation: 0,

        centerTitle: true,

        title: Image.asset(
          'assets/images/glucovida_horizontal.png',
          height: 38,
        ),

        actions: [
          IconButton(
            tooltip: 'Usuarios',

            onPressed: () {
              moduloProximo('Usuarios');
            },

            icon: const Icon(Icons.manage_accounts_outlined),
          ),

          const SizedBox(width: 5),
        ],
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: usuariosStream(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || cargando) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(25),

                child: Text(
                  'No se pudieron cargar los usuarios.\n\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final usuarios = snapshot.data?.docs ?? [];

          int pacientes = 0;
          int doctores = 0;
          int administradores = 0;
          int sinDoctor = 0;

          for (final doc in usuarios) {
            final datos = doc.data();

            final rol = datos['rol']?.toString() ?? '';

            if (rol == 'paciente') {
              pacientes++;

              final doctorId = datos['doctorId'];

              if (doctorId == null || doctorId.toString().trim().isEmpty) {
                sinDoctor++;
              }
            }

            if (rol == 'doctor') {
              doctores++;
            }

            if (rol == 'admin') {
              administradores++;
            }
          }

          return RefreshIndicator(
            onRefresh: cargarAdministrador,

            child: ListView(
              padding: const EdgeInsets.all(18),

              children: [
                Text(
                  'Hola, $nombreAdmin 👋',

                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Panel de administración de GlucoVida.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: _tarjetaResumen(
                        titulo: 'USUARIOS',

                        valor: usuarios.length.toString(),

                        icono: Icons.groups_outlined,

                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: _tarjetaResumen(
                        titulo: 'PACIENTES',

                        valor: pacientes.toString(),

                        icono: Icons.person_outline,

                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: _tarjetaResumen(
                        titulo: 'DOCTORES',

                        valor: doctores.toString(),

                        icono: Icons.medical_services_outlined,

                        color: AppColors.success,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: _tarjetaResumen(
                        titulo: 'SIN DOCTOR',

                        valor: sinDoctor.toString(),

                        icono: Icons.person_search_outlined,

                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                const Text(
                  'Administración',

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
                        icono: Icons.manage_accounts_outlined,

                        titulo: 'Usuarios',

                        onTap: () {
                          moduloProximo('Usuarios');
                        },
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: _accesoRapido(
                        icono: Icons.medical_services_outlined,

                        titulo: 'Doctores',

                        onTap: () {
                          moduloProximo('Doctores');
                        },
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: _accesoRapido(
                        icono: Icons.link_outlined,

                        titulo: 'Asignar',

                        onTap: () {
                          moduloProximo('Asignaciones');
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                _tarjetaPendientes(sinDoctor),

                const SizedBox(height: 30),

                Text(
                  'Administradores registrados: '
                  '$administradores',

                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // =====================================================
  // DRAWER
  // =====================================================

  Widget _drawerAdmin() {
    return Drawer(
      backgroundColor: Colors.white,

      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),

              child: Column(
                children: [
                  Image.asset(
                    'assets/images/glucovida_horizontal.png',
                    height: 48,
                  ),

                  const SizedBox(height: 17),

                  CircleAvatar(
                    radius: 34,

                    backgroundColor: AppColors.primary,

                    child: Text(
                      nombreAdmin.isNotEmpty
                          ? nombreAdmin[0].toUpperCase()
                          : 'A',

                      style: const TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    nombreAdmin,

                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    correoAdmin,

                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 6),

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
                      'ADMINISTRADOR',

                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

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
                    icono: Icons.manage_accounts_outlined,

                    iconoActivo: Icons.manage_accounts,

                    titulo: 'Usuarios',

                    onTap: () {
                      moduloProximo('Usuarios', cerrarDrawer: true);
                    },
                  ),

                  _itemMenu(
                    icono: Icons.medical_services_outlined,

                    iconoActivo: Icons.medical_services,

                    titulo: 'Doctores',

                    onTap: () {
                      moduloProximo('Doctores', cerrarDrawer: true);
                    },
                  ),

                  _itemMenu(
                    icono: Icons.person_outline,

                    iconoActivo: Icons.person,

                    titulo: 'Pacientes',

                    onTap: () {
                      moduloProximo('Pacientes', cerrarDrawer: true);
                    },
                  ),

                  _itemMenu(
                    icono: Icons.link_outlined,

                    iconoActivo: Icons.link,

                    titulo: 'Asignaciones',

                    onTap: () {
                      moduloProximo('Asignaciones', cerrarDrawer: true);
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

  Widget _itemMenu({
    required IconData icono,
    required IconData iconoActivo,
    required String titulo,
    required VoidCallback onTap,
  }) {
    final activo = opcionSeleccionada == titulo;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),

      child: Material(
        color: Colors.transparent,

        child: InkWell(
          borderRadius: BorderRadius.circular(12),

          onTap: onTap,

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),

            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),

            decoration: BoxDecoration(
              gradient: activo ? AppColors.primaryGradient : null,

              borderRadius: BorderRadius.circular(12),
            ),

            child: Row(
              children: [
                Icon(
                  activo ? iconoActivo : icono,

                  size: 22,

                  color: activo ? Colors.white : AppColors.textSecondary,
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Text(
                    titulo,

                    style: TextStyle(
                      color: activo ? Colors.white : AppColors.textPrimary,

                      fontWeight: activo ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),

                if (activo)
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

  Widget _tarjetaResumen({
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

          const SizedBox(height: 14),

          Text(
            valor,

            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

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
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 5),

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

  Widget _tarjetaPendientes(int sinDoctor) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,

            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: .12),

              borderRadius: BorderRadius.circular(14),
            ),

            child: const Icon(
              Icons.person_search_outlined,
              color: AppColors.warning,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  'Pacientes por asignar',

                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 3),

                Text(
                  sinDoctor == 0
                      ? 'Todos los pacientes tienen doctor asignado.'
                      : '$sinDoctor paciente(s) todavía no tienen doctor.',

                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
