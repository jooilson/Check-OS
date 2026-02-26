import 'package:flutter/material.dart';

/// Cores padronizadas da aplicação.
/// Facilita manutenção e alterações globais de cores.
class AppColors {
  AppColors._();

  // ============================================
  // CORES PRIMÁRIAS (Baseadas no seedColor do tema)
  // ============================================
  static const Color primarySeed = Color(0xFF3A38CF);
  static const Color primary = Color(0xFF3A38CF);
  static const Color primaryLight = Color(0xFF6B66FF);
  static const Color primaryDark = Color(0xFF00009E);

  // ============================================
  // CORES SECUNDÁRIAS
  // ============================================
  static const Color secondary = Color(0xFF6200EE);
  static const Color secondaryLight = Color(0xFF9D46FF);
  static const Color secondaryDark = Color(0xFF0A00B6);

  // ============================================
  // CORES DE SUPERFÍCIE
  // ============================================
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color background = Color(0xFFFFFFFF);

  // ============================================
  // CORES DE TEXTO
  // ============================================
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1C1B1F);
  static const Color onSurfaceVariant = Color(0xFF49454F);

  // ============================================
  // CORES DE ESTADO
  // ============================================
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color error = Color(0xFFB00020);
  static const Color errorLight = Color(0xFFFCE4EC);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);

  // ============================================
  // CORES DE STATUS DE OS
  // ============================================
  static const Color statusFinalizado = Color(0xFF4CAF50);
  static const Color statusPendente = Color(0xFFF44336);
  static const Color statusEmAndamento = Color(0xFF3A38CF);

  // ============================================
  // CORES DE FUNDO (para dark theme)
  // ============================================
  static const Color darkSurface = Color(0xFF1C1B1F);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurfaceVariant = Color(0xFF2D2D2D);

  // ============================================
  // CORES DIVERSAS
  // ============================================
  static const Color divider = Color(0xFFE0E0E0);
  static const Color disabled = Color(0xFFBDBDBD);
  static const Color shadow = Color(0x1A000000);
  static const Color overlay = Color(0x80000000);
}

