import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:voatmean_mobile/core/constants/app_colors.dart';
import 'package:voatmean_mobile/core/localization/app_translations.dart';
import 'package:voatmean_mobile/features/auth/data/services/auth_service.dart';
import '../screens/teacher_dashboard_screen.dart';
import '../screens/teacher_students_screen.dart';
import '../screens/teacher_reports_screen.dart';
import '../screens/teacher_settings_screen.dart';

class TeacherMainShell extends StatefulWidget {
  final int initialIndex;

  const TeacherMainShell({super.key, this.initialIndex = 0});

  @override
  State<TeacherMainShell> createState() => _TeacherMainShellState();
}

class _TeacherMainShellState extends State<TeacherMainShell> {
  late int _currentIndex;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _handleSignOut() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  void _handleSwitchToAdmin() {
    Navigator.pushReplacementNamed(context, '/admin');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final cardBg = Theme.of(context).cardColor;

    final List<Widget> screens = [
      const TeacherDashboardScreen(),
      const TeacherStudentsScreen(),
      const TeacherReportsScreen(),
      TeacherSettingsScreen(
        onSignOut: _handleSignOut,
        onSwitchToAdminPortal: _handleSwitchToAdmin,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.bgOf(context),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cardBg,
          border: Border(top: BorderSide(color: AppColors.borderOf(context), width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
          backgroundColor: cardBg,
          indicatorColor: isDark ? const Color(0xFF1E3A8A) : AppColors.primaryLight,
          destinations: [
            NavigationDestination(
              icon: const Icon(LucideIcons.calendar),
              selectedIcon: const Icon(LucideIcons.calendar, color: AppColors.primary),
              label: context.tr('nav_schedule'),
            ),
            NavigationDestination(
              icon: const Icon(LucideIcons.users),
              selectedIcon: const Icon(LucideIcons.users, color: AppColors.primary),
              label: context.tr('nav_students'),
            ),
            NavigationDestination(
              icon: const Icon(LucideIcons.barChart3),
              selectedIcon: const Icon(LucideIcons.barChart3, color: AppColors.primary),
              label: context.tr('nav_reports'),
            ),
            NavigationDestination(
              icon: const Icon(LucideIcons.settings),
              selectedIcon: const Icon(LucideIcons.settings, color: AppColors.primary),
              label: context.tr('nav_settings'),
            ),
          ],
        ),
      ),
    );
  }
}
