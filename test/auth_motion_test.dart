import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:furu/core/app_controller.dart';
import 'package:furu/data/repository.dart';
import 'package:furu/main.dart';
import 'package:furu/models/models.dart';
import 'package:furu/widgets/auth_morph_loading.dart';
import 'package:furu/features/auth/welcome_screen.dart';
import 'package:furu/features/auth/login_screen.dart';
import 'package:furu/core/theme.dart';

class SlowLogin extends AppController {
  final gate = Completer<void>();
  int calls = 0;
  SlowLogin(super.repository);
  @override
  Future<void> signIn(String email, String password) async {
    calls++;
    await gate.future;
    await super.signIn(email, password);
  }
}

Future<SlowLogin> prepare(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final app = SlowLogin(
    LocalFurURepository(await SharedPreferences.getInstance()),
  );
  await app.initialize();
  await app.createAccount(
    const UserProfile(name: 'Test Friend', email: 'friend@example.com'),
    'password123',
  );
  await app.signOut();
  await tester.pumpWidget(FurUApp(controller: app));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Sign in'));
  await tester.tap(find.text('Sign in'));
  await tester.pumpAndSettle();
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Email address'),
    'friend@example.com',
  );
  return app;
}

void main() {
  for (final size in [
    const Size(320, 568),
    const Size(360, 640),
    const Size(390, 844),
    const Size(412, 915),
  ]) {
    testWidgets('Landing fits without scrolling at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);
      SharedPreferences.setMockInitialValues({});
      final app = AppController(
        LocalFurURepository(await SharedPreferences.getInstance()),
      );
      await app.initialize();
      await tester.pumpWidget(FurUApp(controller: app));
      await tester.pumpAndSettle();
      final scroll = tester.state<ScrollableState>(
        find.byType(Scrollable).first,
      );
      expect(scroll.position.maxScrollExtent, 0);
      expect(find.text('Sign in').hitTestable(), findsOneWidget);
      expect(
        find.text('New here? Create an account').hitTestable(),
        findsOneWidget,
      );
      expect(find.text('Contact for Rescue').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'Reference login supports large text, password reveal and keyboard',
    (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final email = TextEditingController();
      final password = TextEditingController(text: 'sample-password');
      addTearDown(email.dispose);
      addTearDown(password.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: Scaffold(
            body: LoginScreen(
              formKey: GlobalKey<FormState>(),
              sectionKeys: List.generate(8, (_) => GlobalKey()),
              email: email,
              password: password,
              onBack: () {},
              onSubmit: () {},
              onForgot: () {},
              onRegister: () {},
              busy: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.byTooltip('Show password'));
      await tester.tap(find.byTooltip('Show password'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField).last).obscureText,
        isFalse,
      );
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Sign in'));
      expect(tester.getBottomLeft(find.text('Sign in')).dy, lessThan(500));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'Login morph persists while pending and opens home only after completion',
    (tester) async {
      final app = await prepare(tester);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.ensureVisible(find.text('Sign in'));
      await tester.tap(find.text('Sign in'));
      await tester.pump();
      expect(find.byType(AuthMorphLoading), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 800));
      expect(app.calls, 1);
      await tester.pump(const Duration(seconds: 3));
      expect(find.byType(AuthMorphLoading), findsOneWidget);
      expect(app.profile, isNull);
      app.gate.complete();
      await tester.pumpAndSettle();
      expect(find.byType(AuthMorphLoading), findsNothing);
      expect(find.text('Your forever friend\nis waiting.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Failed login restores entered form and dismisses the loader', (
    tester,
  ) async {
    final app = await prepare(tester);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'wrongpass123',
    );
    await tester.ensureVisible(find.byTooltip('Show password'));
    await tester.tap(find.byTooltip('Show password'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField).last).obscureText,
      isFalse,
    );
    await tester.ensureVisible(find.text('Sign in'));
    await tester.tap(find.text('Sign in'));
    await tester.pump();
    app.gate.complete();
    await tester.pumpAndSettle();
    expect(find.byType(AuthMorphLoading), findsNothing);
    expect(app.profile, isNull);
    expect(
      find.text('That password is incorrect. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('friend@example.com'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Reduced-motion loader stays still', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: AuthMorphLoading(sections: [], label: 'Signing you in…'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(tester.takeException(), isNull);
  });

  for (final scale in [1.0, 2.0]) {
    testWidgets(
      'Landing fills a phone and remains scrollable at text scale $scale',
      (tester) async {
        tester.view.physicalSize = const Size(320, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            theme: buildTheme(),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: Scaffold(
              body: WelcomeScreen(
                onStart: () {},
                onSignIn: () {},
                onGuest: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.text('Contact for Rescue'));
        expect(find.text('Contact for Rescue').hitTestable(), findsOneWidget);
        expect(
          tester.getBottomLeft(find.text('Contact for Rescue')).dy,
          lessThanOrEqualTo(800),
        );
        if (scale > 1) {
          expect(
            tester
                .state<ScrollableState>(find.byType(Scrollable).first)
                .position
                .maxScrollExtent,
            greaterThan(0),
          );
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
}
