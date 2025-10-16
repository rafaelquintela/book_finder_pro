import 'package:flutter/material.dart';

// Definindo a paleta de cores primária para o branding (Book Finder Pro)
const Color primaryProColor = Color(0xFF1A73E8); // Azul Google
const Color secondaryProColor = Color(0xFF5CB85C); // Verde Ação

/// Constantes de Estilo para o Design System
class AppTheme {
  // Configuração do Tema Claro (Material 3)
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryProColor,
      brightness: Brightness.light,
      primary: primaryProColor,
      secondary: secondaryProColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: primaryProColor,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: Colors.grey.shade100,
    ),
  );

  // Configuração do Tema Escuro (Material 3)
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryProColor,
      brightness: Brightness.dark,
      primary: primaryProColor,
      secondary: secondaryProColor,
      background: const Color(0xFF121212),
      surface: const Color(0xFF1E1E1E),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121212),
      foregroundColor: primaryProColor,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: const Color(0xFF2C2C2C),
    ),
  );
}

/// Helper para configurações de cores.
class ProColor {
  static const Color primary = primaryProColor;
  static const Color secondary = secondaryProColor;
  static const Color accent = Color(0xFFFFCC00); // Amarelo de destaque
  static const Color error = Color(0xFFEF5350);
}
