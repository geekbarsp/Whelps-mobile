import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/app_controller.dart';
import 'core/backend_config.dart';
import 'core/theme.dart';
import 'data/repository.dart';
import 'data/whelps_api_repository.dart';
import 'features/auth/auth_screen.dart';
import 'features/auth/password_recovery_screen.dart';
import 'features/admin/admin_shell.dart';
import 'features/home/shell.dart';
import 'widgets/components.dart';
import 'widgets/loading_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final FurURepository repository;
  final runningWidgetTests = WidgetsBinding.instance.runtimeType
      .toString()
      .contains('TestWidgetsFlutterBinding');
  if (BackendConfig.useWhelpsApi && !runningWidgetTests) {
    repository = WhelpsApiRepository(
      baseUrl: BackendConfig.whelpsApiUrl,
      preferences: preferences,
    );
  } else {
    repository = LocalFurURepository(preferences);
  }
  final controller = AppController(repository);
  runApp(FurUApp(controller: controller));
  // Mount the loading screen before fast local reads can finish.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(controller.initialize());
  });
}

class FurUApp extends StatefulWidget {
  final AppController controller;
  const FurUApp({super.key, required this.controller});
  @override
  State<FurUApp> createState() => _FurUAppState();
}

class _FurUAppState extends State<FurUApp> {
  AppController get controller => widget.controller;
  Timer? introTimer;
  late bool showingIntro;

  @override
  void initState() {
    super.initState();
    showingIntro = controller.loading;
    if (showingIntro) {
      introTimer = Timer(const Duration(milliseconds: 2100), () {
        if (mounted) setState(() => showingIntro = false);
      });
    }
  }

  @override
  void dispose() {
    introTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppScope(
    controller: controller,
    child: ListenableBuilder(
      listenable: controller,
      builder: (context, _) => MaterialApp(
        title: 'FurYou · A forever home',
        debugShowCheckedModeBanner: false,
        theme:
            controller.themePreference == AppThemePreference.light ||
                controller.themePreference == AppThemePreference.system
            ? buildLightTheme()
            : buildTheme(),
        darkTheme: buildDarkTheme(),
        themeMode: switch (controller.themePreference) {
          AppThemePreference.defaultTheme => ThemeMode.light,
          AppThemePreference.dark => ThemeMode.dark,
          AppThemePreference.light => ThemeMode.light,
          AppThemePreference.system => ThemeMode.system,
        },
        home: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            if (controller.loading ||
                (showingIntro &&
                    controller.error == null &&
                    !MediaQuery.disableAnimationsOf(context))) {
              return FurULoadingScreen(progress: controller.loadingProgress);
            }
            if (controller.error != null) {
              return Scaffold(
                body: Center(
                  child: EmptyState(
                    title: 'Let’s try that again',
                    message: controller.error!,
                    action: FilledButton(
                      onPressed: controller.initialize,
                      child: const Text('Retry'),
                    ),
                  ),
                ),
              );
            }
            if (controller.passwordRecovery) {
              return const PasswordRecoveryScreen();
            }
            return controller.profile == null
                ? const AuthScreen()
                : controller.isAdmin
                ? const AdminShell()
                : const AppShell();
          },
        ),
      ),
    ),
  );
}
