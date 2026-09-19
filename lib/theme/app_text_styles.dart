import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// GoChef Typography System
/// Montserrat for headlines/display, Karla for body/labels
class AppTextStyles {
  AppTextStyles._();

  // ─── Display ───
  static TextStyle displayLg({Color? color}) => GoogleFonts.montserrat(
        fontSize: 48,
        height: 56 / 48,
        letterSpacing: -0.02 * 48,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle displayLgMobile({Color? color}) => GoogleFonts.montserrat(
        fontSize: 36,
        height: 44 / 36,
        letterSpacing: -0.02 * 36,
        fontWeight: FontWeight.w700,
        color: color,
      );

  // ─── Headline ───
  static TextStyle headlineLg({Color? color}) => GoogleFonts.montserrat(
        fontSize: 32,
        height: 40 / 32,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle headlineLgMobile({Color? color}) => GoogleFonts.montserrat(
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle headlineMd({Color? color}) => GoogleFonts.montserrat(
        fontSize: 20,
        height: 28 / 20,
        fontWeight: FontWeight.w600,
        color: color,
      );

  // ─── Body ───
  static TextStyle bodyLg({Color? color}) => GoogleFonts.karla(
        fontSize: 18,
        height: 28 / 18,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle bodyMd({Color? color}) => GoogleFonts.karla(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle bodySm({Color? color}) => GoogleFonts.karla(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
        color: color,
      );

  // ─── Label ───
  static TextStyle labelMono({Color? color}) => GoogleFonts.karla(
        fontSize: 14,
        height: 20 / 14,
        letterSpacing: 0.02 * 14,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle labelSm({Color? color}) => GoogleFonts.karla(
        fontSize: 12,
        height: 16 / 12,
        letterSpacing: 0.02 * 12,
        fontWeight: FontWeight.w500,
        color: color,
      );
}
