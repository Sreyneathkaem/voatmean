import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:voatmean_mobile/core/constants/app_colors.dart';

class AdminSettingsScreen extends StatefulWidget {
  final VoidCallback onSignOut;
  final VoidCallback onSwitchToTeacherPortal;

  const AdminSettingsScreen({
    super.key,
    required this.onSignOut,
    required this.onSwitchToTeacherPortal,
  });

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('ការកំណត់', style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('គណនី និងសុវត្ថិភាព'),
          _buildTile(LucideIcons.user, 'ព័ត៌មានផ្ទាល់ខ្លួន', onTap: () {}),
          _buildTile(LucideIcons.lock, 'ប្តូរពាក្យសម្ងាត់', onTap: () {}),
          const SizedBox(height: 20),
          
          _buildSection('កម្មវិធី'),
          SwitchListTile(
            secondary: const Icon(LucideIcons.bell),
            title: const Text('ការជូនដំណឹង'),
            value: _notificationsEnabled,
            onChanged: (v) => setState(() => _notificationsEnabled = v),
          ),
          SwitchListTile(
            secondary: const Icon(LucideIcons.moon),
            title: const Text('មុខងារងងឹត (Dark Mode)'),
            value: _darkMode,
            onChanged: (v) => setState(() => _darkMode = v),
          ),
          const SizedBox(height: 20),

          _buildSection('សកម្មភាព'),
          _buildTile(
            LucideIcons.refreshCw,
            'ប្តូរទៅកាន់ Teacher Portal',
            color: AppColors.primary,
            onTap: widget.onSwitchToTeacherPortal,
          ),
          _buildTile(
            LucideIcons.logOut,
            'ចាកចេញពីកម្មវិធី',
            color: AppColors.danger,
            onTap: widget.onSignOut,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        title,
        style: GoogleFonts.kantumruyPro(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textMuted,
        ),
      ),
    );
  }

  Widget _buildTile(IconData icon, String title, {Color? color, VoidCallback? onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: color ?? AppColors.textPrimary),
        title: Text(title, style: TextStyle(color: color)),
        trailing: const Icon(LucideIcons.chevronRight, size: 18),
        onTap: onTap,
      ),
    );
  }
}
