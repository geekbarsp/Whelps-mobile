import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
import '../../models/models.dart';
import '../../widgets/components.dart';
import '../../widgets/auth_morph_loading.dart';
import 'signup_screen.dart';
import 'welcome_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  String mode = 'welcome';
  final form = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final name = TextEditingController();
  final phone = TextEditingController();
  final region = TextEditingController();
  final city = TextEditingController();
  bool busy = false;
  final sectionKeys = List.generate(8, (_) => GlobalKey());

  Widget section(int index, Widget child) =>
      KeyedSubtree(key: sectionKeys[index], child: child);
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    name.dispose();
    phone.dispose();
    region.dispose();
    city.dispose();
    super.dispose();
  }

  Future<void> run(
    Future<void> Function() action, {
    String? loadingLabel,
  }) async {
    if (busy) return;
    final navigator = Navigator.of(context, rootNavigator: true);
    final messenger = ScaffoldMessenger.of(context);
    final reduced = MediaQuery.disableAnimationsOf(context);
    final rects = <Rect>[];
    for (final key in sectionKeys) {
      final box = key.currentContext?.findRenderObject();
      if (box is RenderBox && box.hasSize) {
        rects.add(box.localToGlobal(Offset.zero) & box.size);
      }
    }
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => busy = true);
    RawDialogRoute<void>? loadingRoute;
    try {
      if (loadingLabel != null) {
        loadingRoute = RawDialogRoute<void>(
          barrierDismissible: false,
          barrierColor: Colors.transparent,
          transitionDuration: Duration.zero,
          pageBuilder: (_, _, _) =>
              AuthMorphLoading(sections: rects, label: loadingLabel),
        );
        unawaited(navigator.push(loadingRoute));
        // Finish the form-to-dot morph before account state changes the page below.
        if (!reduced) {
          await Future<void>.delayed(const Duration(milliseconds: 780));
        }
        await Future.wait([
          action(),
          if (!reduced)
            Future<void>.delayed(const Duration(milliseconds: 1000)),
        ]).timeout(
          const Duration(seconds: 20),
          onTimeout: () => throw StateError(
            'WHELPS took too long to respond. Check the API deployment and try again.',
          ),
        );
      } else {
        await action();
      }
    } catch (e) {
      if (messenger.mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Bad state: ', ''))),
        );
      }
    } finally {
      if (loadingRoute != null && navigator.mounted && loadingRoute.isActive) {
        navigator.removeRoute(loadingRoute);
      }
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _completeSignup(AppController app) async {
    if (!app.usesSecureBackend) {
      await run(
        () => app.createAccount(
          UserProfile(
            name: name.text.trim(),
            email: email.text.trim().toLowerCase(),
          ),
          password.text,
        ),
        loadingLabel: 'Creating your account…',
      );
      return;
    }
    final detailsForm = GlobalKey<FormState>();
    final accepted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          18,
          20,
          20 + MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: Form(
          key: detailsForm,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Where can Whelps reach you?',
                  style: Theme.of(sheetContext).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                const Text(
                  'These details are required for adoption screening and follow-up.',
                ),
                const SizedBox(height: 18),
                FurUTextField(
                  label: 'Philippine mobile number',
                  controller: phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) => RegExp(
                    r'^(?:\+63|0)9\d{9}$',
                  ).hasMatch((value ?? '').replaceAll(RegExp(r'[\s-]'), ''))
                      ? null
                      : 'Use 09XXXXXXXXX or +639XXXXXXXXX.',
                ),
                const SizedBox(height: 12),
                FurUTextField(
                  label: 'Region',
                  controller: region,
                  validator: _required,
                ),
                const SizedBox(height: 12),
                FurUTextField(
                  label: 'City / municipality',
                  controller: city,
                  validator: _required,
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () {
                    if (detailsForm.currentState!.validate()) {
                      Navigator.pop(sheetContext, true);
                    }
                  },
                  child: const Text('Create my account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (accepted != true || !mounted) return;
    await run(
      () => app.createAccount(
        UserProfile(
          name: name.text.trim(),
          email: email.text.trim().toLowerCase(),
          phone: phone.text.trim(),
          region: region.text.trim(),
          city: city.text.trim(),
          location: '${city.text.trim()}, ${region.text.trim()}',
        ),
        password.text,
      ),
      loadingLabel: 'Creating your account…',
    );
  }

  static String? _required(String? value) => (value ?? '').trim().isEmpty
      ? 'This field is required.'
      : null;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Scaffold(
      body: SafeArea(
        child: PageBody(
          child: mode == 'welcome'
              ? WelcomeScreen(
                  onStart: () => setState(() => mode = 'signup'),
                  onSignIn: () => setState(() => mode = 'welcome'),
                  onGuest: app.usesSecureBackend || busy
                      ? null
                      : () => run(app.enterGuest),
                  loginCard: LandingSignInCard(
                    formKey: form,
                    sectionKeys: sectionKeys,
                    email: email,
                    password: password,
                    busy: busy,
                    onForgot: () => setState(() => mode = 'reset'),
                    onRegister: () => setState(() => mode = 'signup'),
                    onSubmit: () {
                      if (busy || !form.currentState!.validate()) return;
                      run(
                        () => app.signIn(email.text, password.text),
                        loadingLabel: 'Signing you in…',
                      );
                    },
                  ),
                )
              : mode == 'signup'
              ? SignupScreen(
                  formKey: form,
                  sectionKeys: sectionKeys,
                  name: name,
                  email: email,
                  password: password,
                  confirmPassword: confirmPassword,
                  busy: busy,
                  onBack: () => setState(() => mode = 'welcome'),
                  onSubmit: () {
                    if (busy || !form.currentState!.validate()) return;
                    _completeSignup(app);
                  },
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: busy
                              ? null
                              : () => setState(() => mode = 'welcome'),
                          tooltip: 'Back to welcome',
                          icon: const Icon(Icons.arrow_back),
                        ),
                        const SizedBox(height: 18),
                        section(0, const Brand()),
                        const SizedBox(height: 32),
                        section(
                          1,
                          Text(
                            mode == 'signup'
                                ? 'Your next chapter\nstarts with FurYou.'
                                : 'Forgot your\npassword?',
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          mode == 'signup'
                              ? 'One account. So many ways to make a difference.'
                              : 'Your next chapter with a little friend starts here.',
                        ),
                        const SizedBox(height: 24),
                        if (mode == 'signup') ...[
                          section(
                            2,
                            FurUTextField(label: 'Full name', controller: name),
                          ),
                        ],
                        section(
                          3,
                          FurUTextField(
                            label: 'Email address',
                            controller: email,
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                        if (mode != 'reset' || !app.usesSecureBackend) ...[
                          section(
                            4,
                            FurUTextField(
                              label: mode == 'reset'
                                  ? 'New password'
                                  : 'Password',
                              controller: password,
                              obscure: true,
                              validator: (v) => (v?.length ?? 0) < 8
                                  ? 'Use at least 8 characters.'
                                  : null,
                            ),
                          ),
                          section(
                            5,
                            FurUTextField(
                              label: 'Confirm password',
                              controller: confirmPassword,
                              obscure: true,
                              validator: (v) => v != password.text
                                  ? 'The passwords do not match.'
                                  : null,
                            ),
                          ),
                        ],
                        section(
                          6,
                          FurUPrimaryButton(
                            label: mode == 'signup'
                                ? 'Create account'
                                : app.usesSecureBackend
                                ? 'Send reset link'
                                : 'Reset password',
                            busy: busy,
                            onPressed: () {
                              if (!form.currentState!.validate()) return;
                              if (mode == 'reset') {
                                run(() async {
                                  await app.resetPassword(
                                    email.text,
                                    password.text,
                                  );
                                  if (!context.mounted) return;
                                  password.clear();
                                  confirmPassword.clear();
                                  setState(() => mode = 'welcome');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        app.usesSecureBackend
                                            ? 'Check your email for a secure password reset link.'
                                            : 'Password updated. Sign in on the landing page.',
                                      ),
                                    ),
                                  );
                                });
                              } else {
                                run(
                                  () => app.createAccount(
                                    UserProfile(
                                      name: name.text.trim(),
                                      email: email.text.trim().toLowerCase(),
                                    ),
                                    password.text,
                                  ),
                                  loadingLabel: 'Creating your account…',
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          app.usesSecureBackend
                              ? 'Your account is protected by FurU secure account services.'
                              : 'Your account is stored on this device.',
                          style: TextStyle(fontSize: 12),
                        ),
                        Center(
                          child: TextButton(
                            onPressed: () => setState(() => mode = 'welcome'),
                            child: const Text('Back to sign in'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
