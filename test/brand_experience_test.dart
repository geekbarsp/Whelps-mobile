import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:furu/core/theme.dart';
import 'package:furu/widgets/brand_experience.dart';

void main() {
  testWidgets(
    'Reference content fits 320px with large text and reduced motion',
    (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var browseCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              disableAnimations: true,
              textScaler: const TextScaler.linear(2),
            ),
            child: child!,
          ),
          home: Scaffold(
            body: Builder(
              builder: (context) => ListView(
                children: [
                  CompanionPortrait(
                    height: 350,
                    compact: true,
                    onBrowse: () => browseCount++,
                  ),
                  TextButton(
                    onPressed: () => showOurStory(context),
                    child: const Text('Our story'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(tester.binding.hasScheduledFrame, isFalse);
      await tester.tap(find.text('Meet the pets'));
      await tester.pumpAndSettle();
      expect(browseCount, 1);
      await tester.tap(find.text('Our story'));
      await tester.pumpAndSettle();
      expect(find.text('Your journey home'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Back to the pets'));
      await tester.tap(find.text('Back to the pets'));
      await tester.pumpAndSettle();
      expect(find.text('Your journey home'), findsNothing);
    },
  );
}
