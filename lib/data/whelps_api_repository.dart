import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';
import 'pets.dart';
import 'repository.dart';

/// Connects the mobile client to the same protected API and PostgreSQL data
/// used by the WHELPS website. Only the short-lived session token is stored in
/// secure device storage; database credentials never enter the app.
class WhelpsApiRepository
    implements
        FurURepository,
        RemoteAuthRepository,
        RemoteSubmissionRepository,
        AdminRepository {
  WhelpsApiRepository({
    required String baseUrl,
    required this.preferences,
    http.Client? client,
    FlutterSecureStorage? secureStorage,
  }) : baseUrl = baseUrl.replaceFirst(RegExp(r'/+$'), ''),
       _client = client ?? http.Client(),
       _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final String baseUrl;
  final SharedPreferences preferences;
  final http.Client _client;
  final FlutterSecureStorage _secureStorage;
  static const _tokenKey = 'whelps.session.token';
  static const _emailKey = 'whelps.session.email';
  static const _localKey = 'whelps.mobile.preferences';
  static const _requestTimeout = Duration(seconds: 15);
  Map<String, dynamic>? _currentUser;
  List<Map<String, dynamic>> _adminPets = const [];
  List<Map<String, dynamic>> _adminApplications = const [];

  @override
  Stream<void> get passwordRecoveryEvents => const Stream<void>.empty();

  Future<Map<String, String>> _headers({bool authenticated = false}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'X-Whelps-Client': 'mobile',
    };
    if (authenticated) {
      final token = await _secureStorage.read(key: _tokenKey);
      if (token == null || token.isEmpty) {
        throw StateError('Your session has expired. Sign in again.');
      }
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> _request(
    String path, {
    String method = 'GET',
    bool authenticated = false,
    Map<String, dynamic>? body,
  }) async {
    late http.Response response;
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _headers(authenticated: authenticated);
    try {
      response = switch (method) {
        'POST' => await _client.post(
          uri,
          headers: headers,
          body: jsonEncode(body ?? const {}),
        ).timeout(_requestTimeout),
        'PATCH' => await _client.patch(
          uri,
          headers: headers,
          body: jsonEncode(body ?? const {}),
        ).timeout(_requestTimeout),
        _ => await _client
            .get(uri, headers: headers)
            .timeout(_requestTimeout),
      };
    } on Exception {
      throw StateError(
        'WHELPS is unreachable. Check your internet connection and try again.',
      );
    }
    Map<String, dynamic> data = const {};
    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map) data = Map<String, dynamic>.from(decoded);
      } catch (_) {
        throw StateError('WHELPS returned an invalid response.');
      }
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (response.statusCode == 401) {
        await _clearSession();
      }
      throw StateError(
        '${data['error'] ?? 'The request could not be completed.'}',
      );
    }
    return data;
  }

  Future<void> _storeSession(Map<String, dynamic> data) async {
    final token = data['sessionToken']?.toString();
    final user = _map(data['user']);
    if (token == null || token.isEmpty || user.isEmpty) {
      throw StateError('WHELPS did not return a valid mobile session.');
    }
    _currentUser = user;
    await _secureStorage.write(key: _tokenKey, value: token);
    await _secureStorage.write(
      key: _emailKey,
      value: user['email']?.toString(),
    );
  }

  Future<void> _clearSession() async {
    _currentUser = null;
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _emailKey);
  }

  @override
  Future<List<Pet>> fetchPets() async {
    final data = await _request('/api/pets');
    return _list(data['pets']).map(_petFromRow).toList();
  }

  Pet _petFromRow(Map<String, dynamic> row) {
    final image = '${row['image'] ?? ''}';
    return Pet(
      id: '${row['id']}',
      name: '${row['name'] ?? 'Pet'}',
      species: '${row['type'] ?? 'Animal'}',
      breed: '${row['breed'] ?? 'Mixed breed'}',
      sex: '${row['gender'] ?? 'Unknown'}',
      size: 'Medium',
      location: 'Whelps Animal Care & Rehabilitation Center',
      photo: image.startsWith('http')
          ? image
          : image.startsWith('/')
          ? '$baseUrl$image'
          : samplePets.first.photo,
      ageMonths: _ageMonths('${row['age'] ?? ''}'),
      description: '${row['description'] ?? ''}',
      traits: const [],
      health: [
        if ('${row['fixedStatus'] ?? row['fixed_status'] ?? ''}'.isNotEmpty)
          '${row['fixedStatus'] ?? row['fixed_status']}',
        if ('${row['vaccinationStatus'] ?? row['vaccination_status'] ?? ''}'
            .isNotEmpty)
          '${row['vaccinationStatus'] ?? row['vaccination_status']}',
        if ('${row['healthNotes'] ?? row['health_notes'] ?? ''}'.isNotEmpty)
          '${row['healthNotes'] ?? row['health_notes']}',
      ],
      rehomer: 'Whelps Animal Care & Rehabilitation Center',
      availability: _petStatus('${row['availability'] ?? 'Available'}'),
    );
  }

  int _ageMonths(String value) {
    final amount = int.tryParse(RegExp(r'\d+').firstMatch(value)?.group(0) ?? '');
    if (amount == null) return 0;
    return value.toLowerCase().contains('month') ? amount : amount * 12;
  }

  PetAvailability _petStatus(String value) => switch (value.toLowerCase()) {
    'available' => PetAvailability.available,
    'on hold' || 'pending' => PetAvailability.pending,
    'adopted' => PetAvailability.adopted,
    _ => PetAvailability.unavailable,
  };

  UserProfile _profile(Map<String, dynamic> user) => UserProfile(
    name: '${user['name'] ?? 'FurU friend'}',
    email: '${user['email'] ?? ''}',
    phone: '${user['phone'] ?? ''}',
    region: '${user['region'] ?? ''}',
    city: '${user['city'] ?? ''}',
    location: [
      '${user['city'] ?? ''}',
      '${user['region'] ?? ''}',
    ].where((value) => value.isNotEmpty).join(', '),
    role: '${user['role']}' == 'ADMIN'
        ? AccountRole.admin
        : AccountRole.adopter,
    verified: '${user['role']}' == 'ADMIN',
  );

  Map<String, dynamic> _local() {
    final raw = preferences.getString(_localKey);
    if (raw == null) return <String, dynamic>{};
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  Future<void> _saveLocal(Map<String, dynamic> value) async {
    if (!await preferences.setString(_localKey, jsonEncode(value))) {
      throw StateError('Could not save settings on this device.');
    }
  }

  Future<Map<String, dynamic>> _account(Map<String, dynamic> user) async {
    _currentUser = user;
    final applications = '${user['role']}' == 'ADMIN'
        ? <Map<String, dynamic>>[]
        : _list(
            (await _request(
              '/api/applications',
              authenticated: true,
            ))['applications'],
          );
    final local = _local();
    final remote = applications.map(_submissionFromApplication).toList();
    final drafts = _list(local['drafts'])
        .map(Submission.fromJson)
        .where((item) => item.status == ApplicationStatus.draft)
        .where((draft) => !remote.any((item) => item.id == draft.id));
    return {
      'profile': _profile(user).toJson(),
      'favorites': List<String>.from(local['favorites'] as List? ?? const []),
      'submissions': [
        ...drafts.map((item) => item.toJson()),
        ...remote.map((item) => item.toJson()),
      ],
      'notificationsEnabled': local['notificationsEnabled'] ?? true,
      'themePreference': local['themePreference'] ?? 'defaultTheme',
    };
  }

  Submission _submissionFromApplication(Map<String, dynamic> row) => Submission(
    id: '${row['id']}',
    kind: SubmissionKind.adoption,
    petId: '${row['petId'] ?? row['pet_id'] ?? ''}',
    answers: {
      'Full name': '${row['fullName'] ?? row['full_name'] ?? ''}',
      'Email': '${row['email'] ?? ''}',
      'Phone number': '${row['contact'] ?? ''}',
      'Location': '${row['address'] ?? ''}',
      'Home type': '${row['housingType'] ?? row['housing_type'] ?? ''}',
      'Pets allowed by housing': '${row['petsAllowed'] ?? row['pets_allowed'] ?? ''}',
      'Safe space for the pet': '${row['housingDetails'] ?? row['housing_details'] ?? ''}',
      'Monthly household income range': '${row['incomeRange'] ?? row['income_range'] ?? ''}',
      'Veterinary and financial care plan': '${row['financialSupport'] ?? row['financial_support'] ?? ''}',
      'Pet experience': '${row['petExperience'] ?? row['pet_experience'] ?? ''}',
      'Daily care and time alone': '${row['experienceDetails'] ?? row['experience_details'] ?? ''}',
      'Reason for adoption': '${row['reason'] ?? ''}',
    },
    status: _applicationStatus('${row['status'] ?? ''}'),
    updatedAt:
        DateTime.tryParse('${row['updatedAt'] ?? row['updated_at'] ?? ''}') ??
        DateTime.now(),
    reviewNote: '${row['latestUpdate'] ?? row['latest_update'] ?? ''}',
    reviewedAt: DateTime.tryParse('${row['reviewedAt'] ?? ''}'),
  );

  ApplicationStatus _applicationStatus(String status) {
    final value = status.toLowerCase();
    if (value.contains('under review') || value.contains('information')) {
      return ApplicationStatus.underReview;
    }
    if (value.contains('approved') || value.contains('completed')) {
      return ApplicationStatus.approved;
    }
    if (value.contains('rejected')) return ApplicationStatus.rejected;
    if (value.contains('cancelled')) return ApplicationStatus.cancelled;
    return ApplicationStatus.submitted;
  }

  @override
  Future<Map<String, dynamic>?> restoreRemoteAccount() async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) return null;
    try {
      final data = await _request('/api/auth/me', authenticated: true);
      final user = _map(data['user']);
      if (user.isEmpty) return null;
      return await _account(user);
    } catch (_) {
      await _clearSession();
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>> signInRemote(
    String email,
    String password,
  ) async {
    final data = await _request(
      '/api/auth/login',
      method: 'POST',
      body: {'email': email, 'password': password},
    );
    await _storeSession(data);
    return _account(_map(data['user']));
  }

  @override
  Future<Map<String, dynamic>?> signUpRemote(
    UserProfile profile,
    String password,
  ) async {
    final data = await _request(
      '/api/auth/register',
      method: 'POST',
      body: {
        'name': profile.name,
        'email': profile.email,
        'phone': profile.phone,
        'region': profile.region,
        'city': profile.city,
        'password': password,
      },
    );
    await _storeSession(data);
    return _account(_map(data['user']));
  }

  @override
  Future<void> signOutRemote() async {
    try {
      await _request('/api/auth/logout', method: 'POST', authenticated: true);
    } finally {
      await _clearSession();
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async => throw StateError(
    'Password recovery is not available yet. Contact Whelps for account help.',
  );

  @override
  Future<void> completePasswordRecovery(String password) async =>
      throw StateError('Open account settings to change your password.');

  @override
  Future<void> updateRemotePassword(
    String currentPassword,
    String password,
  ) async {
    final user = _currentUser;
    if (user == null) throw StateError('Your session has expired.');
    await _request(
      '/api/auth/me',
      method: 'PATCH',
      authenticated: true,
      body: {
        'name': user['name'],
        'email': user['email'],
        'phone': user['phone'],
        'region': user['region'],
        'city': user['city'],
        'currentPassword': currentPassword,
        'newPassword': password,
      },
    );
  }

  @override
  Future<String?> loadSession() => _secureStorage.read(key: _emailKey);

  @override
  Future<void> saveSession(String? email) async {
    if (email == null) await _clearSession();
  }

  @override
  Future<Map<String, dynamic>?> loadAccount(String email) async =>
      restoreRemoteAccount();

  @override
  Future<List<Map<String, dynamic>>> loadAllAccounts() async => const [];

  @override
  Future<void> saveAccount(String email, Map<String, dynamic> data) async {
    final profile = Map<String, dynamic>.from(data['profile'] as Map);
    final local = _local()
      ..['favorites'] = data['favorites'] ?? const []
      ..['notificationsEnabled'] = data['notificationsEnabled'] ?? true
      ..['themePreference'] = data['themePreference'] ?? 'defaultTheme'
      ..['drafts'] = (data['submissions'] as List? ?? const [])
          .where((raw) => (raw as Map)['status'] == 'draft')
          .toList();
    await _saveLocal(local);
    if (_currentUser == null) return;
    final region = '${profile['region'] ?? _currentUser!['region'] ?? ''}';
    final city = '${profile['city'] ?? _currentUser!['city'] ?? ''}';
    final result = await _request(
      '/api/auth/me',
      method: 'PATCH',
      authenticated: true,
      body: {
        'name': profile['name'],
        'email': profile['email'],
        'phone': profile['phone'],
        'region': region,
        'city': city,
      },
    );
    _currentUser = _map(result['user']);
  }

  @override
  Future<void> deleteAccount(String email) async => throw StateError(
    'Account deletion requires Whelps support review. Contact the center from Help & support.',
  );

  @override
  Future<void> savePetAvailability(
    String petId,
    PetAvailability availability,
  ) async {
    await invokeAdminAction('set_pet_status', {
      'pet_id': petId,
      'status': switch (availability) {
        PetAvailability.available => 'Available',
        PetAvailability.pending => 'On Hold',
        PetAvailability.adopted => 'Adopted',
        PetAvailability.unavailable => 'Unavailable',
      },
    });
  }

  @override
  Future<void> persistSubmission(Submission submission) async {
    final local = _local();
    if (submission.status == ApplicationStatus.draft) {
      final drafts = _list(local['drafts'])
        ..removeWhere((row) => '${row['id']}' == submission.id)
        ..insert(0, submission.toJson());
      local['drafts'] = drafts;
      await _saveLocal(local);
      return;
    }
    if (submission.kind == SubmissionKind.rehome) {
      throw StateError(
        'Online rehoming intake is not enabled by the WHELPS website yet. Contact the rescue center to submit this pet.',
      );
    }
    final a = submission.answers;
    await _request(
      '/api/applications',
      method: 'POST',
      authenticated: true,
      body: {
        'petId': submission.petId,
        'fullName': a['Full name'],
        'email': a['Email'],
        'contact': a['Phone number'],
        'address': a['Location'],
        'reason': a['Reason for adoption'],
        'housingType': a['Home type'],
        'petsAllowed': a['Pets allowed by housing'],
        'housingDetails': [
          a['Housing arrangement'],
          a['Household members'],
          a['Safe space for the pet'],
        ].where((value) => (value ?? '').isNotEmpty).join(' · '),
        'incomeRange': a['Monthly household income range'],
        'financialSupport': a['Veterinary and financial care plan'],
        'petExperience': a['Pet experience'] == 'First-time pet parent'
            ? 'No'
            : 'Yes',
        'experienceDetails': [
          a['Pet experience'],
          a['Current pets'],
          a['Daily care and time alone'],
        ].where((value) => (value ?? '').isNotEmpty).join(' · '),
      },
    );
    final drafts = _list(local['drafts'])
      ..removeWhere((row) => '${row['id']}' == submission.id);
    local['drafts'] = drafts;
    await _saveLocal(local);
  }

  @override
  Future<Map<String, dynamic>> fetchAdminWorkspace() async {
    final results = await Future.wait([
      _request('/api/admin/applications', authenticated: true),
      _request('/api/admin/pets', authenticated: true),
      _request('/api/monitoring', authenticated: true),
      _request('/api/conversations?filter=all', authenticated: true),
      _request('/api/admin/evaluation', authenticated: true),
    ]);
    _adminApplications = _list(results[0]['applications']);
    _adminPets = _list(results[1]['pets']);
    final monitoring = results[2];
    final evaluation = _map(results[4]['metrics']);
    final statistics = _map(results[0]['statistics']);
    final applications = _adminApplications.map(_adminApplication).toList();
    final pets = _adminPets.map(_adminPet).toList();
    final placements = _list(monitoring['placements']);
        final records = _list(monitoring['records']);
    return {
      'stats': {
        'adopters': statistics['users'] ?? 0,
        'available_pets': statistics['availablePets'] ?? 0,
        'applications': statistics['total'] ?? applications.length,
        'completed_adoptions': statistics['completed'] ?? 0,
        'unread_messages': statistics['unreadMessages'] ?? 0,
        'pending_applications': statistics['submitted'] ?? 0,
      },
      'applications': applications,
      'pets': pets,
      'adoption_records': placements.map((row) => {
        'id': row['id'],
        'pet_name': row['petName'],
        'adopter_name': row['adopterName'],
        'status': '${row['status']}'.toLowerCase(),
      }).toList(),
      'monitoring_updates': records.map((row) => {
        'id': row['id'],
        'pet_name': row['petName'],
        'adopter_name': row['adopterName'],
        'pet_condition': row['petCondition'],
        'feeding': row['feedingUpdate'],
        'health': row['healthObservations'],
        'behavior': row['behaviorUpdate'],
        'created_at': row['submittedAt'],
        'status': '${row['reviewStatus']}' == 'Pending Review'
            ? 'pending_review'
            : '${row['reviewStatus']}'.toLowerCase().replaceAll(' ', '_'),
      }).toList(),
      'conversations': _list(results[3]['conversations']),
      'users': const [],
      'verifications': const [],
      'analytics': {
        'monthly_applications': _list(evaluation['monthlyApplications'])
            .map((row) => {'month': row['month'], 'total': row['count']})
            .toList(),
        'monthly_adoptions': _list(evaluation['monthlyAdoptions'])
            .map((row) => {'month': row['month'], 'total': row['count']})
            .toList(),
      },
      'evaluation': evaluation,
    };
  }

  Map<String, dynamic> _adminApplication(Map<String, dynamic> row) => {
    ...row,
    'id': row['id'],
    'applicant_id': row['applicantUserId'] ?? row['applicant_user_id'],
    'applicant_name': row['fullName'] ?? row['full_name'],
    'applicant_email': row['email'],
    'pet_name': row['petName'],
    'pet_id': row['petId'],
    'status': _adminStatus('${row['status']}'),
    'submitted_at': row['submittedAt'],
    'updated_at': row['updatedAt'],
    'version': row['version'],
  };

  String _adminStatus(String value) {
    final status = value.toLowerCase();
    if (status == 'submitted') return 'submitted';
    if (status.contains('under review') || status.contains('information')) {
      return 'under_review';
    }
    if (status.contains('approved')) return 'approved';
    if (status.contains('completed')) return 'completed';
    if (status.contains('rejected')) return 'rejected';
    if (status.contains('cancelled')) return 'cancelled';
    return status.replaceAll(' ', '_');
  }

  Map<String, dynamic> _adminPet(Map<String, dynamic> row) => {
    ...row,
    'species': row['type'],
    'health': [
      row['fixedStatus'] ?? row['fixed_status'],
      row['vaccinationStatus'] ?? row['vaccination_status'],
      row['healthNotes'] ?? row['health_notes'],
    ].where((value) => value != null && '$value'.isNotEmpty).toList(),
    'listing_status': '${row['availability']}' == 'Adopted'
        ? 'adopted'
        : '${row['healthVerification'] ?? row['health_verification']}' ==
              'Verified'
        ? 'active'
        : 'pending',
  };

  @override
  Future<void> invokeAdminAction(
    String action,
    Map<String, dynamic> payload,
  ) async {
    if (action == 'review_application') {
      final id = '${payload['application_id']}';
      final row = _adminApplications.firstWhere((item) => '${item['id']}' == id);
      final status = '${payload['status']}';
      final apiAction = switch (status) {
        'more_information' => 'requestInfo',
        'approved' || 'screened' => 'approve',
        'rejected' || 'flagged' => 'reject',
        _ => 'saveReview',
      };
      await _request(
        '/api/admin/applications/$id',
        method: 'PATCH',
        authenticated: true,
        body: {
          'action': apiAction,
          'version': row['version'],
          'housingEvaluation': payload['housing_evaluation'],
          'financialEvaluation': payload['financial_evaluation'],
          'experienceEvaluation': payload['experience_evaluation'],
          'readinessEvaluation': payload['readiness_evaluation'],
          'internalNotes': payload['reason'],
          'message': payload['reason'],
          'reason': payload['reason'],
        },
      );
      return;
    }
    if (action == 'review_monitoring') {
      await _request(
        '/api/monitoring',
        method: 'PATCH',
        authenticated: true,
        body: {
          'id': payload['monitoring_update_id'],
          'action': 'review',
          'reviewStatus': payload['status'] == 'reviewed'
              ? 'Reviewed'
              : 'Needs Clarification',
          'adminNotes': payload['reason'],
        },
      );
      return;
    }
    if (action == 'send_message') {
      await _request(
        '/api/conversations/${payload['conversation_id']}/messages',
        method: 'POST',
        authenticated: true,
        body: {
          'content': payload['body'],
          'clientRequestId': DateTime.now().microsecondsSinceEpoch.toString(),
        },
      );
      return;
    }
    if (action == 'set_pet_status' || action == 'review_pet') {
      final id = '${payload['pet_id']}';
      final pet = _adminPets.firstWhere((item) => '${item['id']}' == id);
      final requested = '${payload['status']}';
      final verified = requested == 'active' || requested == 'Available';
      await _request(
        '/api/admin/pets',
        method: 'PATCH',
        authenticated: true,
        body: {
          'id': id,
          'name': pet['name'],
          'breed': pet['breed'],
          'age': pet['age'],
          'gender': pet['gender'],
          'fixedStatus': pet['fixedStatus'] ?? pet['fixed_status'],
          'vaccinationStatus':
              pet['vaccinationStatus'] ?? pet['vaccination_status'],
          'healthNotes': pet['healthNotes'] ?? pet['health_notes'],
          'description': pet['description'],
          'healthVerification': verified
              ? 'Verified'
              : 'Pending Verification',
          'availability': requested == 'adopted' ? 'Adopted' : 'Available',
          'published': verified,
        },
      );
      return;
    }
    throw StateError('This administrator action is not available in WHELPS.');
  }

  static Map<String, dynamic> _map(Object? value) => value is Map
      ? Map<String, dynamic>.from(value)
      : <String, dynamic>{};

  static List<Map<String, dynamic>> _list(Object? value) => value is List
      ? value.whereType<Map>().map(Map<String, dynamic>.from).toList()
      : <Map<String, dynamic>>[];
}
