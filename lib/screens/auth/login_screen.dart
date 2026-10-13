import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController correoController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool ocultarPassword = true;
  bool recordar = false;
  bool cargando = false;

  @override
  void dispose() {
    correoController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> iniciarSesion() async {
    final correo = correoController.text.trim();
    final password = passwordController.text;

    if (correo.isEmpty || password.isEmpty) {
      mostrarMensaje('Ingresa tu correo y contraseña');
      return;
    }

    setState(() {
      cargando = true;
    });

    try {
      await _authService.iniciarSesion(correo: correo, password: password);

      // AuthGate detectará automáticamente
      // el usuario y su rol.
    } on FirebaseAuthException catch (e) {
      String mensaje = 'No se pudo iniciar sesión';

      if (e.code == 'invalid-email') {
        mensaje = 'El correo no es válido';
      } else if (e.code == 'invalid-credential') {
        mensaje = 'Correo o contraseña incorrectos';
      } else if (e.code == 'user-disabled') {
        mensaje = 'Esta cuenta está deshabilitada';
      } else if (e.code == 'too-many-requests') {
        mensaje = 'Demasiados intentos. Intenta más tarde';
      }

      mostrarMensaje(mensaje);
    } catch (e) {
      mostrarMensaje(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  void mostrarMensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),

                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 34),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: constraints.maxHeight * 0.15),

                      // ============================
                      // LOGO
                      // ============================
                      Row(
                        children: [
                          const SizedBox(width: 32),

                          Center(
                            child: Image.asset(
                              'assets/images/glucovida_horizontal.png',
                              width: 240,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ============================
                      // TÍTULO
                      // ============================
                      const Text(
                        'Bienvenido de vuelta',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),

                      const SizedBox(height: 7),

                      const Text(
                        'Inicia sesión para continuar con tu seguimiento.',
                        style: TextStyle(
                          fontSize: 13.5,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 34),

                      // ============================
                      // CORREO
                      // ============================
                      const Text(
                        'Correo electrónico',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextField(
                        controller: correoController,
                        keyboardType: TextInputType.emailAddress,

                        decoration: InputDecoration(
                          hintText: 'tu@email.com',

                          hintStyle: const TextStyle(
                            color: AppColors.hint,
                            fontSize: 13,
                          ),

                          prefixIcon: const Icon(
                            Icons.mail_outline_rounded,
                            color: AppColors.icon,
                            size: 20,
                          ),

                          filled: true,
                          fillColor: AppColors.inputBackground,

                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 17,
                            horizontal: 15,
                          ),

                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ============================
                      // CONTRASEÑA + OLVIDASTE
                      // ============================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Contraseña',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),

                          GestureDetector(
                            onTap: () {
                              // Después conectamos
                              // recuperación Firebase.
                            },
                            child: const Text(
                              '¿Olvidaste tu contraseña?',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      TextField(
                        controller: passwordController,
                        obscureText: ocultarPassword,

                        decoration: InputDecoration(
                          hintText: '••••••••',

                          hintStyle: const TextStyle(color: AppColors.hint),

                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: AppColors.icon,
                            size: 20,
                          ),

                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                ocultarPassword = !ocultarPassword;
                              });
                            },

                            icon: Icon(
                              ocultarPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.icon,
                              size: 20,
                            ),
                          ),

                          filled: true,
                          fillColor: AppColors.inputBackground,

                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 17,
                            horizontal: 15,
                          ),

                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ============================
                      // RECORDARME
                      // ============================
                      Row(
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,

                            child: Checkbox(
                              value: recordar,

                              activeColor: AppColors.primary,

                              visualDensity: VisualDensity.compact,

                              onChanged: (value) {
                                setState(() {
                                  recordar = value ?? false;
                                });
                              },
                            ),
                          ),

                          const SizedBox(width: 7),

                          const Text(
                            'Recordarme',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // ============================
                      // BOTÓN CON DEGRADADO
                      // ============================
                      Container(
                        height: 54,

                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 25, 98, 215),
                              Color.fromARGB(255, 21, 156, 84),
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
                            borderRadius: BorderRadius.circular(10),

                            onTap: cargando ? null : iniciarSesion,

                            child: Center(
                              child: cargando
                                  ? const SizedBox(
                                      width: 23,
                                      height: 23,

                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Iniciar sesión',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 27),

                      // ============================
                      // CREAR CUENTA
                      // ============================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '¿No tienes cuenta? ',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                            ),
                          ),

                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              );
                            },

                            child: const Text(
                              'Crear cuenta',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 35),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
