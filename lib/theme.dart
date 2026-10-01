import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {

  static const Color spaceBlack = Color(0xFF0B1426);
  static const Color deepSpaceBlack = Color(0xFF0E1A30);
  static const Color deepSpace = Color(0xFF142240);
  static const Color panelBg = Color(0xFF1A2C50);
  static const Color panelBorder = Color(0xFF2F4D7E);
  static const Color subtleBlue = Color(0xFF4A6AA0);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFDCE6F5);
  static const Color textDim = Color(0xFFA8B7D2);
  static const Color accent = Color(0xFF7CC4FF);
  static const Color accentGlow = Color(0xFFA0D6FF);
  static const Color methane = Color(0xFFFF8A4F);
  static const Color methaneGlow = Color(0xFFFFB088);
  static const Color warning = Color(0xFFFFCE5C);
  static const Color success = Color(0xFF7CF0BC);

  static ThemeData build() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: spaceBlack,
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      colorScheme: const ColorScheme.dark(
        surface: panelBg,
        primary: accent,
        secondary: methane,
      ),
    );
  }
}

TextStyle cinTitle(double size, {FontWeight w = FontWeight.w600}) =>
    GoogleFonts.orbitron(
      fontSize: size,
      fontWeight: w,
      color: AppTheme.textPrimary,
      letterSpacing: size > 40 ? 8 : 3,
      height: 1.1,
    );

TextStyle cinBody(double size, {FontWeight w = FontWeight.w500, Color? c}) =>
    GoogleFonts.inter(
      fontSize: size,
      fontWeight: w,
      color: c ?? AppTheme.textSecondary,
      letterSpacing: 0.4,
      height: 1.5,
    );

TextStyle monoText(double size, {Color? c}) => GoogleFonts.shareTechMono(
      fontSize: size,
      fontWeight: FontWeight.w400,
      color: c ?? AppTheme.textSecondary,
      letterSpacing: 1.5,
    );
