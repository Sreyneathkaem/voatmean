import 'package:flutter_test/flutter_test.dart';
import 'package:voatmean_mobile/main.dart';
import 'package:voatmean_mobile/core/constants/app_strings.dart';

void main() {
  testWidgets('App loads and shows splash screen or login', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const VoatmeanApp());

    // Verify that the app name is present (Splash or Login)
    expect(find.textContaining(AppStrings.appName), findsOneWidget);
  });
}
