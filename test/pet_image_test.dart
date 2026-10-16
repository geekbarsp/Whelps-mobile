import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:furu/data/whelps_api_repository.dart';
import 'package:furu/models/models.dart';
import 'package:furu/widgets/components.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

Pet petWithPhoto(String photo) => Pet(
  id: 'buddy',
  name: 'Buddy',
  species: 'Dog',
  breed: 'Labrador',
  sex: 'Male',
  size: 'Medium',
  location: 'Whelps',
  photo: photo,
  ageMonths: 5,
  description: 'Friendly',
  traits: const [],
  health: const [],
);

void main() {
  testWidgets('PetImage uses the network for website pet photos', (
    tester,
  ) async {
    const url = 'https://whelps.test/images/pets/buddy.webp';
    await tester.pumpWidget(MaterialApp(home: PetImage(petWithPhoto(url))));

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<NetworkImage>());
    expect((image.image as NetworkImage).url, url);
  });

  testWidgets('PetImage keeps bundled pet photos as assets', (tester) async {
    const path = 'assets/pets/buddy.jpg';
    await tester.pumpWidget(MaterialApp(home: PetImage(petWithPhoto(path))));

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<AssetImage>());
    expect((image.image as AssetImage).assetName, path);
  });

  test(
    'API pet paths resolve against the website and data images survive',
    () async {
      SharedPreferences.setMockInitialValues({});
      final rows = [
        {'id': 'buddy', 'name': 'Buddy', 'image': '/images/pets/buddy.webp'},
        {
          'id': 'upload',
          'name': 'Upload',
          'image': 'data:image/png;base64,${base64Encode([1, 2, 3])}',
        },
      ];
      final repository = WhelpsApiRepository(
        baseUrl: 'https://whelps.test',
        preferences: await SharedPreferences.getInstance(),
        client: MockClient(
          (_) async => http.Response(jsonEncode({'pets': rows}), 200),
        ),
      );

      final pets = await repository.fetchPets();
      expect(pets.first.photo, 'https://whelps.test/images/pets/buddy.webp');
      expect(pets.last.photo, startsWith('data:image/png;base64,'));
    },
  );
}
