import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/utils/validators.dart';
import '../../widgets/login_form.dart';

class LoginScreen extends StatefulWidget {
  final Function(String role, String email)? onAuthenticated;

  const LoginScreen({super.key, this.onAuthenticated});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  void _onFormSubmit(DetectedRole role, String email) {
    if (role == DetectedRole.dual) {
      _showDualRoleBottomSheet(email);
    } else {
      final roleStr = role == DetectedRole.admin ? 'admin' : 'teacher';
      _showToast(
        role == DetectedRole.admin
            ? 'ចូលប្រើប្រាស់ជោគជ័យក្នុងនាមជា អ្នកគ្រប់គ្រង (Admin)'
            : 'ចូលប្រើប្រាស់ជោគជ័យក្នុងនាមជា គ្រូបង្រៀន (Teacher)',
      );
      widget.onAuthenticated?.call(roleStr, email);
    }
  }

  void _onSocialLogin(String provider) {
    _showToast('ចូលប្រើប្រាស់តាម $provider (Firebase Auth) ជោគជ័យ!');
    widget.onAuthenticated?.call('teacher', 'user@school.edu');
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.kantumruyPro(fontSize: 13)),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showDualRoleBottomSheet(String email) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.purpleBg,
                    border: Border.all(color: AppColors.purpleBorder),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(LucideIcons.layers,
                      color: AppColors.purpleIcon, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.dualModalTitle,
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        AppStrings.dualModalSubtitle,
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(LucideIcons.x, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.purpleBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.purpleBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    email,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.purpleText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppStrings.dualModalPrompt,
                    style: GoogleFonts.kantumruyPro(
                      fontSize: 11,
                      color: AppColors.purpleText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildRoleOption(
              icon: LucideIcons.shield,
              title: AppStrings.adminDashboardTitle,
              subtitle: AppStrings.adminDashboardDesc,
              iconBg: AppColors.blueBg,
              iconColor: AppColors.blueIcon,
              onTap: () {
                Navigator.pop(ctx);
                _showToast('ចូលប្រើប្រាស់ផ្ទាំងអ្នកគ្រប់គ្រង (Admin)');
                widget.onAuthenticated?.call('admin', email);
              },
            ),
            const SizedBox(height: 10),
            _buildRoleOption(
              icon: LucideIcons.graduationCap,
              title: AppStrings.teacherPortalTitle,
              subtitle: AppStrings.teacherPortalDesc,
              iconBg: AppColors.emeraldBg,
              iconColor: AppColors.emeraldIcon,
              onTap: () {
                Navigator.pop(ctx);
                _showToast('ចូលប្រើប្រាស់ផ្ទាំងគ្រូបង្រៀន (Teacher)');
                widget.onAuthenticated?.call('teacher', email);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconBg,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.kantumruyPro(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.kantumruyPro(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.arrowRight,
                size: 18, color: AppColors.textSubtle),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF64748B).withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo & Headers
                    _buildHeader(),
                    const SizedBox(height: 20),

                    // Credentials form & Social buttons
                    LoginForm(
                      onSubmit: _onFormSubmit,
                      onSocialLogin: _onSocialLogin,
                    ),
                    const SizedBox(height: 16),

                    // Footer Notice
                    Text(
                      AppStrings.footerNotice,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.kantumruyPro(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primaryBorder),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              AppStrings.logoUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                LucideIcons.graduationCap,
                size: 32,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          AppStrings.appName,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          AppStrings.appTitleKhmer,
          style: GoogleFonts.kantumruyPro(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AppStrings.appSubtitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.kantumruyPro(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}