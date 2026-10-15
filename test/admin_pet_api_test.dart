import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:furu/data/whelps_api_repository.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Create pet uses the authenticated API and requires later review',
    () async {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({
        'whelps.session.token': 'test-token',
      });
      var calls = 0;
      final repository = WhelpsApiRepository(
        baseUrl: 'https://whelps.test',
        preferences: await SharedPreferences.getInstance(),
        client: MockClient((request) async {
          calls++;
          expect(request.method, 'POST');
          expect(request.url.path, '/api/admin/pets');
          expect(request.headers['Authorization'], 'Bearer test-token');
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['name'], 'Luna');
          expect(body['fixedStatus'], 'Spayed');
          expect(body['published'], false);
          expect(body['healthVerification'], 'Pending Verification');
          expect(body.containsKey('unrelated'), false);
          return http.Response('{"pet":{"id":"PET-1"}}', 201);
        }),
      );
      await repository.invokeAdminAction('create_pet', {
        'name': 'Luna',
        'type': 'Cat',
        'breed': 'Persian',
        'age': '2 years',
        'gender': 'Female',
        'image': 'https://example.com/luna.jpg',
        'fixedStatus': 'Spayed',
        'vaccinationStatus': 'Vaccinated',
        'description': 'Gentle companion',
        'healthNotes': '',
        'published': true,
        'healthVerification': 'Verified',
        'unrelated': 'ignored',
      });
      expect(calls, 1);
    },
  );

  test('Pet creation reports a rejected API request', () async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({
      'whelps.session.token': 'test-token',
    });
    final repository = WhelpsApiRepository(
      baseUrl: 'https://whelps.test',
      preferences: await SharedPreferences.getInstance(),
      client: MockClient(
        (_) async => http.Response(
          '{"error":"Complete all required pet and health fields."}',
          400,
        ),
      ),
    );
    await expectLater(
      repository.invokeAdminAction('create_pet', {}),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('required pet'),
        ),
      ),
    );
  });
}
