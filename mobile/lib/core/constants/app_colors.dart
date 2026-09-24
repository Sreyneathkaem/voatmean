import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const Color primary = Color(0xFF2563EB); // blue-600
  static const Color primaryDark = Color(0xFF1D4ED8); // blue-700
  static const Color primaryLight = Color(0xFFEFF6FF); // blue-50
  static const Color primaryBorder = Color(0xFFDBEAFE); // blue-100

  // Backgrounds & Neutrals
  static const Color background = Color(0xFFF1F5F9); // Crisp cool slate-100
  static const Color card = Colors.white;
  static const Color inputBg = Colors.white;
  static const Color border = Color(0xFFE2E8F0); // slate-200
  static const Color borderHover = Color(0xFFCBD5E1); // slate-300
  static const Color cardBorder = Color(0xFFE2E8F0);

  // Modern Card Elevation Shadow
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.08),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ];

  // Typography (Enriched contrast for Khmer & English)
  static const Color textPrimary = Color(0xFF0F172A); // slate-900 (deepest dark)
  static const Color textSecondary = Color(0xFF334155); // slate-700 (sharp body)
  static const Color textMuted = Color(0xFF475569); // slate-600 (distinctly readable)
  static const Color textSubtle = Color(0xFF64748B); // slate-500 (labels & meta)

  // Role Badges
  // Dual-role (Purple)
  static const Color purpleBg = Color(0xFFFAF5FF);
  static const Color purpleBorder = Color(0xFFE9D5FF);
  static const Color purpleText = Color(0xFF7E22CE);
  static const Color purpleIcon = Color(0xFF9333EA);

  // Admin (Blue)
  static const Color blueBg = Color(0xFFEFF6FF);
  static const Color blueBorder = Color(0xFFBFDBFE);
  static const Color blueText = Color(0xFF1D4ED8);
  static const Color blueIcon = Color(0xFF2563EB);

  // Teacher (Emerald)
  static const Color emeraldBg = Color(0xFFECFDF5);
  static const Color emeraldBorder = Color(0xFFA7F3D0);
  static const Color emeraldText = Color(0xFF047857);
  static const Color emeraldIcon = Color(0xFF059669);

  // Social
  static const Color facebook = Color(0xFF1877F2);
  static const Color googleRed = Color(0xFFEA4335);

  // Status & Actions
  static const Color success = Color(0xFF10B981); // emerald-500
  static const Color successDark = Color(0xFF059669); // emerald-600
  static const Color successBg = Color(0xFFECFDF5); // emerald-50
  static const Color successBorder = Color(0xFFA7F3D0); // emerald-200
  static const Color successText = Color(0xFF047857); // emerald-700

  static const Color warning = Color(0xFFF59E0B); // amber-500
  static const Color warningDark = Color(0xFFD97706); // amber-600
  static const Color warningBg = Color(0xFFFFFBEB); // amber-50
  static const Color warningBorder = Color(0xFFFDE68A); // amber-200
  static const Color warningText = Color(0xFF92400E); // amber-800

  static const Color danger = Color(0xFFEF4444); // red-500
  static const Color dangerDark = Color(0xFFDC2626); // red-600
  static const Color dangerBg = Color(0xFFFEF2F2); // red-50
  static const Color dangerBorder = Color(0xFFFECACA); // red-200
  static const Color dangerText = Color(0xFFB91C1C); // red-700
  static const Color dangerLight = Color(0xFFFEF2F2);

  static const Color slateBg = Color(0xFFF1F5F9); // slate-100
  static const Color slateBorder = Color(0xFFE2E8F0); // slate-200
}
