class BackendConfig {
  static const whelpsApiUrl = String.fromEnvironment(
    'WHELPS_API_URL',
    defaultValue: 'https://whelps-woad.vercel.app',
  );

  static bool get useWhelpsApi =>
      !const bool.fromEnvironment('FLUTTER_TEST') &&
      whelpsApiUrl.startsWith('http');

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static bool get isConfigured =>
      supabaseUrl.startsWith('https://') &&
      supabasePublishableKey.startsWith('sb_publishable_');

  static const passwordResetRedirect = String.fromEnvironment(
    'PASSWORD_RESET_REDIRECT',
    defaultValue: 'io.furu.app://login-callback/',
  );
}
