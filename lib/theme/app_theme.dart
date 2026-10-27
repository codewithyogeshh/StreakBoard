import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static bool isDarkTheme = true;

  // Dark palette constants
  static const Color darkBg = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceLight = Color(0xFF334155);
  static const Color darkBorder = Color(0xFF475569);
  static const Color darkBorderSubtle = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // Clean Light palette tokens
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceLight = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightBorderSubtle = Color(0xFFCBD5E1);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Dynamic Theme Getters - Switch seamlessly in real-time
  static Color get bg => isDarkTheme ? darkBg : lightBg;
  static Color get surface => isDarkTheme ? darkSurface : lightSurface;
  static Color get surfaceLight => isDarkTheme ? darkSurfaceLight : lightSurfaceLight;
  static Color get border => isDarkTheme ? darkBorder : lightBorder;
  static Color get borderSubtle => isDarkTheme ? darkBorderSubtle : lightBorderSubtle;
  static Color get textPrimary => isDarkTheme ? darkTextPrimary : lightTextPrimary;
  static Color get textSecondary => isDarkTheme ? darkTextSecondary : lightTextSecondary;
  static Color get textMuted => isDarkTheme ? darkTextMuted : lightTextMuted;

  static const Color borderHighlight = Color(0xFFFFFFFF);
  
  // Professional accent tokens (no neon colors)
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color primaryGreen = Color(0xFF10B981);
  static const Color primaryOrange = Color(0xFFFB923C);
  static const Color primaryRed = Color(0xFFEF4444);
  static const Color primaryTeal = Color(0xFF14B8A6);
  
  // Compatibility aliases for legacy tokens
  static const Color teal = primaryTeal;
  static const Color purple = primaryPurple;
  static const Color pink = primaryRed;
  static const Color amber = primaryOrange;
  static const Color green = primaryGreen;
  static const Color blue = primaryBlue;
  
  static const List<Color> habitColors = [
    Color(0xFF3B82F6),    // Blue
    Color(0xFF8B5CF6),    // Purple
    Color(0xFF10B981),    // Green
    Color(0xFFFB923C),    // Orange
    Color(0xFFEC4899),    // Pink
    Color(0xFF14B8A6),    // Teal
  ];
  
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      fontFamily: GoogleFonts.inter().fontFamily,
      primaryColor: primaryBlue,
      cardColor: darkSurface,
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: primaryPurple,
        surface: darkSurface,
        error: primaryRed,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
          color: darkTextPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: darkTextPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: darkTextPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w400,
          color: darkTextPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: darkTextSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: darkTextMuted,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: darkBorderSubtle,
        thickness: 1,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      fontFamily: GoogleFonts.inter().fontFamily,
      primaryColor: primaryBlue,
      cardColor: lightSurface,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: primaryPurple,
        surface: lightSurface,
        error: primaryRed,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
          color: lightTextPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: lightTextPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: lightTextPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w400,
          color: lightTextPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: lightTextSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: lightTextMuted,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: lightBorder,
        thickness: 1,
      ),
    );
  }

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color getBg(BuildContext context) =>
      isDark(context) ? bg : lightBg;

  static Color getSurface(BuildContext context) =>
      isDark(context) ? surface : lightSurface;

  static Color getSurfaceLight(BuildContext context) =>
      isDark(context) ? surfaceLight : lightSurfaceLight;

  static Color getBorder(BuildContext context) =>
      isDark(context) ? border : lightBorder;

  static Color getTextPrimary(BuildContext context) =>
      isDark(context) ? textPrimary : lightTextPrimary;

  static Color getTextSecondary(BuildContext context) =>
      isDark(context) ? textSecondary : lightTextSecondary;

  static Color getTextMuted(BuildContext context) =>
      isDark(context) ? textMuted : lightTextMuted;
  
  // Box decoration utilities for clean modern cards with subtle shadow
  static BoxDecoration cardDecoration({
    Color? color,
    BorderRadius? borderRadius,
    Border? border,
    bool glow = false,
    Color? glowColor,
    bool? isDark,
  }) {
    final effectiveDark = isDark ?? isDarkTheme;
    return BoxDecoration(
      color: color ?? (effectiveDark ? darkSurface : lightSurface),
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      border: border ??
          Border.all(
            color: effectiveDark ? darkBorder : lightBorder,
            width: 1,
          ),
      boxShadow: [
        BoxShadow(
          color: effectiveDark
              ? Colors.black.withOpacity(0.3)
              : Colors.black.withOpacity(0.06),
          offset: const Offset(0, 4),
          blurRadius: 12,
          spreadRadius: -2,
        ),
      ],
    );
  }
  
  // Clean background without ambient neon lighting
  static Widget ambientBackground({required Widget child, bool? isDark}) {
    final effectiveDark = isDark ?? isDarkTheme;
    return Stack(
      children: [
        Positioned(
          top: -120,
          left: 0,
          right: 0,
          height: 380,
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.6),
                radius: 0.9,
                colors: effectiveDark
                    ? const [
                        Color(0x0F3B82F6),
                        Color(0x0A8B5CF6),
                        Colors.transparent,
                      ]
                    : const [
                        Color(0x123B82F6),
                        Color(0x088B5CF6),
                        Colors.transparent,
                      ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

