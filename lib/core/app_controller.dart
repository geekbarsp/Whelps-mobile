import 'dart:math';
import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';

import '../data/repository.dart';
import '../models/models.dart';

enum AppThemePreference { defaultTheme, dark, light, system }

class AppController extends ChangeNotifier {
  final Random _random = Random.secure();
  final FurURepository repository;
  AppController(this.repository);
  List<Pet> pets = [];
  UserProfile? profile;
  List<Submission> submissions = [];
  List<UserProfile> managedUsers = [];
  List<AdminReviewCase> reviewCases = [];
  Map<String, dynamic> adminWorkspace = const {};
  bool adminLoading = false;
  Set<String> favorites = {};
  bool notificationsEnabled = true;
  AppThemePreference themePreference = AppThemePreference.defaultTheme;
  String? _credentialSalt;
  String? _credentialHash;
  bool get hasPassword => usesSecureBackend || _credentialHash != null;
  bool get isAdmin => profile?.isAdmin ?? false;
  bool get usesSecureBackend => repository is RemoteAuthRepository;
  bool passwordRecovery = false;
  StreamSubscription<void>? _passwordRecoverySubscription;
  bool loading = true;
  double loadingProgress = 0;
  String? error;
  Future<void> initialize() async {
    loading = true;
    loadingProgress = 0;
    error = null;
    notifyListeners();
    try {
      if (repository case RemoteAuthRepository remote) {
        _passwordRecoverySubscription ??= remote.passwordRecoveryEvents.listen((
          _,
        ) {
          passwordRecovery = true;
          notifyListeners();
        });
      }
      pets = await repository.fetchPets();
      loadingProgress = .5;
      notifyListeners();
      final email = await repository.loadSession();
      loadingProgress = .75;
      notifyListeners();
      if (email != null) {
        if (repository case RemoteAuthRepository remote) {
          final account = await remote.restoreRemoteAccount();
          if (account != null) _applyAccount(account);
        } else {
          await _restore(email);
        }
        if (isAdmin) await refreshAdminData();
      }
    } catch (_) {
      error = usesSecureBackend
          ? 'We could not connect to WHELPS. Check your internet connection and try again.'
          : 'We could not load your local data. Please try again.';
    }
    loading = false;
    loadingProgress = 1;
    notifyListeners();
  }

  Future<bool> _restore(String email) async {
    final data = await repository.loadAccount(email);
    if (data == null) return false;
    _applyAccount(data);
    return true;
  }

  void _applyAccount(Map<String, dynamic> data) {
    profile = UserProfile.fromJson(Map<String, dynamic>.from(data['profile']));
    favorites = Set<String>.from(data['favorites']);
    submissions = (data['submissions'] as List)
        .map((s) => Submission.fromJson(Map<String, dynamic>.from(s)))
        .toList();
    notificationsEnabled = data['notificationsEnabled'] as bool? ?? true;
    themePreference = AppThemePreference.values.firstWhere(
      (value) => value.name == data['themePreference'],
      orElse: () => AppThemePreference.defaultTheme,
    );
    _credentialSalt = data['credentialSalt'] as String?;
    _credentialHash = data['credentialHash'] as String?;
  }

  Map<String, dynamic> _data({
    UserProfile? user,
    List<Submission>? items,
    Set<String>? saved,
  }) => <String, dynamic>{
    'profile': (user ?? profile)!.toJson(),
    'favorites': (saved ?? favorites).toList(),
    'submissions': (items ?? submissions).map((s) => s.toJson()).toList(),
    'notificationsEnabled': notificationsEnabled,
    'themePreference': themePreference.name,
    if (_credentialSalt != null) 'credentialSalt': _credentialSalt,
    if (_credentialHash != null) 'credentialHash': _credentialHash,
  };

  String _newSalt() => List.generate(
    24,
    (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();

  String _hashPassword(String password, String salt) {
    var digest = sha256.convert(utf8.encode('$salt:$password'));
    for (var round = 0; round < 5000; round++) {
      digest = sha256.convert([...digest.bytes, ...utf8.encode(salt)]);
    }
    return digest.toString();
  }

  bool _sameHash(String first, String second) {
    if (first.length != second.length) return false;
    var difference = 0;
    for (var i = 0; i < first.length; i++) {
      difference |= first.codeUnitAt(i) ^ second.codeUnitAt(i);
    }
    return difference == 0;
  }

  Future<void> createAccount(UserProfile user, String password) async {
    final email = user.email.trim().toLowerCase();
    if (repository case RemoteAuthRepository remote) {
      final account = await remote.signUpRemote(
        user.copyWith(email: email, role: AccountRole.adopter),
        password,
      );
      if (account == null) {
        profile = null;
        notifyListeners();
        return;
      }
      _applyAccount(account);
      notifyListeners();
      return;
    }
    if (await repository.loadAccount(email) != null) {
      throw StateError(
        'An account already exists on this device. Sign in instead.',
      );
    }
    _credentialSalt = _newSalt();
    _credentialHash = _hashPassword(password, _credentialSalt!);
    profile = UserProfile(
      name: user.name,
      email: email,
      phone: user.phone,
      location: user.location,
    );
    favorites = {};
    submissions = [];
    notificationsEnabled = true;
    themePreference = AppThemePreference.defaultTheme;
    await repository.saveAccount(email, _data());
    await repository.saveSession(email);
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    email = email.trim().toLowerCase();
    if (repository case RemoteAuthRepository remote) {
      final data = await remote.signInRemote(email, password);
      _applyAccount(data);
      if (isAdmin) await refreshAdminData();
      notifyListeners();
      return;
    }
    final data = await repository.loadAccount(email);
    if (data == null) {
      throw StateError(
        'No account found on this device. Create an account first.',
      );
    }
    final salt = data['credentialSalt'] as String?;
    final storedHash = data['credentialHash'] as String?;
    if (salt != null && storedHash != null) {
      final candidate = _hashPassword(password, salt);
      if (!_sameHash(storedHash, candidate)) {
        throw StateError('That password is incorrect. Please try again.');
      }
    } else {
      // Seamlessly upgrades accounts created by earlier local builds.
      final newSalt = _newSalt();
      data['credentialSalt'] = newSalt;
      data['credentialHash'] = _hashPassword(password, newSalt);
      await repository.saveAccount(email, data);
    }
    _applyAccount(data);
    await repository.saveSession(email);
    if (isAdmin) await refreshAdminData();
    notifyListeners();
  }

  Future<void> resetPassword(String email, String newPassword) async {
    email = email.trim().toLowerCase();
    if (repository case RemoteAuthRepository remote) {
      await remote.sendPasswordReset(email);
      return;
    }
    final data = await repository.loadAccount(email);
    if (data == null) {
      throw StateError('No account with that email exists on this device.');
    }
    final account = UserProfile.fromJson(
      Map<String, dynamic>.from(data['profile'] as Map),
    );
    if (account.isAdmin) {
      throw StateError(
        'Administrator passwords cannot be reset from the public sign-in screen.',
      );
    }
    final salt = _newSalt();
    data['credentialSalt'] = salt;
    data['credentialHash'] = _hashPassword(newPassword, salt);
    await repository.saveAccount(email, data);
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    if (repository case RemoteAuthRepository remote) {
      await remote.updateRemotePassword(currentPassword, newPassword);
      return;
    }
    final email = profile!.email;
    final data = await repository.loadAccount(email);
    final salt = data?['credentialSalt'] as String?;
    final storedHash = data?['credentialHash'] as String?;
    if (data == null || salt == null || storedHash == null) {
      throw StateError(
        'Password changes are unavailable for this guest account.',
      );
    }
    if (!_sameHash(storedHash, _hashPassword(currentPassword, salt))) {
      throw StateError('Your current password is incorrect.');
    }
    final nextSalt = _newSalt();
    data['credentialSalt'] = nextSalt;
    data['credentialHash'] = _hashPassword(newPassword, nextSalt);
    await repository.saveAccount(email, data);
    _credentialSalt = nextSalt;
    _credentialHash = data['credentialHash'] as String;
  }

  Future<void> enterGuest() async {
    const email = 'guest@furu.local';
    if (await repository.loadAccount(email) == null) {
      await repository.saveAccount(
        email,
        _data(
          user: const UserProfile(
            name: 'Friend',
            email: email,
            location: 'Metro Manila',
          ),
          items: [],
          saved: {},
        ),
      );
    }
    await _restore(email);
    await repository.saveSession(email);
    notifyListeners();
  }

  Future<void> signOut() async {
    if (repository case RemoteAuthRepository remote) {
      await remote.signOutRemote();
    } else {
      await repository.saveSession(null);
    }
    profile = null;
    submissions = [];
    favorites = {};
    managedUsers = [];
    reviewCases = [];
    adminWorkspace = const {};
    _credentialSalt = null;
    _credentialHash = null;
    notifyListeners();
  }

  Future<void> completePasswordRecovery(String newPassword) async {
    if (repository is! RemoteAuthRepository) {
      throw StateError('Secure password recovery is not configured.');
    }
    final remote = repository as RemoteAuthRepository;
    await remote.completePasswordRecovery(newPassword);
    passwordRecovery = false;
    final account = await remote.restoreRemoteAccount();
    if (account != null) _applyAccount(account);
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile user) async {
    if (profile!.isAdmin) {
      user = user.copyWith(role: AccountRole.admin, verified: true);
    }
    await repository.saveAccount(profile!.email, _data(user: user));
    profile = user;
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    final next = {...favorites};
    if (!next.add(id)) next.remove(id);
    await repository.saveAccount(profile!.email, _data(saved: next));
    favorites = next;
    notifyListeners();
  }

  Future<void> setNotifications(bool enabled) async {
    final previous = notificationsEnabled;
    notificationsEnabled = enabled;
    try {
      await repository.saveAccount(profile!.email, _data());
      notifyListeners();
    } catch (_) {
      notificationsEnabled = previous;
      rethrow;
    }
  }

  Future<void> setThemePreference(AppThemePreference preference) async {
    final previous = themePreference;
    themePreference = preference;
    notifyListeners();
    try {
      await repository.saveAccount(profile!.email, _data());
    } catch (_) {
      themePreference = previous;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    if (isAdmin) {
      throw StateError('Administrator accounts require server review.');
    }
    final email = profile!.email;
    await repository.deleteAccount(email);
    await repository.saveSession(null);
    profile = null;
    submissions = [];
    favorites = {};
    notificationsEnabled = true;
    themePreference = AppThemePreference.defaultTheme;
    _credentialSalt = null;
    _credentialHash = null;
    notifyListeners();
  }

  Pet? petById(String? id) {
    for (final pet in pets) {
      if (pet.id == id) return pet;
    }
    return null;
  }

  Submission newDraft(SubmissionKind kind, {Pet? pet}) {
    if (kind == SubmissionKind.adoption) {
      if (pet == null || pet.availability != PetAvailability.available) {
        throw StateError('This pet is not accepting applications right now.');
      }
      for (final item in submissions) {
        if (item.petId == pet.id &&
            item.kind == kind &&
            item.status != ApplicationStatus.cancelled &&
            item.status != ApplicationStatus.rejected) {
          return item;
        }
      }
    }
    return Submission(
      id: List.generate(
        16,
        (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
      ).join(),
      kind: kind,
      petId: pet?.id,
      answers: {
        'Full name': profile!.name,
        'Email': profile!.email,
        'Phone number': profile!.phone,
        'Location': profile!.location,
      },
      updatedAt: DateTime.now(),
    );
  }

  Future<void> saveSubmission(Submission item) async {
    final next = [item, ...submissions.where((s) => s.id != item.id)];
    if (repository case RemoteSubmissionRepository remote) {
      await remote.persistSubmission(item);
    } else {
      await repository.saveAccount(profile!.email, _data(items: next));
    }
    submissions = next;
    notifyListeners();
  }

  Future<void> deleteDraft(String id) async {
    Submission? item;
    for (final submission in submissions) {
      if (submission.id == id) {
        item = submission;
        break;
      }
    }
    if (item == null || item.status != ApplicationStatus.draft) {
      throw StateError('Only drafts can be deleted.');
    }
    final next = submissions
        .where((submission) => submission.id != id)
        .toList();
    await repository.saveAccount(profile!.email, _data(items: next));
    submissions = next;
    notifyListeners();
  }

  Future<void> submit(Submission item) async {
    if (item.status != ApplicationStatus.draft) {
      throw StateError('This application has already been submitted.');
    }
    if (item.attachments.any((a) => a.bytes == null)) {
      throw StateError('Please reselect your attachments before submitting.');
    }
    if (item.kind == SubmissionKind.rehome &&
        !item.attachments.any((a) => a.isImage)) {
      throw StateError('Add at least one pet photo.');
    }
    await saveSubmission(item.copyWith(status: ApplicationStatus.submitted));
  }

  void _requireAdmin() {
    if (!isAdmin) throw StateError('Administrator access is required.');
  }

  Future<void> refreshAdminData() async {
    _requireAdmin();
    adminLoading = true;
    notifyListeners();
    if (repository case AdminRepository admin) {
      try {
        adminWorkspace = await admin.fetchAdminWorkspace();
        managedUsers = (adminWorkspace['users'] as List? ?? const [])
            .map((raw) => UserProfile.fromJson(_profileJsonFromAdminRow(raw)))
            .toList();
        reviewCases = _remoteReviewCases(adminWorkspace);
      } finally {
        adminLoading = false;
        notifyListeners();
      }
      return;
    }
    final accounts = await repository.loadAllAccounts();
    final users = <UserProfile>[];
    final cases = <AdminReviewCase>[];
    for (final data in accounts) {
      final owner = UserProfile.fromJson(
        Map<String, dynamic>.from(data['profile'] as Map),
      );
      if (!owner.isAdmin && owner.email != 'guest@furu.local') {
        users.add(owner);
      }
      for (final raw in (data['submissions'] as List? ?? const [])) {
        final submission = Submission.fromJson(
          Map<String, dynamic>.from(raw as Map),
        );
        if (!owner.isAdmin &&
            submission.status != ApplicationStatus.draft &&
            submission.status != ApplicationStatus.cancelled) {
          cases.add(AdminReviewCase(owner: owner, submission: submission));
        }
      }
    }
    users.sort((a, b) => a.name.compareTo(b.name));
    cases.sort(
      (a, b) => b.submission.updatedAt.compareTo(a.submission.updatedAt),
    );
    managedUsers = users;
    reviewCases = cases;
    adminLoading = false;
    notifyListeners();
  }

  Map<String, dynamic> _profileJsonFromAdminRow(dynamic raw) {
    final row = Map<String, dynamic>.from(raw as Map);
    return {
      'name': row['full_name'] ?? 'FurU member',
      'email': row['email'] ?? '',
      'phone': row['phone'] ?? '',
      'location': row['location'] ?? '',
      'organization': row['organization_name'] ?? '',
      'accountType': row['account_type'] ?? 'individual',
      'role': row['role'] == 'individual_rehomer'
          ? 'individualRehomer'
          : row['role'] ?? 'adopter',
      'verificationRequested': row['verification_status'] == 'pending',
      'verified': row['verification_status'] == 'verified',
    };
  }

  List<AdminReviewCase> _remoteReviewCases(Map<String, dynamic> workspace) {
    final users = <String, UserProfile>{};
    for (final raw in workspace['users'] as List? ?? const []) {
      final row = Map<String, dynamic>.from(raw as Map);
      users[row['id'].toString()] = UserProfile.fromJson(
        _profileJsonFromAdminRow(row),
      );
    }
    return (workspace['applications'] as List? ?? const []).map((raw) {
      final row = Map<String, dynamic>.from(raw as Map);
      final status = (row['status'] as String? ?? 'submitted').replaceAll(
        '_review',
        'Review',
      );
      return AdminReviewCase(
        owner:
            users[row['applicant_id'].toString()] ??
            const UserProfile(name: 'Unknown member', email: ''),
        submission: Submission(
          id: row['id'].toString(),
          kind: SubmissionKind.adoption,
          petId: row['pet_id']?.toString(),
          answers: Map<String, String>.from(row['answers'] as Map? ?? const {}),
          attachments: (row['document_names'] as List? ?? const [])
              .map((name) => Attachment(name.toString()))
              .toList(),
          status: ApplicationStatus.values.firstWhere(
            (value) => value.name == status,
            orElse: () => ApplicationStatus.submitted,
          ),
          updatedAt:
              DateTime.tryParse(row['updated_at']?.toString() ?? '') ??
              DateTime.now(),
          reviewNote: row['review_note'] as String? ?? '',
          reviewedAt: DateTime.tryParse(row['reviewed_at']?.toString() ?? ''),
        ),
      );
    }).toList();
  }

  Future<void> runAdminAction(
    String action,
    Map<String, dynamic> payload,
  ) async {
    _requireAdmin();
    if (repository is! AdminRepository) {
      throw StateError('This action requires the configured secure backend.');
    }
    final admin = repository as AdminRepository;
    await admin.invokeAdminAction(action, payload);
    await refreshAdminData();
  }

  Future<void> reviewSubmission({
    required String ownerEmail,
    required String submissionId,
    required ApplicationStatus status,
    String note = '',
  }) async {
    _requireAdmin();
    if (!const [
      ApplicationStatus.underReview,
      ApplicationStatus.approved,
      ApplicationStatus.rejected,
    ].contains(status)) {
      throw StateError('Choose a valid review decision.');
    }
    if (repository is AdminRepository) {
      await runAdminAction('review_application', {
        'application_id': submissionId,
        'status': status == ApplicationStatus.underReview
            ? 'under_review'
            : status.name,
        'reason': note.trim(),
      });
      return;
    }
    final data = await repository.loadAccount(ownerEmail);
    if (data == null) throw StateError('The applicant account was not found.');
    final items = (data['submissions'] as List? ?? const [])
        .map(
          (raw) => Submission.fromJson(Map<String, dynamic>.from(raw as Map)),
        )
        .toList();
    final index = items.indexWhere((item) => item.id == submissionId);
    if (index < 0) throw StateError('The submission was not found.');
    items[index] = items[index].copyWith(
      status: status,
      reviewNote: note.trim(),
      reviewedAt: DateTime.now(),
    );
    data['submissions'] = items.map((item) => item.toJson()).toList();
    await repository.saveAccount(ownerEmail, data);
    await refreshAdminData();
  }

  Future<void> setUserVerification(String email, bool verified) async {
    _requireAdmin();
    if (repository is AdminRepository) {
      Map<String, dynamic>? user;
      for (final raw in adminWorkspace['users'] as List? ?? const []) {
        final row = Map<String, dynamic>.from(raw as Map);
        if (row['email'] == email) {
          user = row;
          break;
        }
      }
      if (user == null) throw StateError('The user account was not found.');
      await runAdminAction('verify_organization', {
        'user_id': user['id'],
        'status': verified ? 'verified' : 'revoked',
        'reason': verified ? 'Verification approved' : 'Verification revoked',
      });
      return;
    }
    final data = await repository.loadAccount(email);
    if (data == null) throw StateError('The user account was not found.');
    final user = UserProfile.fromJson(
      Map<String, dynamic>.from(data['profile'] as Map),
    ).copyWith(verified: verified, verificationRequested: false);
    data['profile'] = user.toJson();
    await repository.saveAccount(email, data);
    await refreshAdminData();
  }

  Future<void> setPetAvailability(
    String petId,
    PetAvailability availability,
  ) async {
    _requireAdmin();
    await repository.savePetAvailability(petId, availability);
    pets = await repository.fetchPets();
    notifyListeners();
  }
}

class AppScope extends InheritedNotifier<AppController> {
  const AppScope({
    super.key,
    required AppController controller,
    required super.child,
  }) : super(notifier: controller);
  static AppController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
