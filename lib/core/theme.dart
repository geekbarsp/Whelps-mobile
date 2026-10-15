import 'package:flutter/material.dart';

class FurUColors {
  // Existing semantic tokens retain their names for feature compatibility.
  static const forest = Color(0xFF82421D);
  static const cream = Color(0xFFFBF6ED);
  static const peach = Color(0xFFFFDBB4);
  static const sage = Color(0xFFF0E6D7);
  static const ink = Color(0xFF30251E);
  static const muted = Color(0xFF77685D);
  static const orange = Color(0xFFFFA039);
  static const cocoa = Color(0xFF3C2D24);

  static Color card(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? Theme.of(context).colorScheme.surface
      : Colors.white;
}

ThemeData buildTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: FurUColors.forest,
    primary: FurUColors.forest,
    surface: FurUColors.cream,
  ),
  scaffoldBackgroundColor: FurUColors.cream,
  splashFactory: InkSparkle.splashFactory,
  fontFamily: 'NunitoSans',
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontFamily: 'Fraunces',
      fontSize: 34,
      fontWeight: FontWeight.w800,
      height: 1.15,
      letterSpacing: -1.2,
      color: FurUColors.ink,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Fraunces',
      fontSize: 28,
      fontWeight: FontWeight.w800,
      height: 1.2,
      letterSpacing: -.7,
      color: FurUColors.ink,
    ),
    titleLarge: TextStyle(
      fontFamily: 'Fraunces',
      fontSize: 22,
      fontWeight: FontWeight.w800,
      color: FurUColors.ink,
    ),
    titleMedium: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w700,
      color: FurUColors.ink,
    ),
    bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: FurUColors.ink),
    bodyMedium: TextStyle(fontSize: 14, height: 1.45, color: FurUColors.muted),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: FurUColors.cream,
    foregroundColor: FurUColors.ink,
    centerTitle: false,
    scrolledUnderElevation: 0,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFDFE4DD)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFDFE4DD)),
    ),
    errorMaxLines: 3,
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: FurUColors.orange,
      foregroundColor: FurUColors.ink,
      minimumSize: const Size(48, 54),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: const TextStyle(
        fontFamily: 'NunitoSans',
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(48, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: Colors.white,
    indicatorColor: FurUColors.sage,
    height: 76,
    labelTextStyle: WidgetStateProperty.all(
      const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
    ),
  ),
  chipTheme: ChipThemeData(
    side: BorderSide.none,
    backgroundColor: Colors.white,
    selectedColor: FurUColors.sage,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  dividerTheme: const DividerThemeData(color: Color(0xFFE2E6DE)),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: FurUColors.ink,
    contentTextStyle: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  ),
);

ThemeData buildLightTheme() {
  final base = buildTheme();
  const background = Color(0xFFFFFCF8);
  final scheme = ColorScheme.fromSeed(
    seedColor: FurUColors.forest,
    brightness: Brightness.light,
    surface: Colors.white,
  );
  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: background,
    appBarTheme: base.appBarTheme.copyWith(backgroundColor: background),
    navigationBarTheme: base.navigationBarTheme.copyWith(
      backgroundColor: Colors.white,
    ),
  );
}

ThemeData buildDarkTheme() {
  const background = Color(0xFF130D0A);
  const surface = Color(0xFF241814);
  const raisedSurface = Color(0xFF2D201A);
  const text = Color(0xFFFFF5EC);
  const muted = Color(0xFFCDB9AD);
  const accent = Color(0xFFFF982F);
  const outline = Color(0xFF594137);
  final base = buildTheme();
  const scheme = ColorScheme.dark(
    primary: accent,
    onPrimary: Color(0xFF2B170C),
    primaryContainer: Color(0xFF693615),
    onPrimaryContainer: Color(0xFFFFE0C2),
    secondary: Color(0xFFFFB775),
    onSecondary: Color(0xFF321B0E),
    secondaryContainer: Color(0xFF52301F),
    onSecondaryContainer: Color(0xFFFFDDC1),
    surface: surface,
    onSurface: text,
    surfaceContainerLowest: background,
    surfaceContainerLow: Color(0xFF1B120F),
    surfaceContainer: surface,
    surfaceContainerHigh: raisedSurface,
    surfaceContainerHighest: Color(0xFF382820),
    onSurfaceVariant: muted,
    outline: outline,
    outlineVariant: Color(0xFF3D2B24),
    error: Color(0xFFFF8A80),
    onError: Color(0xFF3A0805),
  );
  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: background,
    canvasColor: background,
    cardColor: surface,
    textTheme: base.textTheme.apply(bodyColor: muted, displayColor: text),
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: text,
      centerTitle: false,
      scrolledUnderElevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF1D1411),
      indicatorColor: const Color(0xFF6B381A),
      height: 76,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected) ? accent : muted,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: states.contains(WidgetState.selected) ? accent : muted,
        ),
      ),
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      fillColor: raisedSurface,
      labelStyle: const TextStyle(color: muted),
      hintStyle: const TextStyle(color: Color(0xFFA9968B)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: accent, width: 1.5),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: surface,
      selectedColor: const Color(0xFF75411F),
      labelStyle: const TextStyle(color: text),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFF49372E)),
    dialogTheme: const DialogThemeData(backgroundColor: surface),
    bottomSheetTheme: const BottomSheetThemeData(backgroundColor: surface),
    cardTheme: const CardThemeData(color: surface, surfaceTintColor: surface),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? const Color(0xFF3A1D0D)
            : muted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? accent
            : const Color(0xFF4A3830),
      ),
    ),
    iconTheme: const IconThemeData(color: muted),
  );
}
