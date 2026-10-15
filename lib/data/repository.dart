import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';
import 'pets.dart';

/// Data boundary shared by the WHELPS API client and deterministic local tests.
abstract class FurURepository {
  Future<List<Pet>> fetchPets();
  Future<List<Map<String, dynamic>>> loadAllAccounts();
  Future<Map<String, dynamic>?> loadAccount(String email);
  Future<void> saveAccount(String email, Map<String, dynamic> data);
  Future<void> deleteAccount(String email);
  Future<String?> loadSession();
  Future<void> saveSession(String? email);
  Future<void> savePetAvailability(String petId, PetAvailability availability);
}

/// Implemented only by the production WHELPS API source. Authentication is
/// deliberately separate from profile persistence so a profile row can never
/// grant itself administrator authority.
abstract interface class RemoteAuthRepository {
  Stream<void> get passwordRecoveryEvents;
  Future<Map<String, dynamic>?> restoreRemoteAccount();
  Future<Map<String, dynamic>> signInRemote(String email, String password);
  Future<Map<String, dynamic>?> signUpRemote(
    UserProfile profile,
    String password,
  );
  Future<void> sendPasswordReset(String email);
  Future<void> updateRemotePassword(String currentPassword, String password);
  Future<void> completePasswordRecovery(String password);
  Future<void> signOutRemote();
}

/// Privileged calls are implemented as server-verified RPCs. The Flutter
/// client never receives a service-role key and never performs direct admin
/// table updates.
abstract interface class AdminRepository {
  Future<Map<String, dynamic>> fetchAdminWorkspace();
  Future<void> invokeAdminAction(String action, Map<String, dynamic> payload);
}

abstract interface class RemoteSubmissionRepository {
  Future<void> persistSubmission(Submission submission);
}

abstract interface class NotificationRepository {
  Future<List<Map<String, dynamic>>> fetchNotifications();
}

class LocalFurURepository implements FurURepository {
  final SharedPreferences preferences;
  LocalFurURepository(this.preferences);
  @override
  Future<List<Pet>> fetchPets() async {
    final raw = preferences.getString('furu.petAvailability');
    final saved = raw == null
        ? <String, dynamic>{}
        : jsonDecode(raw) as Map<String, dynamic>;
    return samplePets
        .map(
          (pet) => pet.copyWith(
            availability: PetAvailability.values.firstWhere(
              (value) => value.name == saved[pet.id],
              orElse: () => PetAvailability.available,
            ),
          ),
        )
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> loadAllAccounts() async {
    final accounts = <Map<String, dynamic>>[];
    for (final key in preferences.getKeys()) {
      if (!key.startsWith('furu.account.')) continue;
      final raw = preferences.getString(key);
      if (raw == null) continue;
      try {
        accounts.add(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        // One damaged local account must not hide the remaining review queue.
      }
    }
    return accounts;
  }

  @override
  Future<Map<String, dynamic>?> loadAccount(String email) async {
    final raw = preferences.getString('furu.account.$email');
    return raw == null ? null : jsonDecode(raw) as Map<String, dynamic>;
  }

  @override
  Future<void> saveAccount(String email, Map<String, dynamic> data) async {
    if (!await preferences.setString('furu.account.$email', jsonEncode(data))) {
      throw StateError('Could not save on this device. Please try again.');
    }
  }

  @override
  Future<void> deleteAccount(String email) async {
    if (!await preferences.remove('furu.account.$email')) {
      throw StateError('Could not remove this account from the device.');
    }
  }

  @override
  Future<String?> loadSession() async => preferences.getString('furu.session');
  @override
  Future<void> saveSession(String? email) async {
    final ok = email == null
        ? await preferences.remove('furu.session')
        : await preferences.setString('furu.session', email);
    if (!ok) throw StateError('Could not update your local session.');
  }

  @override
  Future<void> savePetAvailability(
    String petId,
    PetAvailability availability,
  ) async {
    final raw = preferences.getString('furu.petAvailability');
    final saved = raw == null
        ? <String, dynamic>{}
        : Map<String, dynamic>.from(jsonDecode(raw) as Map);
    saved[petId] = availability.name;
    if (!await preferences.setString(
      'furu.petAvailability',
      jsonEncode(saved),
    )) {
      throw StateError('Could not update this pet. Please try again.');
    }
  }
}
