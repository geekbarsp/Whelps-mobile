class BackendConfig {
  static const whelpsApiUrl = String.fromEnvironment(
    'WHELPS_API_URL',
    defaultValue: 'https://whelps-woad.vercel.app',
  );

  static bool get useWhelpsApi =>
      !const bool.fromEnvironment('FLUTTER_TEST') &&
      whelpsApiUrl.startsWith('http');
}
