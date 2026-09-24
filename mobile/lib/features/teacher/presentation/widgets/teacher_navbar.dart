import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:voatmean_mobile/core/constants/app_colors.dart';
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
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
          backgroundColor: Colors.white,
          indicatorColor: AppColors.primaryLight,
          destinations: const [
            NavigationDestination(
              icon: Icon(LucideIcons.calendar),
              selectedIcon: Icon(LucideIcons.calendar, color: AppColors.primary),
              label: 'កាលវិភាគ',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.users),
              selectedIcon: Icon(LucideIcons.users, color: AppColors.primary),
              label: 'សិស្ស',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.barChart3),
              selectedIcon: Icon(LucideIcons.barChart3, color: AppColors.primary),
              label: 'របាយការណ៍',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.settings),
              selectedIcon: Icon(LucideIcons.settings, color: AppColors.primary),
              label: 'ការកំណត់',
            ),
          ],
        ),
      ),
    );
  }
}
