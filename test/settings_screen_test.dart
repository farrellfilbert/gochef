import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_chef_app/screens/profile/settings_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'pref_push_notif_0': true,
      'pref_email_notif_0': true,
      'pref_sms_alerts_0': false,
      'pref_language_0': 'English',
      'pref_appearance_0': 'Dark',
      'pref_cache_size_0': '14.2 MB',
    });
  });

  testWidgets('SettingsScreen renders all sections and interactive items', (WidgetTester tester) async {
    // Set realistic mobile phone screen size
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: SettingsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify sections exist
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('ACCOUNT SETTINGS'), findsOneWidget);
    expect(find.text('PREFERENCES'), findsOneWidget);

    // Verify Account Settings tiles
    expect(find.text('Personal Information'), findsOneWidget);
    expect(find.text('Password & Security'), findsOneWidget);
    expect(find.text('Social Accounts'), findsOneWidget);
    expect(find.text('Delete Account'), findsOneWidget);

    // Scroll to see Preferences & App Settings
    await tester.scrollUntilVisible(find.text('Storage & Cache'), 200);
    await tester.pumpAndSettle();

    expect(find.text('Privacy & Data'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);

    // Verify App Settings items
    expect(find.text('Storage & Cache'), findsOneWidget);
    expect(find.text('Version Info'), findsOneWidget);
    expect(find.text('Clear Search History'), findsOneWidget);

    // Tap Version Info to ensure modal opens without crashing
    await tester.tap(find.text('Version Info'));
    await tester.pumpAndSettle();
    expect(find.text('GoChef Version'), findsOneWidget);
    expect(find.text('v2.4.0 (Build 128)'), findsOneWidget);
  });
}
