import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:voatmean_mobile/core/constants/app_colors.dart';
import 'package:voatmean_mobile/core/localization/app_translations.dart';
import 'package:voatmean_mobile/features/auth/data/services/auth_service.dart';
import '../screens/admin_dashboard_screen.dart';
import '../screens/admin_assignclass_screen.dart';
import '../screens/admin_assignteacher_screen.dart';
import '../screens/admin_students_screen.dart';
import '../screens/admin_settings_screen.dart';

class AdminMainShell extends StatefulWidget {
  final int initialIndex;

  const AdminMainShell({super.key, this.initialIndex = 0});

  @override
  State<AdminMainShell> createState() => _AdminMainShellState();
}

class _AdminMainShellState extends State<AdminMainShell> {
  late int _currentIndex;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const AdminDashboardScreen(),
      const AdminAssignClassScreen(),
      const AdminAssignTeacherScreen(),
      const AdminStudentsScreen(),
      AdminSettingsScreen(
        onSignOut: () async {
          await _authService.signOut();
          if (!context.mounted) return;
          Navigator.pushReplacementNamed(context, '/');
        },
        onSwitchToTeacherPortal: () {
          Navigator.pushReplacementNamed(context, '/teacher');
        },
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.bgOf(context),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: AdminMainShellNavBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
      ),
    );
  }
}

class AdminMainShellNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const AdminMainShellNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final cardBg = Theme.of(context).cardColor;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        border: Border(top: BorderSide(color: AppColors.borderOf(context), width: 1)),
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        backgroundColor: cardBg,
        indicatorColor: isDark ? const Color(0xFF1E3A8A) : AppColors.primaryLight,
        destinations: [
          NavigationDestination(
            icon: const Icon(LucideIcons.layoutDashboard),
            selectedIcon: const Icon(LucideIcons.layoutDashboard, color: AppColors.primary),
            label: context.tr('nav_dashboard'),
          ),
          NavigationDestination(
            icon: const Icon(LucideIcons.bookOpen),
            selectedIcon: const Icon(LucideIcons.bookOpen, color: AppColors.primary),
            label: context.tr('nav_classes'),
          ),
          NavigationDestination(
            icon: const Icon(LucideIcons.users),
            selectedIcon: const Icon(LucideIcons.users, color: AppColors.primary),
            label: context.tr('nav_teachers'),
          ),
          NavigationDestination(
            icon: const Icon(LucideIcons.graduationCap),
            selectedIcon: const Icon(LucideIcons.graduationCap, color: AppColors.primary),
            label: context.tr('nav_students'),
          ),
          NavigationDestination(
            icon: const Icon(LucideIcons.settings),
            selectedIcon: const Icon(LucideIcons.settings, color: AppColors.primary),
            label: context.tr('nav_settings'),
          ),
        ],
      ),
    );
  }
}
