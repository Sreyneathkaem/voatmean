import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:voatmean_mobile/core/constants/app_colors.dart';
import '../screens/admin_dashboard_screen.dart';
import '../screens/admin_assignclass_screen.dart';
import '../screens/admin_assignteacher_screen.dart';
import '../screens/admin_settings_screen.dart';

class AdminMainShell extends StatefulWidget {
  final int initialIndex;

  const AdminMainShell({super.key, this.initialIndex = 0});

  @override
  State<AdminMainShell> createState() => _AdminMainShellState();
}

class _AdminMainShellState extends State<AdminMainShell> {
  late int _currentIndex;

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
      AdminSettingsScreen(
        onSignOut: () {
          Navigator.pushReplacementNamed(context, '/');
        },
        onSwitchToTeacherPortal: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('បានប្តូរទៅកាន់ផ្ទាំងគ្រូបង្រៀន (Teacher Portal)'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.primary,
            ),
          );
        },
      ),
    ];

    return Scaffold(
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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primaryLight,
        destinations: const [
          NavigationDestination(
            icon: Icon(LucideIcons.layoutDashboard),
            selectedIcon: Icon(LucideIcons.layoutDashboard, color: AppColors.primary),
            label: 'ផ្ទាំងទិន្នន័យ',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.bookOpen),
            selectedIcon: Icon(LucideIcons.bookOpen, color: AppColors.primary),
            label: 'ចាត់តាំងថ្នាក់',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.users),
            selectedIcon: Icon(LucideIcons.users, color: AppColors.primary),
            label: 'គ្រូបង្រៀន',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.settings),
            selectedIcon: Icon(LucideIcons.settings, color: AppColors.primary),
            label: 'ការកំណត់',
          ),
        ],
      ),
    );
  }
}
