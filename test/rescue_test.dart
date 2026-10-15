import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:furu/core/app_controller.dart';
import 'package:furu/core/theme.dart';
import 'package:furu/data/repository.dart';
import 'package:furu/features/rescue/rescue_screen.dart';
import 'package:furu/main.dart';

void main() {
  for (final width in [320.0, 390.0, 768.0]) {
    testWidgets('Rescue contacts and message fit $width px', (tester) async {
      tester.view.physicalSize = Size(width, 850);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(theme: buildTheme(), home: const RescueScreen()),
      );
      await tester.pumpAndSettle();
      expect(find.text('Contact for Rescue'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(
        find.text('Copy rescue message'),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(
        find.widgetWithText(OutlinedButton, 'Copy rescue message'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'Rescue is reachable from welcome and home without account type selection',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final app = AppController(
        LocalFurURepository(await SharedPreferences.getInstance()),
      );
      await app.initialize();
      await tester.pumpWidget(FurUApp(controller: app));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Contact for Rescue'));
      await tester.tap(find.text('Contact for Rescue'));
      await tester.pumpAndSettle();
      expect(find.text('Who you can contact'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await app.enterGuest();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rescue').first);
      await tester.pumpAndSettle();
      expect(find.text('Contact for Rescue'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
