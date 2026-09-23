import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Identidad GlucoVida
  static const Color primary = Color(0xFF0D9488);
  static const Color primaryLight = Color(0xFF14B8A6);
  static const Color primaryDark = Color(0xFF0F766E);

  static const Color accent = Color(0xFF0284C7);
  static const Color accentLight = Color(0xFF38BDF8);

  // Estados
  static const Color danger = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);

  // Fondos
  static const Color background = Color(0xFFF0FAFA);
  static const Color surface = Colors.white;

  // Textos
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Bordes
  static const Color border = Color(0xFFE2E8F0);

  // Inputs
  static const Color inputBackground = Colors.white;
  static const Color hint = Color(0xFF94A3B8);
  static const Color icon = Color(0xFF94A3B8);

  // Estados de glucosa
  static const Color normalBackground = Color(0xFFDCFCE7);
  static const Color normalText = Color(0xFF166534);

  static const Color highBackground = Color(0xFFFEE2E2);
  static const Color highText = Color(0xFF991B1B);

  static const Color lowBackground = Color(0xFFFEF3C7);
  static const Color lowText = Color(0xFF92400E);

  // Gradiente principal
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, accent],
  );
}
