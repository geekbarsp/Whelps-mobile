import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:furu/core/app_controller.dart';
import 'package:furu/core/theme.dart';
import 'package:furu/data/repository.dart';
import 'package:furu/features/applications/workflow_screen.dart';
import 'package:furu/features/admin/admin_shell.dart';
import 'package:furu/features/applications/workflow_fields.dart';
import 'package:furu/features/pets/pet_detail.dart';
import 'package:furu/main.dart';
import 'package:furu/models/models.dart';

Future<AppController> setup({bool signedIn = true}) async {
  SharedPreferences.setMockInitialValues({});
  final app = AppController(
    LocalFurURepository(await SharedPreferences.getInstance()),
  );
  await app.initialize();
  if (signedIn) await app.enterGuest();
  return app;
}

void main() {
  testWidgets('Administrator account opens the mobile admin workspace', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final repository = LocalFurURepository(
      await SharedPreferences.getInstance(),
    );
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
    final app = AppController(repository);
    await app.initialize();
    app.adminWorkspace = {
      'stats': {
        'adopters': 12,
        'available_pets': 4,
        'applications': 1,
        'pending_applications': 7,
        'completed_adoptions': 4,
        'unread_messages': 2,
        'average_rating': 4.7,
        'feedback_submissions': 9,
        'monitoring_updates': 3,
      },
      'pets': [
        {
          'id': 'pet-1',
          'name': 'Luna',
          'breed': 'Persian',
          'listing_status': 'pending',
          'health': ['Vaccinated'],
        },
      ],
      'applications': [
        {
          'id': 'application-1',
          'applicant_name': 'Angel Garcia',
          'applicant_email': 'angel@example.com',
          'pet_name': 'Luna',
          'status': 'submitted',
        },
      ],
      'adoption_records': <Map<String, dynamic>>[],
      'monitoring_updates': <Map<String, dynamic>>[],
      'analytics': {
        'monthly_applications': [
          {'month': '2026-08-01', 'total': 3},
          {'month': '2026-09-01', 'total': 5},
          {'month': '2026-10-01', 'total': 7},
        ],
        'monthly_adoptions': [
          {'month': '2026-08-01', 'total': 1},
          {'month': '2026-09-01', 'total': 2},
          {'month': '2026-10-01', 'total': 4},
        ],
        'completion_rate': 57.1,
        'report_resolution_rate': 80,
      },
    };
    await tester.pumpWidget(FurUApp(controller: app));
    await tester.pumpAndSettle();
    expect(find.byType(AdminShell), findsOneWidget);
    expect(find.text('Administration Panel'), findsOneWidget);
    expect(find.text('Welcome back,'), findsOneWidget);
    for (final width in [320.0, 360.0, 390.0, 412.0, 768.0]) {
      tester.view.physicalSize = Size(width, 850);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    tester.view.physicalSize = const Size(320, 700);
    app.themePreference = AppThemePreference.dark;
    app.notifyListeners();
    tester.platformDispatcher.textScaleFactorTestValue = 1.7;
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    tester.platformDispatcher.clearTextScaleFactorTestValue();
    app.themePreference = AppThemePreference.defaultTheme;
    app.notifyListeners();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pets').last);
    await tester.pumpAndSettle();
    expect(find.text('Pets & Health'), findsOneWidget);
    expect(find.text('Search pet name, breed, or status...'), findsOneWidget);
    for (final width in [320.0, 360.0, 390.0, 412.0, 768.0]) {
      tester.view.physicalSize = Size(width, 850);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Admin pets at $width');
    }
    tester.view.physicalSize = const Size(320, 700);
    tester.platformDispatcher.textScaleFactorTestValue = 1.7;
    app.themePreference = AppThemePreference.dark;
    app.notifyListeners();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    tester.platformDispatcher.clearTextScaleFactorTestValue();
    app.themePreference = AppThemePreference.defaultTheme;
    app.notifyListeners();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Filter pets'));
    await tester.pumpAndSettle();
    expect(find.text('Apply filters'), findsOneWidget);
    await tester.tap(find.text('Apply filters'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'unmatched-pet');
    await tester.pumpAndSettle();
    expect(find.text('No pet records in this view'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '');
    await tester.tap(find.text('Add Pet'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Continue'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Enter Pet name.'), findsOneWidget);
    for (final entry in {
      'name': 'Mochi',
      'breed': 'Mixed breed',
      'age': '2 years',
      'image': 'https://example.com/mochi.jpg',
      'description': 'A gentle companion',
    }.entries) {
      await tester.ensureVisible(find.byKey(ValueKey(entry.key)));
      await tester.enterText(find.byKey(ValueKey(entry.key)), entry.value);
      await tester.pumpAndSettle();
    }
    await tester.ensureVisible(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('2. Health & review'), findsOneWidget);
    await tester.ensureVisible(find.text('Back to pet details'));
    await tester.tap(find.text('Back to pet details'));
    await tester.pumpAndSettle();
    expect(find.text('Mochi'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Applications').last);
    await tester.pumpAndSettle();
    expect(
      find.text('Review and manage adoption applications.'),
      findsOneWidget,
    );
    for (final width in [320.0, 360.0, 390.0, 412.0, 768.0]) {
      tester.view.physicalSize = Size(width, 850);
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Admin applications at $width',
      );
    }
    tester.view.physicalSize = const Size(320, 700);
    tester.platformDispatcher.textScaleFactorTestValue = 1.7;
    app.themePreference = AppThemePreference.dark;
    app.notifyListeners();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    tester.platformDispatcher.clearTextScaleFactorTestValue();
    app.themePreference = AppThemePreference.defaultTheme;
    app.notifyListeners();
    await tester.pumpAndSettle();
    String? copiedLink;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copiedLink = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await tester.tap(find.text('New Application'));
    await tester.pumpAndSettle();
    expect(find.text('Copy Whelps website link'), findsOneWidget);
    await tester.runAsync(() async {
      await tester.tap(find.text('Copy Whelps website link'));
    });
    await tester.pumpAndSettle();
    expect(copiedLink, startsWith('https://'));
    expect(find.text('Start a new application'), findsNothing);
    await tester.ensureVisible(find.byTooltip('Filter applications'));
    await tester.tap(find.byTooltip('Filter applications'));
    await tester.pumpAndSettle();
    expect(find.text('Sort by'), findsOneWidget);
    await tester.tap(find.text('Apply filters'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField).first,
      'unmatched-application',
    );
    await tester.pumpAndSettle();
    expect(find.text('No matching applications'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Angel');
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Angel Garcia'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Angel Garcia'));
    await tester.pumpAndSettle();
    expect(find.text('Adoption screening'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Monitoring').last);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Monitoring'), findsOneWidget);
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('System evaluation'));
    await tester.pumpAndSettle();
    expect(find.text('Platform outcomes'), findsOneWidget);
    expect(find.text('Adoption activity'), findsOneWidget);
    expect(find.text('Applications'), findsOneWidget);
    expect(find.text('Completed adoptions'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  for (final width in [320.0, 360.0, 390.0, 412.0, 768.0]) {
    testWidgets('Main navigation fits ${width.toInt()}px', (tester) async {
      tester.view.physicalSize = Size(width, 850);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final app = await setup();
      await tester.pumpWidget(FurUApp(controller: app));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      for (final label in ['Discover', 'Activity', 'Profile', 'Home']) {
        await tester.tap(find.text(label).last);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$label at $width');
      }
      await tester.tap(find.text('Discover').last);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'no-such-pet');
      await tester.pumpAndSettle();
      expect(find.text('No paws found just yet'), findsOneWidget);
      await tester.tap(find.byTooltip('Filter pets'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('Welcome and signup are usable on a narrow phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final app = await setup(signedIn: false);
    await tester.pumpWidget(FurUApp(controller: app));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Get started'));
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(find.text('Account type'), findsNothing);
    expect(find.text('Full name'), findsOneWidget);
    await tester.ensureVisible(find.text('Back to sign in'));
    await tester.tap(find.text('Back to sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back!'), findsOneWidget);
    expect(find.text('Full name'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Account creation opens the full app', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final app = await setup(signedIn: false);
    await tester.pumpWidget(FurUApp(controller: app));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Full name'),
      'Jamie Rivera',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email address'),
      'jamie@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'strong-password',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirm password'),
      'strong-password',
    );
    await tester.ensureVisible(find.text('Create account'));
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(app.profile!.name, 'Jamie Rivera');
    expect(find.text('Your forever friend\nis waiting.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Notification center opens a saved draft', (tester) async {
    final app = await setup();
    await app.saveSubmission(app.newDraft(SubmissionKind.rehome));
    await tester.pumpWidget(FurUApp(controller: app));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Notifications'));
    await tester.pumpAndSettle();
    expect(find.text('Your draft is waiting'), findsOneWidget);
    await tester.tap(find.text('Your draft is waiting'));
    await tester.pumpAndSettle();
    expect(find.text('Meet your pet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Home dashboard scrolls through the full mobile story', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final app = await setup();
    await tester.pumpWidget(FurUApp(controller: app));
    await tester.pumpAndSettle();

    expect(find.text('Your forever friend\nis waiting.'), findsOneWidget);
    for (var i = 0; i < 4; i++) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -550));
      await tester.pumpAndSettle();
    }
    expect(find.text('Contact for Rescue'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Discover pet grid scrolls naturally on mobile', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final app = await setup();
    await tester.pumpWidget(FurUApp(controller: app));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discover').last);
    await tester.pumpAndSettle();

    final before = tester.getTopLeft(find.text('Milo').last).dy;
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -500));
    await tester.pumpAndSettle();
    final after = tester.getTopLeft(find.text('Milo').last).dy;
    expect(after, lessThan(before));
    expect(tester.takeException(), isNull);
  });
  testWidgets('Detail and forms support large text and keyboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final app = await setup();
    Widget wrap(Widget child) => AppScope(
      controller: app,
      child: MaterialApp(
        theme: buildTheme(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.6)),
          child: child!,
        ),
        home: child,
      ),
    );
    await tester.pumpWidget(wrap(PetDetail(pet: app.pets.first)));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(
      wrap(
        WorkflowScreen(
          submission: app.newDraft(
            SubmissionKind.adoption,
            pet: app.pets.first,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid phone number.'), findsNothing);
    expect(find.text('Please enter phone number.'), findsOneWidget);
    expect(app.submissions, isEmpty);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    expect(tester.getBottomLeft(find.text('Continue')).dy, lessThan(500));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('Profile identity card fits a long account name', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final app = await setup();
    await app.updateProfile(
      const UserProfile(
        name: 'John Hendrix Dela Cruz',
        email: 'sample@example.com',
        location: 'Metro Manila',
      ),
    );
    await tester.pumpWidget(FurUApp(controller: app));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  testWidgets('Profile settings changes and persists the app theme', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final app = await setup();
    await tester.pumpWidget(FurUApp(controller: app));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const PageStorageKey('profile-scroll')),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Default'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(app.themePreference, AppThemePreference.dark);
    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();
    expect(app.themePreference, AppThemePreference.light);
    await tester.tap(find.text('System'));
    await tester.pumpAndSettle();
    expect(app.themePreference, AppThemePreference.system);
    await tester.tap(find.text('Default'));
    await tester.pumpAndSettle();
    expect(app.themePreference, AppThemePreference.defaultTheme);
    await tester.drag(
      find.byKey(const PageStorageKey('settings-scroll')),
      const Offset(0, -900),
    );
    await tester.pumpAndSettle();
    expect(find.text('Remove account from this device'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Draft saves and resumes entered contact details', (
    tester,
  ) async {
    final app = await setup();
    final draft = app.newDraft(SubmissionKind.adoption, pet: app.pets.first);
    await tester.pumpWidget(
      AppScope(
        controller: app,
        child: MaterialApp(
          theme: buildTheme(),
          home: WorkflowScreen(submission: draft),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final phone = find.widgetWithText(TextFormField, 'Phone number');
    await tester.enterText(phone, '09171234567');
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();
    expect(app.submissions.single.answers['Phone number'], '09171234567');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('A place to call home'), findsOneWidget);
    expect(app.submissions.single.step, 1);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('Final review submits once and shows human review', (
    tester,
  ) async {
    final app = await setup();
    final draft = app.newDraft(SubmissionKind.adoption, pet: app.pets.first);
    final answers = {...draft.answers};
    for (final step in workflowSteps(SubmissionKind.adoption)) {
      for (final field in step.fields) {
        answers[field.label] = field.options?.first ?? 'Sample answer';
      }
    }
    answers['Email'] = 'alex@example.com';
    answers['Phone number'] = '09171234567';
    final review = draft.copyWith(answers: answers, step: 5);
    await tester.pumpWidget(
      AppScope(
        controller: app,
        child: MaterialApp(
          theme: buildTheme(),
          home: WorkflowScreen(submission: review),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byType(CheckboxListTile),
      450,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byType(CheckboxListTile));
    await tester.tap(find.text('Submit for review'));
    await tester.pumpAndSettle();
    expect(app.submissions.single.status, ApplicationStatus.submitted);
    expect(find.text('A hopeful new beginning.'), findsOneWidget);
    expect(find.text('Human review'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
