import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/locale_provider.dart';
import 'features/admin/presentation/widgets/admin_navbar.dart';
import 'features/auth/presentation/screens/authentication/login_screen.dart';
import 'features/auth/presentation/screens/authentication/register_screen.dart';
import 'features/teacher/presentation/widgets/teacher_navbar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');
  } catch (e, stackTrace) {
    debugPrint('Firebase initialization failed: $e');
    debugPrintStack(stackTrace: stackTrace);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const VoatmeanApp(),
    ),
  );
}

class VoatmeanApp extends StatelessWidget {
  const VoatmeanApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      title: '${AppStrings.appName} • វត្តមាន',
      debugShowCheckedModeBanner: false,
      locale: localeProvider.locale,
      supportedLocales: const [
        Locale('km', 'KH'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(
              onAuthenticated: (role, email) {
                if (role == 'admin') {
                  Navigator.pushReplacementNamed(context, '/admin');
                } else {
                  Navigator.pushReplacementNamed(context, '/teacher');
                }

                if (role != 'admin' && role != 'teacher') {
                  debugPrint('Logged in as $role: $email');
                }
              },
            ),
        '/register': (context) => const RegisterScreen(),
        '/admin': (context) => const AdminMainShell(),
        '/teacher': (context) => const TeacherMainShell(),
      },
    );
  }
}
