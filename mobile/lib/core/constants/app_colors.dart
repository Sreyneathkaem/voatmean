import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const Color primary = Color(0xFF2563EB); // blue-600
  static const Color primaryDark = Color(0xFF1D4ED8); // blue-700
  static const Color primaryLight = Color(0xFFEFF6FF); // blue-50
  static const Color primaryBorder = Color(0xFFDBEAFE); // blue-100

  // Backgrounds & Neutrals (Light Mode)
  static const Color background = Color(0xFFF1F5F9); // Crisp cool slate-100
  static const Color card = Colors.white;
  static const Color inputBg = Colors.white;
  static const Color border = Color(0xFFE2E8F0); // slate-200
  static const Color borderHover = Color(0xFFCBD5E1); // slate-300
  static const Color cardBorder = Color(0xFFCBD5E1);

  // Backgrounds & Neutrals (Dark Mode)
  static const Color backgroundDark = Color(0xFF0F172A); // slate-900 (deep dark background)
  static const Color cardDark = Color(0xFF1E293B); // slate-800 (elevated card surface)
  static const Color inputBgDark = Color(0xFF334155); // slate-700
  static const Color borderDark = Color(0xFF334155); // slate-700
  static const Color borderHoverDark = Color(0xFF475569); // slate-600
  static const Color cardBorderDark = Color(0xFF334155);

  // Typography (Light Mode)
  static const Color textPrimary = Color(0xFF0F172A); // slate-900
  static const Color textSecondary = Color(0xFF334155); // slate-700
  static const Color textMuted = Color(0xFF475569); // slate-600
  static const Color textSubtle = Color(0xFF64748B); // slate-500

  // Typography (Dark Mode) - High contrast & crisp readability
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // slate-50 (pure crisp white)
  static const Color textSecondaryDark = Color(0xFFE2E8F0); // slate-200 (crisp high contrast)
  static const Color textMutedDark = Color(0xFFCBD5E1); // slate-300 (clearly visible secondary)
  static const Color textSubtleDark = Color(0xFFA0AEC0); // slate-300/400 (crisply visible hint/subtle)

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

  // Modern Card Elevation Shadow
  static List<BoxShadow> get cardShadow => const [
        BoxShadow(
          color: Color(0x1A0F172A), // 10% crisp shadow for clear box noticeability
          blurRadius: 14,
          offset: Offset(0, 4),
        ),
        BoxShadow(
          color: Color(0x0C0F172A), // 4.5% ambient soft fill
          blurRadius: 6,
          offset: Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get elevatedShadow => const [
        BoxShadow(
          color: Color(0x220F172A), // 13.5% depth
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
        BoxShadow(
          color: Color(0x0E0F172A), // 5.5% ambient
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ];

  // Context-aware Theme Helpers
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color bgOf(BuildContext context) =>
      isDark(context) ? backgroundDark : background;

  static Color cardOf(BuildContext context) =>
      isDark(context) ? cardDark : card;

  static Color borderOf(BuildContext context) =>
      isDark(context) ? borderDark : border;

  static Color cardBorderOf(BuildContext context) =>
      isDark(context) ? cardBorderDark : cardBorder;

  static Color inputBgOf(BuildContext context) =>
      isDark(context) ? inputBgDark : inputBg;

  static Color textPrimaryOf(BuildContext context) =>
      isDark(context) ? textPrimaryDark : textPrimary;

  static Color textSecondaryOf(BuildContext context) =>
      isDark(context) ? textSecondaryDark : textSecondary;

  static Color textMutedOf(BuildContext context) =>
      isDark(context) ? textMutedDark : textMuted;

  static Color textSubtleOf(BuildContext context) =>
      isDark(context) ? textSubtleDark : textSubtle;

  static Color primaryLightOf(BuildContext context) =>
      isDark(context) ? const Color(0x591E3A8A) : primaryLight;

  static Color slateBgOf(BuildContext context) =>
      isDark(context) ? const Color(0xFF26334D) : slateBg;

  static Color successBgOf(BuildContext context) =>
      isDark(context) ? const Color(0x2610B981) : successBg;

  static Color successBorderOf(BuildContext context) =>
      isDark(context) ? const Color(0x6610B981) : successBorder;

  static Color successTextOf(BuildContext context) =>
      isDark(context) ? const Color(0xFF34D399) : successText;

  static Color warningBgOf(BuildContext context) =>
      isDark(context) ? const Color(0x26F59E0B) : warningBg;

  static Color warningBorderOf(BuildContext context) =>
      isDark(context) ? const Color(0x66F59E0B) : warningBorder;

  static Color warningTextOf(BuildContext context) =>
      isDark(context) ? const Color(0xFFFBBF24) : warningText;

  static Color dangerBgOf(BuildContext context) =>
      isDark(context) ? const Color(0x26EF4444) : dangerBg;

  static Color dangerBorderOf(BuildContext context) =>
      isDark(context) ? const Color(0x66EF4444) : dangerBorder;

  static Color dangerTextOf(BuildContext context) =>
      isDark(context) ? const Color(0xFFF87171) : dangerText;

  static List<BoxShadow> cardShadowOf(BuildContext context) =>
      isDark(context)
          ? const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ]
          : cardShadow;

  static List<BoxShadow> elevatedShadowOf(BuildContext context) =>
      isDark(context)
          ? const [
              BoxShadow(
                color: Color(0x60000000),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ]
          : elevatedShadow;
}
