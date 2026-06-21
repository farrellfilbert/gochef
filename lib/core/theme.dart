import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Base Colors - Premium Midnight Charcoal
  static const Color backgroundDark = Color(0xFF090A0F); 
  static const Color surfaceColor = Color(0xFF13151E); 
  static const Color surfaceLight = Color(0xFF1D202D); 
  
  // Accents - Ember / Deep Cyber Fuchsia Gradient
  static const Color fuchsiaPrimary = Color(0xFFFF2A6D); // Coral/Fuchsia Pink
  static const Color fuchsiaAccent = Color(0xFF9000FF);  // Deep Purple
  static const Color secondaryAccent = Color(0xFFFF9933); // Sunset Orange

  // Chef Mode Colors (Stitch Design)
  static const Color chefBackground = Color(0xFF1F0F12);
  static const Color chefSurface = Color(0xFF1E1E1E);
  static const Color chefSurfaceVariant = Color(0xFF353535);
  static const Color chefPrimary = Color(0xFFE91E63); // Magenta
  static const Color chefPrimaryContainer = Color(0xFFFF4E7C);
  static const Color chefSecondary = Color(0xFF78DC77); // Green
  static const Color chefTertiary = Color(0xFFFF9800); // Warm Orange
  static const Color chefTextPrimary = Color(0xFFFADBDE);
  static const Color chefTextSecondary = Color(0xFFE4BDC2);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [fuchsiaPrimary, fuchsiaAccent],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x22FFFFFF), // 13% opacity
      Color(0x05FFFFFF), // 2% opacity
    ],
  );

  // Text Colors
  static const Color textPrimary = Color(0xFFF7F8FA);
  static const Color textSecondary = Color(0xFFA5B0C2);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      primaryColor: fuchsiaPrimary,
      colorScheme: const ColorScheme.dark(
        primary: fuchsiaPrimary,
        secondary: fuchsiaAccent,
        surface: surfaceColor,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.w800, letterSpacing: -1.0),
        displayMedium: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        titleLarge: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.w600, letterSpacing: -0.2),
        bodyLarge: GoogleFonts.outfit(color: textPrimary, letterSpacing: 0.1),
        bodyMedium: GoogleFonts.outfit(color: textSecondary, letterSpacing: 0.2, fontWeight: FontWeight.w400),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
