import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:voatmean_mobile/core/constants/app_colors.dart';
import 'package:voatmean_mobile/core/constants/app_typography.dart';

/// The official brand logo for Voatmean (វត្តមាន).
/// Combines an education emblem (graduation cap) with an attendance verification badge (check mark).
class AppLogo extends StatelessWidget {
  final double size;
  final bool showBadge;
  final bool showText;
  final String? subtitle;

  const AppLogo({
    super.key,
    this.size = 64,
    this.showBadge = true,
    this.showText = false,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = size * 0.48;
    final badgeSize = size * 0.36;

    final logoIcon = Stack(
      clipBehavior: Clip.none,
      children: [
        // Main Logo Container
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF1E40AF), // Dark blue
                Color(0xFF2563EB), // Primary brand blue
                Color(0xFF3B82F6), // Sky highlight
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.30),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.28),
                blurRadius: size * 0.25,
                offset: Offset(0, size * 0.08),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Icon(
              LucideIcons.graduationCap,
              color: Colors.white,
              size: iconSize,
            ),
          ),
        ),

        // Attendance Verification Badge (Green checkmark at bottom-right)
        if (showBadge)
          Positioned(
            right: -size * 0.06,
            bottom: -size * 0.06,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981), // Emerald green
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  LucideIcons.check,
                  color: Colors.white,
                  size: badgeSize * 0.6,
                ),
              ),
            ),
          ),
      ],
    );

    if (!showText) {
      return logoIcon;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        logoIcon,
        const SizedBox(height: 12),
        Text(
          'Voatmean',
          style: AppTypography.displayLarge.copyWith(
            letterSpacing: -0.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle ?? 'ប្រព័ន្ធគ្រប់គ្រងវត្តមានសិស្ស',
          style: AppTypography.captionBold.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
