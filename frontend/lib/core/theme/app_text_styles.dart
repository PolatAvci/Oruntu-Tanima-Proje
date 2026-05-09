import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized text styles using Google Fonts (Inter).
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _base => GoogleFonts.inter();

  static TextStyle get headlineLarge => _base.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
      );

  static TextStyle get headlineMedium => _base.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        height: 1.3,
      );

  static TextStyle get titleLarge => _base.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.4,
      );

  static TextStyle get titleMedium => _base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get bodyLarge => _base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodyMedium => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get labelLarge => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.4,
      );

  static TextStyle get labelMedium => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        height: 1.4,
      );

  static TextStyle get displayLarge => _base.copyWith(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        height: 1.1,
      );
}
