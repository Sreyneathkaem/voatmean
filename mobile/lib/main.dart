import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'features/auth/presentation/screens/authentication/login_screen.dart';
import 'features/auth/presentation/screens/authentication/register_screen.dart';
import 'features/auth/presentation/screens/admin/admin_dashboard_screen.dart'; // 1. IMPORT THE ADMIN SCREEN

void main() {
  runApp(const VoatmeanApp());
}

class VoatmeanApp extends StatelessWidget {
  const VoatmeanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${AppStrings.appName} • វត្តមាន',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        textTheme: GoogleFonts.kantumruyProTextTheme(
          ThemeData.light().textTheme,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(
          onAuthenticated: (role, email) {
            debugPrint('Authentication Success: Role=$role, Email=$email');

            // 2. NAVIGATE BASED ON THE DETECTED ROLE
            if (role == 'admin') {
              Navigator.pushReplacementNamed(context, '/admin');
            } else if (role == 'teacher') {
              // When ready, route to teacher portal:
              // Navigator.pushReplacementNamed(context, '/teacher');

              // For now, let's also navigate to admin or show feedback:
              Navigator.pushReplacementNamed(context, '/admin');
            }
          },
        ),
        '/register': (context) => const RegisterScreen(),

        // 3. REGISTER THE ADMIN ROUTE HERE
        '/admin': (context) => const AdminDashboardScreen(),
      },
    );
  }
}