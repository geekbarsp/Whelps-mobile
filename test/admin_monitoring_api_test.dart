import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:furu/data/whelps_api_repository.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({
      'whelps.session.token': 'test-token',
    });
  });

  test(
    'Monitoring preserves photos, placement links and both kinds of notes',
    () async {
      final repository = WhelpsApiRepository(
        baseUrl: 'https://whelps.test',
        preferences: await SharedPreferences.getInstance(),
        client: MockClient((request) async {
          expect(request.url.path, '/api/admin/workspace');
          return http.Response(
            jsonEncode({
              'monitoring': {
                'placements': [
                  {
                    'id': 'p1',
                    'petName': 'Luna',
                    'petImage': '/luna.jpg',
                    'adopterName': 'Angel',
                    'applicationStatus': 'Approved — Awaiting Placement',
                    'status': 'Monitoring',
                  },
                ],
                'records': [
                  {
                    'id': 'm1',
                    'placementId': 'p1',
                    'petName': 'Luna',
                    'petImage': '/luna.jpg',
                    'adopterName': 'Angel',
                    'submittedAt': '2026-10-15T10:00:00Z',
                    'petCondition': 'Active',
                    'feedingUpdate': 'Twice daily',
                    'healthObservations': 'Vet visit booked',
                    'behaviorUpdate': 'Settling in',
                    'notes': 'Adopter note',
                    'adminNotes': 'Staff note',
                    'reviewStatus': 'Pending Review',
                  },
                ],
              },
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );
      final workspace = await repository.fetchAdminWorkspace();
      final placement = (workspace['adoption_records'] as List).single as Map;
      expect(placement['petImage'], '/luna.jpg');
      expect(placement['applicationStatus'], 'Approved — Awaiting Placement');
      final update = (workspace['monitoring_updates'] as List).single as Map;
      expect(update['placementId'], 'p1');
      expect(update['petImage'], '/luna.jpg');
      expect(update['notes'], 'Adopter note');
      expect(update['admin_notes'], 'Staff note');
      expect(update['status'], 'pending_review');
      expect(update['feeding'], 'Twice daily');
    },
  );

  for (final clarification in [false, true]) {
    test(
      'Monitoring review sends staff notes and correct status ($clarification)',
      () async {
        var calls = 0;
        final repository = WhelpsApiRepository(
          baseUrl: 'https://whelps.test',
          preferences: await SharedPreferences.getInstance(),
          client: MockClient((request) async {
            calls++;
            expect(request.method, 'PATCH');
            expect(request.url.path, '/api/monitoring');
            expect(request.headers['Authorization'], 'Bearer test-token');
            final body = jsonDecode(request.body) as Map;
            expect(body['id'], 'm1');
            expect(body['action'], 'review');
            expect(
              body['reviewStatus'],
              clarification ? 'Needs Clarification' : 'Reviewed',
            );
            expect(
              body['adminNotes'],
              'Please confirm the next veterinary appointment.',
            );
            return http.Response('{"ok":true,"completed":false}', 200);
          }),
        );
        await repository.invokeAdminAction('review_monitoring', {
          'monitoring_update_id': 'm1',
          'status': clarification ? 'needs_clarification' : 'reviewed',
          'reason': 'Please confirm the next veterinary appointment.',
        });
        expect(calls, 1);
      },
    );
  }
}
