import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/backend_config.dart';
import '../models/models.dart';
import 'pets.dart';
import 'repository.dart';

class SupabaseFurURepository
    implements
        FurURepository,
        RemoteAuthRepository,
        AdminRepository,
        RemoteSubmissionRepository {
  final SupabaseClient client;
  SupabaseFurURepository(this.client);

  String get _userId {
    final id = client.auth.currentUser?.id;
    if (id == null) {
      throw StateError('Your session has expired. Sign in again.');
    }
    return id;
  }

  @override
  Stream<void> get passwordRecoveryEvents => client.auth.onAuthStateChange
      .where((event) => event.event == AuthChangeEvent.passwordRecovery)
      .map((_) {});

  @override
  Future<List<Pet>> fetchPets() async {
    final rows = await client
        .from('pets')
        .select(
          'id,name,species,breed,sex,size,location,description,age_months,'
          'traits,health,listing_status,photo_url,rehomer:profiles!owner_id(full_name,organization_name)',
        )
        .order('created_at', ascending: false);
    return (rows as List).map((raw) {
      final row = Map<String, dynamic>.from(raw as Map);
      final owner = row['rehomer'] is Map
          ? Map<String, dynamic>.from(row['rehomer'] as Map)
          : const <String, dynamic>{};
      final remotePhoto = row['photo_url'] as String?;
      return Pet(
        id: row['id'].toString(),
        name: row['name'] as String? ?? 'Pet',
        species: row['species'] as String? ?? 'Animal',
        breed: row['breed'] as String? ?? 'Mixed breed',
        sex: row['sex'] as String? ?? 'Unknown',
        size: row['size'] as String? ?? 'Unknown',
        location: row['location'] as String? ?? '',
        photo: remotePhoto?.isNotEmpty == true
            ? remotePhoto!
            : samplePets.first.photo,
        ageMonths: row['age_months'] as int? ?? 0,
        description: row['description'] as String? ?? '',
        traits: List<String>.from(row['traits'] as List? ?? const []),
        health: List<String>.from(row['health'] as List? ?? const []),
        rehomer:
            (owner['organization_name'] as String?)?.trim().isNotEmpty == true
            ? owner['organization_name'] as String
            : owner['full_name'] as String? ?? 'FurU community',
        availability: _petAvailability(row['listing_status'] as String?),
      );
    }).toList();
  }

  PetAvailability _petAvailability(String? value) => switch (value) {
    'active' || 'approved' => PetAvailability.available,
    'pending' || 'corrections_requested' => PetAvailability.pending,
    'adopted' => PetAvailability.adopted,
    _ => PetAvailability.unavailable,
  };

  Future<Map<String, dynamic>> _account() async {
    final profileRow = await client
        .from('profiles')
        .select()
        .eq('id', _userId)
        .single();
    final profile = Map<String, dynamic>.from(profileRow);
    final favoriteRows = await client
        .from('favorites')
        .select('pet_id')
        .eq('user_id', _userId);
    final adoptionRows = await client
        .from('adoption_applications')
        .select()
        .eq('applicant_id', _userId);
    final rehomeRows = await client
        .from('rehome_submissions')
        .select()
        .eq('owner_id', _userId);
    return {
      'profile': _profileFromRow(profile).toJson(),
      'favorites': (favoriteRows as List)
          .map((row) => (row as Map)['pet_id'].toString())
          .toList(),
      'submissions': [
        ...(adoptionRows as List).map(
          (row) => _submissionFromRow(
            Map<String, dynamic>.from(row as Map),
            SubmissionKind.adoption,
          ).toJson(),
        ),
        ...(rehomeRows as List).map(
          (row) => _submissionFromRow(
            Map<String, dynamic>.from(row as Map),
            SubmissionKind.rehome,
          ).toJson(),
        ),
      ],
      'notificationsEnabled': profile['notifications_enabled'] ?? true,
      'themePreference': profile['theme_preference'] ?? 'defaultTheme',
    };
  }

  UserProfile _profileFromRow(Map<String, dynamic> row) => UserProfile(
    name: row['full_name'] as String? ?? 'FurU friend',
    email: row['email'] as String? ?? client.auth.currentUser?.email ?? '',
    phone: row['phone'] as String? ?? '',
    location: row['location'] as String? ?? '',
    organization: row['organization_name'] as String? ?? '',
    accountType: row['account_type'] == 'organization'
        ? AccountType.organization
        : AccountType.individual,
    role: switch (row['role']) {
      'admin' => AccountRole.admin,
      'organization' => AccountRole.organization,
      'individual_rehomer' => AccountRole.individualRehomer,
      _ => AccountRole.adopter,
    },
    verificationRequested:
        row['verification_status'] == 'pending' ||
        row['verification_status'] == 'more_information',
    verified: row['verification_status'] == 'verified',
  );

  Submission _submissionFromRow(
    Map<String, dynamic> row,
    SubmissionKind kind,
  ) => Submission(
    id: row['id'].toString(),
    kind: kind,
    petId: row['pet_id']?.toString(),
    answers: Map<String, String>.from(row['answers'] as Map? ?? const {}),
    attachments: (row['document_names'] as List? ?? const [])
        .map((name) => Attachment(name.toString()))
        .toList(),
    status: ApplicationStatus.values.firstWhere(
      (status) => status.name == _camelStatus(row['status'] as String?),
      orElse: () => ApplicationStatus.submitted,
    ),
    step: row['draft_step'] as int? ?? 0,
    updatedAt:
        DateTime.tryParse(row['updated_at'] as String? ?? '') ?? DateTime.now(),
    reviewNote: row['review_note'] as String? ?? '',
    reviewedAt: DateTime.tryParse(row['reviewed_at'] as String? ?? ''),
  );

  String _camelStatus(String? value) => value == 'under_review'
      ? 'underReview'
      : value == 'changes_requested'
      ? 'submitted'
      : value ?? 'submitted';

  @override
  Future<Map<String, dynamic>?> restoreRemoteAccount() async =>
      client.auth.currentSession == null ? null : _account();

  @override
  Future<Map<String, dynamic>> signInRemote(
    String email,
    String password,
  ) async {
    await client.auth.signInWithPassword(email: email, password: password);
    return _account();
  }

  @override
  Future<Map<String, dynamic>?> signUpRemote(
    UserProfile profile,
    String password,
  ) async {
    final response = await client.auth.signUp(
      email: profile.email,
      password: password,
      data: {'full_name': profile.name},
      emailRedirectTo: BackendConfig.passwordResetRedirect,
    );
    return response.session == null ? null : _account();
  }

  @override
  Future<void> sendPasswordReset(String email) =>
      client.auth.resetPasswordForEmail(
        email,
        redirectTo: BackendConfig.passwordResetRedirect,
      );

  @override
  Future<void> updateRemotePassword(
    String currentPassword,
    String password,
  ) async {
    final email = client.auth.currentUser?.email;
    if (email == null) throw StateError('Your session has expired.');
    await client.auth.signInWithPassword(
      email: email,
      password: currentPassword,
    );
    await client.auth.updateUser(UserAttributes(password: password));
  }

  @override
  Future<void> completePasswordRecovery(String password) async {
    await client.auth.updateUser(UserAttributes(password: password));
  }

  @override
  Future<void> signOutRemote() => client.auth.signOut();

  @override
  Future<List<Map<String, dynamic>>> loadAllAccounts() async =>
      throw UnsupportedError('Use the protected admin workspace RPC.');

  @override
  Future<Map<String, dynamic>?> loadAccount(String email) async =>
      client.auth.currentSession == null ? null : _account();

  @override
  Future<void> saveAccount(String email, Map<String, dynamic> data) async {
    final profile = Map<String, dynamic>.from(data['profile'] as Map);
    await client
        .from('profiles')
        .update({
          'full_name': profile['name'],
          'phone': profile['phone'],
          'location': profile['location'],
          'organization_name': profile['organization'],
          'notifications_enabled': data['notificationsEnabled'],
          'theme_preference': data['themePreference'],
        })
        .eq('id', _userId);

    await client.from('favorites').delete().eq('user_id', _userId);
    final favoriteIds = List<String>.from(
      data['favorites'] as List? ?? const [],
    );
    if (favoriteIds.isNotEmpty) {
      await client
          .from('favorites')
          .insert(
            favoriteIds
                .map((id) => {'user_id': _userId, 'pet_id': id})
                .toList(),
          );
    }

    for (final raw in data['submissions'] as List? ?? const []) {
      final item = Map<String, dynamic>.from(raw as Map);
      final kind = item['kind'] as String;
      final table = kind == 'adoption'
          ? 'adoption_applications'
          : 'rehome_submissions';
      await client.from(table).upsert({
        'id': item['id'],
        kind == 'adoption' ? 'applicant_id' : 'owner_id': _userId,
        if (kind == 'adoption') 'pet_id': item['petId'],
        'answers': item['answers'],
        'document_names': (item['attachments'] as List? ?? const [])
            .map((value) => (value as Map)['name'])
            .toList(),
        'status': _snakeStatus(item['status'] as String),
        'draft_step': item['step'],
        'updated_at': item['updatedAt'],
      });
    }
  }

  String _snakeStatus(String value) =>
      value == 'underReview' ? 'under_review' : value;

  @override
  Future<void> deleteAccount(String email) async {
    await client.rpc('request_account_deletion');
    await client.auth.signOut();
  }

  @override
  Future<String?> loadSession() async => client.auth.currentUser?.email;

  @override
  Future<void> saveSession(String? email) async {
    if (email == null) await client.auth.signOut();
  }

  @override
  Future<void> savePetAvailability(
    String petId,
    PetAvailability availability,
  ) => invokeAdminAction('set_pet_status', {
    'pet_id': petId,
    'status': switch (availability) {
      PetAvailability.available => 'active',
      PetAvailability.pending => 'pending',
      PetAvailability.adopted => 'adopted',
      PetAvailability.unavailable => 'removed',
    },
  });

  @override
  Future<Map<String, dynamic>> fetchAdminWorkspace() async {
    final result = await client.rpc('admin_workspace');
    if (result is! Map) throw StateError('The admin response was invalid.');
    return Map<String, dynamic>.from(result);
  }

  @override
  Future<void> invokeAdminAction(
    String action,
    Map<String, dynamic> payload,
  ) async {
    await client.rpc(
      'admin_action',
      params: {'p_action': action, 'p_payload': payload},
    );
  }

  @override
  Future<void> persistSubmission(Submission submission) async {
    final paths = <String>[];
    final bucket = submission.kind == SubmissionKind.adoption
        ? 'adoption-documents'
        : 'pet-images';
    for (final attachment in submission.attachments) {
      final bytes = attachment.bytes;
      if (bytes == null) {
        paths.add(attachment.name);
        continue;
      }
      final safeName = attachment.name.replaceAll(
        RegExp(r'[^A-Za-z0-9._-]'),
        '_',
      );
      final path = '$_userId/${submission.id}/$safeName';
      await client.storage
          .from(bucket)
          .uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );
      paths.add(path);
    }
    final table = submission.kind == SubmissionKind.adoption
        ? 'adoption_applications'
        : 'rehome_submissions';
    await client.from(table).upsert({
      'id': submission.id,
      submission.kind == SubmissionKind.adoption ? 'applicant_id' : 'owner_id':
          _userId,
      if (submission.kind == SubmissionKind.adoption)
        'pet_id': submission.petId,
      'answers': submission.answers,
      'document_names': paths,
      'status': _snakeStatus(submission.status.name),
      'draft_step': submission.step,
      'updated_at': submission.updatedAt.toIso8601String(),
    });
  }
}
