import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:furu/core/app_controller.dart';
import 'package:furu/data/repository.dart';
import 'package:furu/models/models.dart';
import 'package:furu/features/applications/workflow_fields.dart';

void main() {
  test(
    'Trusted local admin fixture can review users, submissions, and pets',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final member = AppController(LocalFurURepository(preferences));
      await member.initialize();
      await member.createAccount(
        const UserProfile(name: 'Applicant', email: 'person@example.com'),
        'memberpass',
      );
      await member.updateProfile(
        member.profile!.copyWith(verificationRequested: true),
      );
      final draft = member.newDraft(
        SubmissionKind.adoption,
        pet: member.pets.first,
      );
      await member.submit(draft);
      final submissionId = member.submissions.single.id;
      await member.signOut();

      final repository = LocalFurURepository(preferences);
      await repository.saveAccount('admin@test.invalid', {
        'profile': const UserProfile(
          name: 'Test administrator',
          email: 'admin@test.invalid',
          role: AccountRole.admin,
          verified: true,
        ).toJson(),
        'favorites': <String>[],
        'submissions': <Map<String, dynamic>>[],
        'notificationsEnabled': true,
        'themePreference': AppThemePreference.defaultTheme.name,
      });
      await repository.saveSession('admin@test.invalid');
      final admin = AppController(repository);
      await admin.initialize();
      expect(admin.isAdmin, isTrue);
      expect(admin.managedUsers.single.email, 'person@example.com');
      expect(admin.reviewCases.single.submission.id, submissionId);

      await admin.reviewSubmission(
        ownerEmail: 'person@example.com',
        submissionId: submissionId,
        status: ApplicationStatus.approved,
        note: 'Ready for a meet and greet.',
      );
      await admin.setUserVerification('person@example.com', true);
      await admin.setPetAvailability(
        admin.pets.first.id,
        PetAvailability.pending,
      );
      await admin.signOut();

      final restored = AppController(LocalFurURepository(preferences));
      await restored.initialize();
      await restored.signIn('person@example.com', 'memberpass');
      expect(restored.profile!.verified, isTrue);
      expect(restored.submissions.single.status, ApplicationStatus.approved);
      expect(
        restored.submissions.single.reviewNote,
        'Ready for a meet and greet.',
      );
      expect(restored.pets.first.availability, PetAvailability.pending);
    },
  );

  test('Local startup never seeds administrator credentials', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = LocalFurURepository(
      await SharedPreferences.getInstance(),
    );
    final app = AppController(repository);
    await app.initialize();
    expect(await repository.loadAllAccounts(), isEmpty);
    expect(app.profile, isNull);
  });

  test('Regular members cannot perform administrator decisions', () async {
    SharedPreferences.setMockInitialValues({});
    final app = AppController(
      LocalFurURepository(await SharedPreferences.getInstance()),
    );
    await app.initialize();
    await app.createAccount(
      const UserProfile(name: 'Member', email: 'member@example.com'),
      'memberpass',
    );
    expect(
      () => app.setPetAvailability('milo', PetAvailability.adopted),
      throwsA(isA<StateError>()),
    );
  });

  late LocalFurURepository repo;
  late AppController app;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repo = LocalFurURepository(await SharedPreferences.getInstance());
    app = AppController(repo);
    await app.initialize();
    await app.enterGuest();
  });
  test('Favorites, profile and draft resume after restart', () async {
    await app.toggleFavorite('milo');
    final draft = app
        .newDraft(SubmissionKind.adoption, pet: app.pets.first)
        .copyWith(
          answers: {'Full name': 'Sample', 'Home type': 'House'},
          step: 2,
        );
    await app.saveSubmission(draft);
    final restored = AppController(repo);
    await restored.initialize();
    expect(restored.profile!.name, 'Friend');
    expect(restored.favorites, {'milo'});
    expect(restored.submissions.single.step, 2);
    expect(restored.submissions.single.answers['Home type'], 'House');
  });
  test('Accounts do not share drafts or favorites', () async {
    await app.toggleFavorite('milo');
    await app.saveSubmission(app.newDraft(SubmissionKind.rehome));
    await app.signOut();
    await app.createAccount(
      const UserProfile(name: 'Representative', email: 'shelter@example.com'),
      'strong-password',
    );
    expect(app.favorites, isEmpty);
    expect(app.submissions, isEmpty);
    await app.signOut();
    await app.enterGuest();
    expect(app.favorites, {'milo'});
    expect(app.submissions, hasLength(1));
  });
  test('Rehoming requires a photo and never publishes immediately', () async {
    final draft = app.newDraft(SubmissionKind.rehome);
    await expectLater(app.submit(draft), throwsStateError);
    final withPhoto = draft.copyWith(
      attachments: [
        Attachment(
          'sample.jpg',
          isImage: true,
          bytes: Uint8List.fromList([1, 2, 3]),
        ),
      ],
    );
    await app.submit(withPhoto);
    expect(app.submissions.single.status, ApplicationStatus.submitted);
    expect(app.pets, hasLength(4));
    await expectLater(app.submit(app.submissions.single), throwsStateError);
  });
  test(
    'Attachment bytes never persist and restored files need reselection',
    () async {
      final draft = app
          .newDraft(SubmissionKind.rehome)
          .copyWith(
            attachments: [
              Attachment(
                'sample.jpg',
                isImage: true,
                bytes: Uint8List.fromList([1, 2, 3]),
              ),
            ],
          );
      await app.saveSubmission(draft);
      final restored = AppController(repo);
      await restored.initialize();
      expect(restored.submissions.single.attachments.single.bytes, isNull);
      await expectLater(
        restored.submit(restored.submissions.single),
        throwsStateError,
      );
    },
  );
  test(
    'Existing adoption resumes and cancellation allows a new application',
    () async {
      final draft = app.newDraft(SubmissionKind.adoption, pet: app.pets.first);
      await app.saveSubmission(draft);
      expect(
        app.newDraft(SubmissionKind.adoption, pet: app.pets.first).id,
        draft.id,
      );
      await app.saveSubmission(
        draft.copyWith(status: ApplicationStatus.cancelled),
      );
      expect(
        app.newDraft(SubmissionKind.adoption, pet: app.pets.first).id,
        isNot(draft.id),
      );
    },
  );
  test('Form validation rejects invalid contact and age values', () {
    expect(validateAnswer(const FieldSpec('Email'), 'invalid'), isNotNull);
    expect(validateAnswer(const FieldSpec('Phone number'), '12'), isNotNull);
    expect(validateAnswer(const FieldSpec('Age in months'), '-1'), isNotNull);
    expect(validateAnswer(const FieldSpec('Age in months'), '24'), isNull);
    expect(
      validateAnswer(const FieldSpec('Current pets', optional: true), ''),
      isNull,
    );
    expect(
      workflowSteps(SubmissionKind.rehome)
          .expand((s) => s.fields)
          .any((f) => f.label == 'Organization name'),
      isFalse,
    );
  });
  test('Local account checks and resets passwords', () async {
    await app.signOut();
    const profile = UserProfile(name: 'Jamie', email: 'jamie@example.com');
    await app.createAccount(profile, 'first-password');
    await app.signOut();
    await expectLater(
      app.signIn(profile.email, 'wrong-password'),
      throwsStateError,
    );
    await app.signIn(profile.email, 'first-password');
    expect(app.profile!.name, 'Jamie');
    await app.signOut();
    await app.resetPassword(profile.email, 'second-password');
    await expectLater(
      app.signIn(profile.email, 'first-password'),
      throwsStateError,
    );
    await app.signIn(profile.email, 'second-password');
    expect(app.profile!.email, profile.email);
  });
  test('Only drafts can be deleted', () async {
    final draft = app.newDraft(SubmissionKind.rehome);
    await app.saveSubmission(draft);
    await app.deleteDraft(draft.id);
    expect(app.submissions, isEmpty);
    final submitted = draft.copyWith(status: ApplicationStatus.submitted);
    await app.saveSubmission(submitted);
    await expectLater(app.deleteDraft(submitted.id), throwsStateError);
  });
  test(
    'Notification preference persists and account removal clears data',
    () async {
      await app.signOut();
      const profile = UserProfile(name: 'Taylor', email: 'taylor@example.com');
      await app.createAccount(profile, 'strong-password');
      await app.setNotifications(false);
      await app.setThemePreference(AppThemePreference.dark);
      final restored = AppController(repo);
      await restored.initialize();
      expect(restored.notificationsEnabled, isFalse);
      expect(restored.themePreference, AppThemePreference.dark);
      await restored.deleteAccount();
      expect(restored.profile, isNull);
      expect(await repo.loadAccount(profile.email), isNull);
      expect(await repo.loadSession(), isNull);
    },
  );
}
