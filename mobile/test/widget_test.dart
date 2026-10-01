import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:voatmean_mobile/core/localization/locale_provider.dart';
import 'package:voatmean_mobile/core/theme/theme_provider.dart';
import 'package:voatmean_mobile/main.dart';
import 'package:voatmean_mobile/core/constants/app_strings.dart';

void main() {
  testWidgets('App loads and shows splash screen or login', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ],
        child: const VoatmeanApp(),
      ),
    );
    await tester.pump();

    // Verify that the app name is present (Splash or Login)
    expect(find.textContaining(AppStrings.appName), findsWidgets);
  });
}
