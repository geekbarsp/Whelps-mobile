import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:furu/core/theme.dart';
import 'package:furu/features/home/our_story_screen.dart';

void main() {
  testWidgets('Our Story is readable and its FAQs expand on a narrow phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: const MediaQuery(
          data: MediaQueryData(
            size: Size(320, 800),
            textScaler: TextScaler.linear(1.6),
          ),
          child: OurStoryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Where happy\nbeginnings start.'), findsOneWidget);
    expect(tester.takeException(), isNull);

    for (var i = 0; i < 16; i++) {
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();
    }
    expect(find.text('Things people often ask.'), findsOneWidget);
    await tester.ensureVisible(find.text('How does rehabilitation work?'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('How does rehabilitation work?'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Care plans are tailored'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
