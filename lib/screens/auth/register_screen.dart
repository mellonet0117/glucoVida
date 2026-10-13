import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nombreController = TextEditingController();

  final apellidosController = TextEditingController();

  final correoController = TextEditingController();

  final passwordController = TextEditingController();

  final confirmarController = TextEditingController();

  final AuthService _authService = AuthService();

  bool aceptarTerminos = false;
  bool ocultarPassword = true;
  bool ocultarConfirmacion = true;
  bool cargando = false;

  String? errorNombre;
  String? errorApellidos;
  String? errorCorreo;
  String? errorPassword;
  String? errorConfirmacion;
  String? errorTerminos;

  @override
  void dispose() {
    nombreController.dispose();
    apellidosController.dispose();
    correoController.dispose();
    passwordController.dispose();
    confirmarController.dispose();

    super.dispose();
  }

  bool validarFormulario() {
    setState(() {
      errorNombre = null;
      errorApellidos = null;
      errorCorreo = null;
      errorPassword = null;
      errorConfirmacion = null;
      errorTerminos = null;
    });

    bool valido = true;

    if (nombreController.text.trim().isEmpty) {
      errorNombre = 'Campo requerido';
      valido = false;
    }

    if (apellidosController.text.trim().isEmpty) {
      errorApellidos = 'Campo requerido';
      valido = false;
    }

    final correo = correoController.text.trim();

    if (correo.isEmpty) {
      errorCorreo = 'Campo requerido';
      valido = false;
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(correo)) {
      errorCorreo = 'Correo electrónico inválido';
      valido = false;
    }

    if (passwordController.text.isEmpty) {
      errorPassword = 'Campo requerido';
      valido = false;
    } else if (passwordController.text.length < 6) {
      errorPassword = 'Mínimo 6 caracteres';
      valido = false;
    }

    if (confirmarController.text != passwordController.text) {
      errorConfirmacion = 'Las contraseñas no coinciden';
      valido = false;
    }

    if (!aceptarTerminos) {
      errorTerminos = 'Debes aceptar los términos';
      valido = false;
    }

    setState(() {});

    return valido;
  }

  Future<void> registrar() async {
    if (!validarFormulario()) {
      return;
    }

    setState(() {
      cargando = true;
    });

    try {
      await _authService.registrarPaciente(
        nombre: nombreController.text.trim(),
        apellidos: apellidosController.text.trim(),
        correo: correoController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cuenta creada correctamente. Ahora inicia sesión.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Regresamos y AuthGate detectará
      // automáticamente al nuevo usuario.
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String mensaje = 'No se pudo crear la cuenta';

      if (e.code == 'email-already-in-use') {
        mensaje = 'Este correo ya está registrado';
      } else if (e.code == 'invalid-email') {
        mensaje = 'El correo electrónico no es válido';
      } else if (e.code == 'weak-password') {
        mensaje = 'La contraseña es demasiado débil';
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), behavior: SnackBarBehavior.floating),
    );
  }

  InputDecoration inputDecoration({
    required String hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool error = false,
  }) {
    return InputDecoration(
      hintText: hint,

      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),

      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,

      filled: true,

      // En el Figma los inputs son gris claro
      fillColor: const Color(0xFFF8FAFC),

      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: error ? const Color(0xFFFCA5A5) : AppColors.border,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
    );
  }

  Widget etiqueta(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF334155),
      ),
    );
  }

  Widget mensajeError(String? mensaje) {
    if (mensaje == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Text(
        mensaje,
        style: const TextStyle(color: AppColors.danger, fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 30),

            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),

              child: Column(
                children: [
                  // ==========================
                  // LOGO
                  // ==========================

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 2, height: 2),

                      const SizedBox(width: 5),

                      Center(
                        child: Image.asset(
                          'assets/images/glucovida_horizontal.png',
                          width: 240,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // ==========================
                  // TARJETA
                  // ==========================
                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(26),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(18),

                      border: Border.all(color: const Color(0xFFF1F5F9)),

                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0D000000),
                          blurRadius: 12,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Crear cuenta',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 5),

                        const Text(
                          'Comienza tu camino hacia una vida más saludable.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 26),

                        // ==================
                        // NOMBRE
                        // ==================
                        etiqueta('Nombre'),

                        const SizedBox(height: 7),

                        TextField(
                          controller: nombreController,

                          textCapitalization: TextCapitalization.words,

                          decoration: inputDecoration(
                            hint: 'María',
                            error: errorNombre != null,
                          ),
                        ),

                        mensajeError(errorNombre),

                        const SizedBox(height: 17),

                        // ==================
                        // APELLIDOS
                        // ==================
                        etiqueta('Apellidos'),

                        const SizedBox(height: 7),

                        TextField(
                          controller: apellidosController,

                          textCapitalization: TextCapitalization.words,

                          decoration: inputDecoration(
                            hint: 'García López',
                            error: errorApellidos != null,
                          ),
                        ),

                        mensajeError(errorApellidos),

                        const SizedBox(height: 17),

                        // ==================
                        // CORREO
                        // ==================
                        etiqueta('Correo electrónico'),

                        const SizedBox(height: 7),

                        TextField(
                          controller: correoController,

                          keyboardType: TextInputType.emailAddress,

                          decoration: inputDecoration(
                            hint: 'tu@email.com',

                            error: errorCorreo != null,

                            prefixIcon: const Icon(
                              Icons.mail_outline_rounded,
                              size: 19,
                              color: Color.fromARGB(255, 121, 148, 186),
                            ),
                          ),
                        ),

                        mensajeError(errorCorreo),

                        const SizedBox(height: 17),

                        // ==================
                        // CONTRASEÑA
                        // ==================
                        etiqueta('Contraseña'),

                        const SizedBox(height: 7),

                        TextField(
                          controller: passwordController,

                          obscureText: ocultarPassword,

                          decoration: inputDecoration(
                            hint: '••••••••',

                            error: errorPassword != null,

                            prefixIcon: const Icon(
                              Icons.lock_outline_rounded,
                              size: 19,
                              color: AppColors.textMuted,
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
                                size: 19,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),

                        mensajeError(errorPassword),

                        const SizedBox(height: 17),

                        // ==================
                        // CONFIRMAR
                        // ==================
                        etiqueta('Confirmar contraseña'),

                        const SizedBox(height: 7),

                        TextField(
                          controller: confirmarController,

                          obscureText: ocultarConfirmacion,

                          decoration: inputDecoration(
                            hint: '••••••••',

                            error: errorConfirmacion != null,

                            prefixIcon: const Icon(
                              Icons.lock_outline_rounded,
                              size: 19,
                              color: AppColors.textMuted,
                            ),

                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  ocultarConfirmacion = !ocultarConfirmacion;
                                });
                              },

                              icon: Icon(
                                ocultarConfirmacion
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 19,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),

                        mensajeError(errorConfirmacion),

                        const SizedBox(height: 20),

                        // ==================
                        // TÉRMINOS
                        // ==================
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,

                              child: Checkbox(
                                value: aceptarTerminos,

                                activeColor: AppColors.primary,

                                onChanged: (value) {
                                  setState(() {
                                    aceptarTerminos = value ?? false;

                                    if (aceptarTerminos) {
                                      errorTerminos = null;
                                    }
                                  });
                                },
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Wrap(
                                children: const [
                                  Text(
                                    'Acepto los ',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),

                                  Text(
                                    'Términos y condiciones',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),

                                  Text(
                                    ' y la ',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),

                                  Text(
                                    'Política de privacidad',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        mensajeError(errorTerminos),

                        const SizedBox(height: 24),

                        // ==================
                        // CREAR CUENTA
                        // ==================
                        Container(
                          height: 52,

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
                                color: AppColors.primary.withValues(
                                  alpha: 0.25,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),

                          child: Material(
                            color: Colors.transparent,

                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),

                              onTap: cargando ? null : registrar,

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
                                        'Crear cuenta',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // ==================
                        // LOGIN
                        // ==================
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '¿Ya tienes cuenta? ',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),

                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },

                              child: const Text(
                                'Iniciar sesión',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
