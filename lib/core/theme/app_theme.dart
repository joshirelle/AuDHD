import 'package:flutter/material.dart';

/// Iisang pinagmumulan ng kulay ng app — **Neuro-Calm (Low-Sensory)**.
///
/// Walang `Color(0xFF...)` na literal sa labas ng file na ito. Doon lang
/// nagagawang palitan ang buong tema sa isang lugar sa halip na habulin ang
/// bawat screen.
///
/// Mababa ang saturation ng mga palaman para bawasan ang sensory overload,
/// pero pinananatili sa 4.5:1 pataas ang lahat ng teksto laban sa pinatungan
/// nito — ang "low-sensory" ay tungkol sa palaman, hindi sa nababasa.
class AppColors {
  // --- Base ---
  static const Color background = Color(0xFFF4F1EA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF3A3630);

  /// Pangalawang teksto. Malamig ang tono para tumugma sa background, at
  /// pasado pa rin sa 4.5:1 laban dito at sa puti.
  static const Color textMuted = Color(0xFF5F6B70);

  /// Guhit at hindi aktibong palamuti — hindi ito para sa teksto.
  static const Color divider = Color(0xFFDFD9CE);
  static const Color logoGreen = Color(0xFF4F6F52);
  
  // --- Pastel na palaman ---
  static const Color skyBlue = Color(0xFFAEC9C5);
  static const Color skyBlueLight = Color(0xFFDCE8E6);
  static const Color mintGreen = Color(0xFFCBD9BE);
  static const Color butterYellow = Color(0xFFEDE0C4);
  static const Color coralPeach = Color(0xFFE8C4B8);
  static const Color lavender = Color(0xFFDFD9E4);

  /// Tinta: madilim na teksto at icon sa ibabaw ng katapat na pastel sa itaas.
  /// Magkapares ang mga ito — kapag pinalitan ang pastel, palitan din ang tinta.
  static const Color mintInk = Color(0xFF2F4A33);
  static const Color butterInk = Color(0xFF5C4A21);
  static const Color skyInk = Color(0xFF26494A);
  static const Color coralInk = Color(0xFF6B3A2A);

  // --- Estado ---
  static const Color danger = Color(0xFFA8443F);
  static const Color warning = Color(0xFF8A672B);
  static const Color success = Color(0xFF3D6B4A);

  // --- Malalambot na palaman ng card ---
  static const Color tintSuccess = Color(0xFFE3EBDE);
  static const Color tintDanger = Color(0xFFF3E7E4);
  static const Color tintWarm = Color(0xFFF5EBE0);
  static const Color tintTeal = Color(0xFFE4EDEB);
  static const Color tintGold = Color(0xFFF1EADA);
  static const Color tintBlue = Color(0xFFE8EDEF);

  // Kasarian
  static const Color genderBlue = Color(0xFF4A7A8C);
  static const Color genderPink = Color(0xFFB3717F);

  // Bituin / gantimpala
  static const Color starGold = Color(0xFFB8894A);
  static const Color starGoldLight = Color(0xFFD9B36A);
  static const Color starGoldDeep = Color(0xFFC79A48);

  // Uri ng gawain at pagsusuri
  static const Color autismPurple = Color(0xFF7A6B8F);
  static const Color adhdBlue = Color(0xFF4A7A8C);
  static const Color vanderbiltBlue = Color(0xFF5A7D94);
  static const Color historyPurple = Color(0xFF7E7391);

  /// Pangkalahatang accent ng UI — nav, header, at progress.
  static const Color accentBlue = Color(0xFF43707F);
}

class AppRadius {
  static const double card = 24.0;
  static const double button = 30.0;
}

class AppTheme {
  static ThemeData get light => ThemeData(
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Nunito',
    useMaterial3: true,
    // Kung wala ito, lila ang default ng Material sa anumang widget na
    // hindi tahasang binigyan ng kulay.
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.logoGreen).copyWith(
      primary: AppColors.logoGreen,
      onPrimary: Colors.white,
      secondary: AppColors.skyBlue,
      onSecondary: AppColors.textDark,
      surface: AppColors.surface,
      onSurface: AppColors.textDark,
      error: AppColors.danger,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      titleTextStyle: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.textDark,
      ),
    ),
  );
}