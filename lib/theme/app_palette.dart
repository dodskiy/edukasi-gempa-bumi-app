import 'package:flutter/material.dart';

/// Palet warna bersama untuk Splash Screen & Home Screen (SiGempa Malut).
///
/// Semua layar memakai sumber warna yang sama supaya identitas visual
/// aplikasi tetap konsisten: langit Maluku yang cerah, matahari kuning,
/// karang/oranye khas gempa, hijau siaga, dan latar krem yang ramah anak.
class AppPalette {
  const AppPalette._();

  // ---- Langit & laut -------------------------------------------------
  static const Color sky = Color(0xFF6FC6EE);
  static const Color skyDeep = Color(0xFF3FA8DA);
  static const Color skySoft = Color(0xFFBFE9FB);
  static const Color skyMist = Color(0xFFE9F9FF);
  static const Color seaFoam = Color(0xFFDFF6FF);

  // ---- Matahari / lencana -------------------------------------------
  static const Color sunny = Color(0xFFFFC94D);
  static const Color sunnyDeep = Color(0xFFF2A70B);
  static const Color sunnySoft = Color(0xFFFFF3D0);

  // ---- Karang / aksen utama (gempa) ---------------------------------
  static const Color coral = Color(0xFFFF8B7A);
  static const Color coralDeep = Color(0xFFF16249);
  static const Color coralDark = Color(0xFFC4400E);
  static const Color coralSoft = Color(0xFFFFE9E4);

  // ---- Hijau siaga ---------------------------------------------------
  static const Color mint = Color(0xFF6FDBA8);
  static const Color mintDeep = Color(0xFF3DBE85);
  static const Color forest = Color(0xFF2E8B57);

  // ---- Ungu edukasi --------------------------------------------------
  static const Color grape = Color(0xFFB79CF0);
  static const Color grapeDeep = Color(0xFF7048C4);

  // ---- Netral --------------------------------------------------------
  static const Color cream = Color(0xFFFFFBF1);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color navy = Color(0xFF31355A);
  static const Color inkSoft = Color(0xFF8385A3);
  static const Color lineBorder = Color(0xFFF2ECDA);
  static const Color shadow3D = Color(0xFFE9E2CE);

  // ---- Gradien siap pakai -------------------------------------------
  static const LinearGradient headerGradient = LinearGradient(
    colors: [sky, skyDeep],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient skyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE9F9FF), Color(0xFFC7EEFF), Color(0xFF9ADCF7)],
    stops: [0.0, 0.45, 0.80],
  );

  static const LinearGradient coralGradient = LinearGradient(
    colors: [coralDeep, Color(0xFFFF7A59)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunnyGradient = LinearGradient(
    colors: [Color(0xFFFFD98A), sunnyDeep],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient mintGradient = LinearGradient(
    colors: [Color(0xFF8CE6B2), mintDeep],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ---- Bayangan standar ---------------------------------------------
  static const BoxShadow softShadow = BoxShadow(
    color: Color(0x1A31355A),
    blurRadius: 18,
    offset: Offset(0, 10),
  );

  static const BoxShadow card3DShadow = BoxShadow(
    color: shadow3D,
    offset: Offset(0, 5),
    blurRadius: 0,
  );

  static const BoxShadow navShadow = BoxShadow(
    color: Color(0x1F31355A),
    blurRadius: 18,
    offset: Offset(0, 8),
  );
}
