import 'package:flutter/material.dart';

class AppTheme {
  // Warna Utama (Palet Ramah Siswa & Aksen Keselamatan Siaga Bencana)
  static const Color primaryColor =
      Color(0xFF006699); // Blue Oceanic (Maluku Utara)
  static const Color secondaryColor =
      Color(0xFFFF8C00); // Safety Orange (Mitigasi Gempa)
  static const Color accentColor = Color(0xFF2EC4B6); // Tosca Bahari
  static const Color dangerColor = Color(0xFFE63946); // Merah Darurat
  static const Color successColor = Color(0xFF2A9D8F); // Hijau Aman
  static const Color warningColor = Color(0xFFE9C46A); // Kuning Waspada

  static const Color backgroundColor = Color(0xFFF4F8FA);
  static const Color surfaceColor = Colors.white;
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: dangerColor,
        surface: surfaceColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          backgroundColor: secondaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
