import 'package:flutter/material.dart';

/// GoChef Premium Color Palette
/// Extracted from color.jpeg design system
class AppColors {
  AppColors._();

  // ─── Primary ───
  static const Color primary = Color(0xFFFFB1C6);
  static const Color primaryContainer = Color(0xFFFF4A90);
  static const Color primaryFixed = Color(0xFFFFD9E1);
  static const Color primaryFixedDim = Color(0xFFFFB1C6);
  static const Color onPrimary = Color(0xFF650030);
  static const Color onPrimaryContainer = Color(0xFF590029);
  static const Color onPrimaryFixed = Color(0xFF3F001B);
  static const Color onPrimaryFixedVariant = Color(0xFF8E0046);
  static const Color inversePrimary = Color(0xFFBA005E);
  static const Color fuchsia = Color(0xFFFF1493); // Vibrant Fuchsia

  // ─── Secondary ───
  static const Color secondary = Color(0xFFC6C6C7);
  static const Color secondaryContainer = Color(0xFF454747);
  static const Color secondaryFixed = Color(0xFFE2E2E2);
  static const Color secondaryFixedDim = Color(0xFFC6C6C7);
  static const Color onSecondary = Color(0xFF2F3131);
  static const Color onSecondaryContainer = Color(0xFFB4B5B5);
  static const Color onSecondaryFixed = Color(0xFF1A1C1C);
  static const Color onSecondaryFixedVariant = Color(0xFF454747);

  // ─── Tertiary ───
  static const Color tertiary = Color(0xFFFFB0CD);
  static const Color tertiaryContainer = Color(0xFFDB6C9B);
  static const Color tertiaryFixed = Color(0xFFFFD9E4);
  static const Color tertiaryFixedDim = Color(0xFFFFB0CD);
  static const Color onTertiary = Color(0xFF620639);
  static const Color onTertiaryContainer = Color(0xFF570032);
  static const Color onTertiaryFixed = Color(0xFF3E0021);
  static const Color onTertiaryFixedVariant = Color(0xFF7F2250);

  // ─── Surface ───
  static const Color surface = Color(0xFF0F131C);
  static const Color surfaceDim = Color(0xFF0F131C);
  static const Color surfaceBright = Color(0xFF353943);
  static const Color surfaceVariant = Color(0xFF31353F);
  static const Color surfaceContainer = Color(0xFF1C2029);
  static const Color surfaceContainerLow = Color(0xFF181B25);
  static const Color surfaceContainerLowest = Color(0xFF0A0E17);
  static const Color surfaceContainerHigh = Color(0xFF262A34);
  static const Color surfaceContainerHighest = Color(0xFF31353F);
  static const Color surfaceTint = Color(0xFFFFB1C6);
  static const Color onSurface = Color(0xFFDFE2EF);
  static const Color onSurfaceVariant = Color(0xFFE2BDC5);
  static const Color inverseSurface = Color(0xFFDFE2EF);
  static const Color inverseOnSurface = Color(0xFF2C303A);

  // ─── Background ───
  static const Color background = Color(0xFF0F131C);
  static const Color onBackground = Color(0xFFDFE2EF);
  static const Color midnight = Color(0xFF0D111A);

  // ─── Error ───
  static const Color error = Color(0xFFFFB4AB);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onError = Color(0xFF690005);
  static const Color onErrorContainer = Color(0xFFFFDAD6);

  // ─── Outline ───
  static const Color outline = Color(0xFFA98890);
  static const Color outlineVariant = Color(0xFF5A4046);

  // ─── Gradients ───
  static const LinearGradient magentaGloss = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF4A90), Color(0xFFBA005E)],
  );

  static const LinearGradient ctaGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFF4A90), Color(0xFFDB6C9B)],
  );

  static const LinearGradient signUpGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF4A90), Color(0xFFDB6C9B)],
  );

  // ─── Glass / Overlay ───
  static const Color glassBackground = Color(0x991C2029); // ~60% opacity
  static const Color glassBorder = Color(0x1AA98890); // ~10% opacity
  static const Color ghostBorder = Color(0x1AE2BDC5); // ~10% opacity
}
