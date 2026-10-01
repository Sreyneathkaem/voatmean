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
    Color? color,
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
        height: 1.3,
      );

  static TextStyle get displayMedium => font(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        height: 1.3,
      );

  // Section & Card Titles
  static TextStyle get titleLarge => font(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        height: 1.35,
      );

  static TextStyle get titleMedium => font(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        height: 1.35,
      );

  static TextStyle get titleSmall => font(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.35,
      );

  // Body Text (Optimal readability for Khmer & English)
  static TextStyle get bodyLarge => font(
        fontSize: 15,
        fontWeight: FontWeight.normal,
        height: 1.45,
      );

  static TextStyle get bodyMedium => font(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        height: 1.45,
      );

  static TextStyle get bodySmall => font(
        fontSize: 13,
        fontWeight: FontWeight.normal,
        height: 1.4,
      );

  // Interactive Labels & Buttons
  static TextStyle get labelLarge => font(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        height: 1.35,
      );

  static TextStyle get labelMedium => font(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        height: 1.35,
      );

  static TextStyle get labelSmall => font(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        height: 1.35,
      );

  // Captions & Secondary Details (Never smaller than 12.5px for Khmer readability)
  static TextStyle get caption => font(
        fontSize: 12.5,
        fontWeight: FontWeight.normal,
        height: 1.35,
      );

  static TextStyle get captionBold => font(
        fontSize: 12.5,
        fontWeight: FontWeight.bold,
        height: 1.35,
      );

  // Context-aware Helpers for high-contrast dark/light rendering
  static TextStyle titleMediumOf(BuildContext context) =>
      titleMedium.copyWith(color: AppColors.textPrimaryOf(context));

  static TextStyle titleSmallOf(BuildContext context) =>
      titleSmall.copyWith(color: AppColors.textPrimaryOf(context));

  static TextStyle bodyMediumOf(BuildContext context) =>
      bodyMedium.copyWith(color: AppColors.textSecondaryOf(context));

  static TextStyle bodySmallOf(BuildContext context) =>
      bodySmall.copyWith(color: AppColors.textSecondaryOf(context));

  static TextStyle captionOf(BuildContext context) =>
      caption.copyWith(color: AppColors.textMutedOf(context));

  static TextStyle captionBoldOf(BuildContext context) =>
      captionBold.copyWith(color: AppColors.textMutedOf(context));

  // Material 3 TextTheme generator (Light Mode)
  static TextTheme get textTheme {
    return GoogleFonts.kantumruyProTextTheme().copyWith(
      displayLarge: displayLarge.copyWith(color: AppColors.textPrimary),
      displayMedium: displayMedium.copyWith(color: AppColors.textPrimary),
      titleLarge: titleLarge.copyWith(color: AppColors.textPrimary),
      titleMedium: titleMedium.copyWith(color: AppColors.textPrimary),
      titleSmall: titleSmall.copyWith(color: AppColors.textPrimary),
      bodyLarge: bodyLarge.copyWith(color: AppColors.textPrimary),
      bodyMedium: bodyMedium.copyWith(color: AppColors.textSecondary),
      bodySmall: bodySmall.copyWith(color: AppColors.textSecondary),
      labelLarge: labelLarge.copyWith(color: AppColors.textPrimary),
      labelMedium: labelMedium.copyWith(color: AppColors.textPrimary),
      labelSmall: labelSmall.copyWith(color: AppColors.textPrimary),
    );
  }

  // Material 3 TextTheme generator (Dark Mode)
  static TextTheme get darkTextTheme {
    return GoogleFonts.kantumruyProTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: font(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimaryDark, height: 1.3),
      displayMedium: font(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimaryDark, height: 1.3),
      titleLarge: font(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimaryDark, height: 1.35),
      titleMedium: font(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimaryDark, height: 1.35),
      titleSmall: font(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark, height: 1.35),
      bodyLarge: font(fontSize: 15, fontWeight: FontWeight.normal, color: AppColors.textPrimaryDark, height: 1.45),
      bodyMedium: font(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.textSecondaryDark, height: 1.45),
      bodySmall: font(fontSize: 13, fontWeight: FontWeight.normal, color: AppColors.textSecondaryDark, height: 1.4),
      labelLarge: font(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimaryDark, height: 1.35),
      labelMedium: font(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark, height: 1.35),
      labelSmall: font(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark, height: 1.35),
    );
  }
}

