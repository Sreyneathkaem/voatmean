import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'features/admin/presentation/widgets/admin_navbar.dart';
import 'features/auth/presentation/screens/authentication/login_screen.dart';
import 'features/auth/presentation/screens/authentication/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }
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
            Navigator.pushReplacementNamed(context, '/admin');
          },
        ),
        '/register': (context) => const RegisterScreen(),
        '/admin': (context) => const AdminMainShell(),
      },
    );
  }
}
