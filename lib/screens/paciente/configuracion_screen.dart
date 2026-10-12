import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../services/notificacion_service.dart';
import '../../services/recordatorio_service.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RecordatorioService _recordatorioService = RecordatorioService();

  bool notificaciones = true;
  bool cargando = true;
  bool actualizandoNotificaciones = false;

  @override
  void initState() {
    super.initState();
    cargarConfiguracion();
  }

  Future<void> cargarConfiguracion() async {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      return;
    }

    try {
      final doc = await _firestore
          .collection('usuarios')
          .doc(usuario.uid)
          .get();

      final datos = doc.data() ?? {};

      if (!mounted) return;

      setState(() {
        notificaciones = datos['notificacionesActivas'] ?? true;

        cargando = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        cargando = false;
      });
    }
  }

  Future<void> cambiarNotificaciones(bool value) async {
    final usuario = _auth.currentUser;

    if (usuario == null) return;

    setState(() {
      actualizandoNotificaciones = true;
    });

    try {
      if (value) {
        final permiso = await NotificacionService.solicitarPermiso();

        if (!permiso) {
          if (!mounted) return;

          mostrarMensaje('No se concedió permiso para mostrar notificaciones.');

          return;
        }

        await _recordatorioService.reprogramarRecordatoriosActivos();
      } else {
        await NotificacionService.cancelarTodas();
      }

      await _firestore.collection('usuarios').doc(usuario.uid).update({
        'notificacionesActivas': value,

        'fechaActualizacion': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        notificaciones = value;
      });

      mostrarMensaje(
        value ? 'Notificaciones activadas.' : 'Notificaciones desactivadas.',
      );
    } catch (e) {
      if (!mounted) return;

      mostrarMensaje('No se pudo cambiar la configuración.');
    } finally {
      if (mounted) {
        setState(() {
          actualizandoNotificaciones = false;
        });
      }
    }
  }

  Future<void> cambiarPassword() async {
    final usuario = _auth.currentUser;

    final correo = usuario?.email;

    if (correo == null || correo.isEmpty) {
      mostrarMensaje('No se encontró el correo de la cuenta.');

      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text('Cambiar contraseña'),

          content: Text(
            'Enviaremos un enlace a:\n\n$correo\n\npara que puedas crear una nueva contraseña.',
          ),

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

              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: correo);

      if (!mounted) return;

      mostrarMensaje('Revisa tu correo para cambiar la contraseña.');
    } on FirebaseAuthException catch (e) {
      mostrarMensaje(e.message ?? 'No se pudo enviar el correo.');
    }
  }

  void mostrarAcercaDe() {
    showAboutDialog(
      context: context,

      applicationName: 'GlucoVida',

      applicationVersion: '1.0.0',

      applicationIcon: Image.asset(
        'assets/images/glucovida_icon.png',
        width: 60,
        height: 60,
      ),

      children: const [
        Text(
          'Aplicación para el seguimiento de glucosa, recordatorios y apoyo al cuidado de la salud.',
        ),
        SizedBox(height: 10),
        Text('Controla hoy, vive mejor mañana.'),
      ],
    );
  }

  void mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(title: const Text('Configuración')),

      body: ListView(
        padding: const EdgeInsets.all(18),

        children: [
          const Text(
            'Preferencias',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: SwitchListTile(
              value: notificaciones,

              onChanged: actualizandoNotificaciones
                  ? null
                  : cambiarNotificaciones,

              activeThumbColor: AppColors.primary,

              secondary: actualizandoNotificaciones
                  ? const SizedBox(
                      width: 23,
                      height: 23,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.primary,
                    ),

              title: const Text('Notificaciones'),

              subtitle: Text(
                notificaciones
                    ? 'Recordatorios y avisos activados'
                    : 'Recordatorios y avisos desactivados',
              ),
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'Cuenta y seguridad',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: const Icon(Icons.lock_outline, color: AppColors.primary),

              title: const Text('Cambiar contraseña'),

              subtitle: const Text('Recibe un enlace por correo'),

              trailing: const Icon(Icons.chevron_right),

              onTap: cambiarPassword,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'Aplicación',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: Image.asset(
                'assets/images/glucovida_icon.png',
                width: 36,
                height: 36,
              ),

              title: const Text('Acerca de GlucoVida'),

              subtitle: const Text('Versión 1.0.0'),

              trailing: const Icon(Icons.chevron_right),

              onTap: mostrarAcercaDe,
            ),
          ),
        ],
      ),
    );
  }
}
