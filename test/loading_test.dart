import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:furu/widgets/loading_screen.dart';
import 'package:furu/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Actual startup shows the dog before fast local data completes', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await app.main();
    await tester.pump();
    expect(find.byType(FurULoadingScreen), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(FurULoadingScreen), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.byType(FurULoadingScreen), findsNothing);
    expect(find.text('New here? Create an account'), findsOneWidget);
  });

  testWidgets(
    'Loading fits a narrow phone with large text and reduced motion',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              disableAnimations: true,
              textScaler: TextScaler.linear(2),
            ),
            child: FurULoadingScreen(progress: .75),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        tester
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .value,
        .75,
      );
      expect(tester.binding.hasScheduledFrame, isFalse);
    },
  );
}
