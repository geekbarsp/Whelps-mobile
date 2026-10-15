# Validation

- Flutter 3.47.5; Dart 3.13.4; Windows host.
- `flutter pub get`: completed; dependencies locked in pubspec.lock.
- `flutter analyze`: no issues.
- `flutter test`: 45 passing controller/widget tests.
- `flutter build web --release`: successful, including the Wasm compatibility dry run.
- Responsive widget checks: 320, 360, 390, 412, 768 logical pixels; navigation, rescue resources, discovery empty state and filter sheet.
- Large-text check: 1.6× at 320 pixels; form action remains above a 300-pixel keyboard inset.
- Workflow checks: per-step validation, saved/resumed contact details, review agreement and submission, duplicate-adoption resume, cancellation/new draft, draft deletion, attachment reselection, account data isolation, account creation, password checking/reset, persistent notification preferences, notification routing, and local account removal.
- A test caught timestamp-ID collisions when creating drafts rapidly. IDs now use 128 random bits.
- Browser inspection: bundled photos/fonts, welcome, home, discovery, pet details and adoption form; actual keyboard entry, draft save/exit, rehoming dropdowns, image selection and document selection through the browser picker. No JavaScript runtime errors. Screenshots in `validation/`.
- Actual installed `lirobi.phone-preview` 3.1.10 activated through `mobile-preview.show` in an isolated VS Code extension host, displaying http://localhost:8080 in the iPhone 13 Pro frame. Screenshot: `validation/vscode-mobile-preview.png`; activation evidence: `validation/extension-result.json`.

## Limits

Native Android/iOS builds and physical-device picker/permission behavior were not tested. Android SDK is missing, and the host is Windows. iOS requires macOS/Xcode/signing. The WHELPS server patch must be deployed before mobile Bearer sessions and browser CORS work against the live site. Online rehoming intake, private attachment upload, account deletion, and password recovery still require website endpoints.
