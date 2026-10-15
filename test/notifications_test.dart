import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:furu/core/app_controller.dart';
import 'package:furu/core/theme.dart';
import 'package:furu/data/repository.dart';
import 'package:furu/data/whelps_api_repository.dart';
import 'package:furu/features/admin/admin_shell.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _NotificationSource extends LocalFurURepository
    implements NotificationRepository {
  _NotificationSource(super.preferences);
  Completer<List<Map<String, dynamic>>> response = Completer();
  @override
  Future<List<Map<String, dynamic>>> fetchNotifications() => response.future;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({
      'whelps.session.token': 'test-token',
    });
  });

  test('Notification inbox uses the authenticated website endpoint', () async {
    final repository = WhelpsApiRepository(
      baseUrl: 'https://whelps.test',
      preferences: await SharedPreferences.getInstance(),
      client: MockClient((request) async {
        expect(request.url.path, '/api/notifications');
        expect(request.method, 'GET');
        expect(request.headers['Authorization'], 'Bearer test-token');
        return http.Response(
          jsonEncode({
            'notifications': [
              {
                'id': 'n1',
                'message': 'Application received',
                'isRead': false,
                'applicationId': 'a1',
              },
            ],
          }),
          200,
        );
      }),
    );
    final items = await repository.fetchNotifications();
    expect(items.single['message'], 'Application received');
    expect(items.single['applicationId'], 'a1');
    expect(items.single['isRead'], false);
  });

  test('Failed notification requests do not become empty inboxes', () async {
    final repository = WhelpsApiRepository(
      baseUrl: 'https://whelps.test',
      preferences: await SharedPreferences.getInstance(),
      client: MockClient(
        (_) async => http.Response('{"error":"Unavailable"}', 503),
      ),
    );
    await expectLater(repository.fetchNotifications(), throwsStateError);
  });

  testWidgets(
    'Bell handles loading, retry, empty and populated notifications',
    (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final source = _NotificationSource(await SharedPreferences.getInstance());
      final app = AppController(source);
      await app.initialize();
      await tester.pumpWidget(
        AppScope(
          controller: app,
          child: MaterialApp(theme: buildTheme(), home: const AdminShell()),
        ),
      );
      await tester.tap(find.byTooltip('Notifications').first);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('All quiet for now'), findsNothing);
      source.response.completeError(StateError('Offline'));
      await tester.pumpAndSettle();
      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('All quiet for now'), findsNothing);
      source.response = Completer();
      await tester.tap(find.text('Try again'));
      source.response.complete([]);
      await tester.pumpAndSettle();
      expect(find.text('All quiet for now'), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      source.response = Completer()
        ..complete([
          {'id': 'n1', 'message': 'Luna has a new update', 'isRead': false},
        ]);
      await tester.tap(find.byTooltip('Notifications').first);
      await tester.pumpAndSettle();
      expect(find.text('Luna has a new update'), findsOneWidget);
      expect(find.text('All quiet for now'), findsNothing);
      await tester.tap(find.text('Luna has a new update'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
