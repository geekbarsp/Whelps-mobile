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

  testWidgets('Progress follows input and animation settles on arrival', (
    tester,
  ) async {
    Widget screen(double progress) =>
        MaterialApp(home: FurULoadingScreen(progress: progress));
    await tester.pumpWidget(screen(0));
    await tester.pump(const Duration(seconds: 4));
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      0,
    );
    await tester.pumpWidget(screen(.5));
    await tester.pump(const Duration(seconds: 1));
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      .5,
    );
    await tester.pumpWidget(screen(1));
    await tester.pumpAndSettle();
    expect(find.text('Welcome home'), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      1,
    );
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('Loading layout fits phone widths in light and dark mode', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final dark in [false, true]) {
      for (final width in [320.0, 360.0, 390.0, 412.0]) {
        tester.view.physicalSize = Size(width, 700);
        await tester.pumpWidget(
          MaterialApp(
            theme: dark ? ThemeData.dark() : ThemeData.light(),
            home: const MediaQuery(
              data: MediaQueryData(
                disableAnimations: true,
                textScaler: TextScaler.linear(1.7),
              ),
              child: FurULoadingScreen(progress: .5),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$width / dark: $dark');
      }
    }
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
