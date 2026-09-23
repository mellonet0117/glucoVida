import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Detecta cambios de sesión
  Stream<User?> get cambiosSesion => _auth.authStateChanges();

  // Usuario actual
  User? get usuarioActual => _auth.currentUser;

  // =========================================
  // REGISTRAR PACIENTE
  // =========================================
  Future<void> registrarPaciente({
    required String nombre,
    required String apellidos,
    required String correo,
    required String password,
  }) async {
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: correo,
      password: password,
    );

    final usuario = credential.user;

    if (usuario == null) {
      throw Exception('No se pudo crear el usuario.');
    }

    try {
      final nombreCompleto = '$nombre $apellidos'.trim();

      await usuario.updateDisplayName(nombreCompleto);

      await _firestore.collection('usuarios').doc(usuario.uid).set({
        'uid': usuario.uid,
        'nombre': nombre,
        'apellidos': apellidos,
        'nombreCompleto': nombreCompleto,
        'correo': correo,
        'rol': 'paciente',
        'activo': true,
        'fechaRegistro': FieldValue.serverTimestamp(),
      });

      // Firebase inicia sesión automáticamente
      // después del registro.
      // La cerramos para que el usuario
      // tenga que iniciar sesión manualmente.
      await _auth.signOut();
    } catch (e) {
      try {
        await usuario.delete();
      } catch (_) {}

      rethrow;
    }
  }

  // =========================================
  // INICIAR SESIÓN
  // =========================================
  Future<void> iniciarSesion({
    required String correo,
    required String password,
  }) async {
    UserCredential credential = await _auth.signInWithEmailAndPassword(
      email: correo,
      password: password,
    );

    final usuario = credential.user;

    if (usuario == null) {
      throw Exception('No se pudo iniciar sesión.');
    }

    final documento = await _firestore
        .collection('usuarios')
        .doc(usuario.uid)
        .get();

    if (!documento.exists) {
      await cerrarSesion();

      throw Exception('Este usuario no tiene perfil en GlucoVida.');
    }

    final datos = documento.data()!;

    if (datos['activo'] == false) {
      await cerrarSesion();

      throw Exception('Esta cuenta se encuentra desactivada.');
    }
  }

  // =========================================
  // OBTENER ROL
  // =========================================
  Future<String> obtenerRolActual() async {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw Exception('No existe una sesión activa.');
    }

    final documento = await _firestore
        .collection('usuarios')
        .doc(usuario.uid)
        .get();

    if (!documento.exists) {
      throw Exception('No se encontró el perfil del usuario.');
    }

    final datos = documento.data()!;

    if (datos['activo'] == false) {
      await cerrarSesion();

      throw Exception('La cuenta está desactivada.');
    }

    final rol = datos['rol']?.toString();

    if (rol == null || rol.isEmpty) {
      throw Exception('El usuario no tiene un rol asignado.');
    }

    return rol;
  }

  // =========================================
  // CERRAR SESIÓN
  // =========================================
  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }
}
