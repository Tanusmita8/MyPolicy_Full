import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App theme configuration with HDFC brand colors and Material 3
class AppTheme {
  // HDFC Brand Colors
  static const Color primaryBlue = Color(0xFF2E5AAC);
  static const Color backgroundGrey = Color(0xFFF3F4F6);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color borderBlue = Color(0xFFE3E8F0);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color statusActive = Color(0xFF10B981);
  static const Color statusDue = Color(0xFFFBBF24);
  static const Color statusexpiringsoon = Color.fromARGB(255, 191, 187, 160);
  static const Color statusExpired = Color.fromARGB(255, 251, 25, 4);
  static const Color primaryRed = Color(0xFFD32F2F);
  static const Color darkestBlue = Color(0xFF003366);
  
  // Spacing System
  static const double spacing2 = 2.0;
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing48 = 48.0;
  
  // Border Radius
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 20.0;
  static const double radiusPill = 30.0;
  
  // Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 15,
      offset: const Offset(0, 4),
    ),
  ];

  /// Main theme data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        surface: backgroundGrey,
        onSurface: textDark,
      ),
      scaffoldBackgroundColor: backgroundGrey,
      
      // Typography using Poppins
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        // Large welcome text
        headlineLarge: GoogleFonts.poppins(
          fontSize: 22, // Reduced from 24
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        // Mobile headers
        headlineSmall: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        // Card titles
        titleLarge: GoogleFonts.poppins(
          fontSize: 14, // Reduced from 15
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        // Policy names
        titleMedium: GoogleFonts.poppins(
          fontSize: 13, // Reduced from 14
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        // Body text
        bodyMedium: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.normal,
          color: textGrey,
        ),
        // Small text (policy IDs, labels)
        bodySmall: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.normal,
          color: textGrey,
        ),
        // Numbers/values
        labelLarge: GoogleFonts.poppins(
          fontSize: 16, // Reduced from 18
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
      ),
      
      // Card theme
      cardTheme: const CardThemeData(
        color: cardWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
        ),
      ),
    );
  }
}
