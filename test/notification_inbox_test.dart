import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:furu/core/theme.dart';
import 'package:furu/widgets/notification_inbox.dart';

const inboxItems = [
  {
    'id': 'n1',
    'type': 'APPLICATION_CANCELLED',
    'message': 'Francis cancelled the adoption request for Buddy.',
    'createdAt': '2026-10-16T10:24:00',
    'isRead': false,
  },
  {
    'id': 'n2',
    'type': 'NEW_APPLICATION',
    'message': 'A new adoption application was submitted for Buddy.',
    'createdAt': '2026-10-16T09:18:00',
    'isRead': false,
  },
  {
    'id': 'n3',
    'type': 'NEW_MESSAGE',
    'message': 'ANGEL GARCIA sent a message about Luna.',
    'createdAt': '2026-10-15T16:32:00',
    'isRead': true,
  },
];
Widget inbox({
  bool dark = false,
  void Function(Map<String, dynamic>)? open,
  Future<void> Function(List<String>, bool)? action,
}) => MaterialApp(
  theme: dark ? buildDarkTheme() : buildTheme(),
  home: FurUNotificationInbox(
    items: inboxItems,
    onRefresh: () async {},
    onOpen: open ?? (_) {},
    onAction: action ?? (_, _) async {},
  ),
);

void main() {
  testWidgets(
    'Select reveals unchecked boxes, Select all selects visible category, Cancel hides boxes',
    (tester) async {
      List<String>? changed;
      bool? deleted;
      final pending = Completer<void>();
      var opened = 0;
      await tester.pumpWidget(
        inbox(
          open: (_) => opened++,
          action: (ids, delete) {
            changed = ids;
            deleted = delete;
            return pending.future;
          },
        ),
      );
      expect(find.byType(Checkbox), findsNothing);
      await tester.tap(find.text(inboxItems.first['message'] as String));
      expect(opened, 1);
      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();
      expect(find.byType(Checkbox), findsNWidgets(3));
      expect(
        tester
            .widgetList<Checkbox>(find.byType(Checkbox))
            .every((box) => box.value == false),
        isTrue,
      );
      expect(find.text('Select all'), findsOneWidget);
      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();
      expect(find.text('1 selected'), findsOneWidget);
      expect(opened, 1);
      await tester.tap(find.text('Applications'));
      await tester.pumpAndSettle();
      expect(find.text('0 selected'), findsOneWidget);
      expect(find.byType(Checkbox), findsNWidgets(2));
      await tester.tap(find.text('Select all'));
      await tester.pumpAndSettle();
      expect(find.text('2 selected'), findsOneWidget);
      await tester.tap(find.text('Mark as read'));
      await tester.pump();
      expect(changed, ['n1', 'n2']);
      expect(deleted, false);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      pending.complete();
      await tester.pumpAndSettle();
      expect(find.byType(Checkbox), findsNothing);
      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(Checkbox), findsNothing);
    },
  );

  testWidgets('Delete confirms and a failed action preserves selection', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      inbox(
        action: (_, delete) async {
          expect(delete, isTrue);
          calls++;
          throw StateError('Unavailable');
        },
      ),
    );
    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select all'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(calls, 0);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(find.text('3 selected'), findsOneWidget);
    expect(
      find.text('Could not delete notifications. Please try again.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'Inbox fits narrow phones, dark mode and enlarged text while selecting',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      for (final dark in [false, true]) {
        await tester.pumpWidget(inbox(dark: dark));
        await tester.pumpAndSettle();
        if (find.text('Select').evaluate().isNotEmpty) {
          await tester.tap(find.text('Select'));
          await tester.pumpAndSettle();
        }
        for (final width in [320.0, 360.0, 390.0, 412.0]) {
          for (final scale in [1.0, 1.7]) {
            tester.view.physicalSize = Size(width, 844);
            tester.platformDispatcher.textScaleFactorTestValue = scale;
            await tester.pumpAndSettle();
            expect(
              tester.takeException(),
              isNull,
              reason: '$width, scale $scale, dark $dark',
            );
          }
        }
      }
    },
  );
}
