import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:furu/data/whelps_api_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('pet discovery opens with bundled pets while the API is offline', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = WhelpsApiRepository(
      baseUrl: 'https://example.test',
      preferences: preferences,
      client: MockClient((_) async => throw http.ClientException('offline')),
    );

    final pets = await repository.fetchPets();

    expect(pets, isNotEmpty);
  });

  test('last successful pet list is reused while the API is offline', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    var online = true;
    final repository = WhelpsApiRepository(
      baseUrl: 'https://example.test',
      preferences: preferences,
      client: MockClient((_) async {
        if (!online) throw http.ClientException('offline');
        return http.Response(
          jsonEncode({
            'pets': [
              {
                'id': 'cached-pet',
                'name': 'Pepper',
                'type': 'Dog',
                'breed': 'Mixed breed',
                'gender': 'Female',
                'age': '8 months',
                'availability': 'Available',
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    expect((await repository.fetchPets()).single.name, 'Pepper');
    online = false;
    expect((await repository.fetchPets()).single.name, 'Pepper');
  });
}
