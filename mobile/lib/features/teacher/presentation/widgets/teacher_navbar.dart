import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:voatmean_mobile/core/constants/app_colors.dart';
import 'package:voatmean_mobile/features/auth/data/services/auth_service.dart';
import '../screens/teacher_dashboard_screen.dart';

class TeacherMainShell extends StatefulWidget {
  const TeacherMainShell({super.key});

  @override
  State<TeacherMainShell> createState() => _TeacherMainShellState();
}

class _TeacherMainShellState extends State<TeacherMainShell> {
  int _currentIndex = 0;
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const TeacherDashboardScreen(),
      _buildPlaceholder('បញ្ជីសិស្ស'),
      _buildPlaceholder('របាយការណ៍'),
      _buildSettings(context),
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

  Widget _buildPlaceholder(String title) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('កំពុងអភិវឌ្ឍផ្ទាំង $title...')),
    );
  }

  Widget _buildSettings(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ការកំណត់')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(LucideIcons.logOut, color: Colors.red),
            title: const Text('ចាកចេញពីកម្មវិធី', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await _authService.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
        ],
      ),
    );
  }
}
