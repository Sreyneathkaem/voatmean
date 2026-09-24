import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Central Typography System for Voatmean Mobile.
/// Ensures consistent Kantumruy Pro font rendering across Khmer and Latin (English)
/// scripts with optimal font sizes and comfortable line heights for Khmer diacritics and subscripts.
class AppTypography {
  // Base text style builder ensuring Kantumruy Pro font family and proper line height
  static TextStyle font({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color color = AppColors.textPrimary,
    double height = 1.4,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.kantumruyPro(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
  }

  // Display & Large Screen Headers
  static TextStyle get displayLarge => font(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get displayMedium => font(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  // Section & Card Titles
  static TextStyle get titleLarge => font(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        height: 1.35,
      );

  static TextStyle get titleMedium => font(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        height: 1.35,
      );

  static TextStyle get titleSmall => font(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.35,
      );

  // Body Text (Optimal readability for Khmer & English)
  static TextStyle get bodyLarge => font(
        fontSize: 15,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
        height: 1.45,
      );

  static TextStyle get bodyMedium => font(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
        height: 1.45,
      );

  static TextStyle get bodySmall => font(
        fontSize: 13,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  // Interactive Labels & Buttons
  static TextStyle get labelLarge => font(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        height: 1.35,
      );

  static TextStyle get labelMedium => font(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.35,
      );

  static TextStyle get labelSmall => font(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.35,
      );

  // Captions & Secondary Details (Never smaller than 12.5px for Khmer readability)
  static TextStyle get caption => font(
        fontSize: 12.5,
        fontWeight: FontWeight.normal,
        color: AppColors.textMuted,
        height: 1.35,
      );

  static TextStyle get captionBold => font(
        fontSize: 12.5,
        fontWeight: FontWeight.bold,
        color: AppColors.textMuted,
        height: 1.35,
      );

  // Material 3 TextTheme generator
  static TextTheme get textTheme {
    return GoogleFonts.kantumruyProTextTheme().copyWith(
      displayLarge: displayLarge,
      displayMedium: displayMedium,
      titleLarge: titleLarge,
      titleMedium: titleMedium,
      titleSmall: titleSmall,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelMedium: labelMedium,
      labelSmall: labelSmall,
    );
  }
}
