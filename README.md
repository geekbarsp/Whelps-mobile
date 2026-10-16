# FurU

A mobile-first Flutter / Dart adoption, rescue-contact, and administration application with Material 3, connected through the WHELPS server API to its existing Supabase PostgreSQL database.

## Run

Flutter 3.47.5 / Dart 3.13.4 was installed at `C:/Users/Admin/development/flutter`. VS Code workspace settings point to that SDK. Add its `bin` directory to PATH, or invoke the full path:

```powershell
& 'C:/Users/Admin/development/flutter/bin/flutter.bat' pub get
& 'C:/Users/Admin/development/flutter/bin/flutter.bat' run -d chrome
```

The app defaults to `https://whelps-woad.vercel.app` and uses the same live WHELPS database whenever a connection is available. It keeps the last loaded pets, signed-in account, drafts, favorites, and settings on the device so the main experience can still open offline. Sign-in, submissions, admin changes, and other server updates require a connection. To use another deployment, copy `config/whelps.example.json` to `config/whelps.json`, change `WHELPS_API_URL`, and launch with **FurU Online** in VS Code.

## Mobile Preview extension

The installed **Mobile Preview - Phone & Tablet Simulator** (`lirobi.phone-preview` 3.1.10) was activated and used to render this app in its iPhone 13 Pro frame. Evidence: [actual extension screenshot](docs/validation/vscode-mobile-preview.png).

- Run VS Code task **FurU: mobile preview server**.
- Run command **Mobile Preview: Show**. The workspace URL is `http://localhost:8080`.
- The compiled release can also be served with `node tools/serve-preview.cjs` after `flutter build web`. Do not run both servers on port 8080 at once.
- Phone/tablet viewport tests cover 320, 360, 390, 412, and 768 logical pixels. Native camera/file permissions still need device testing.

## Features

- Welcome, online sign-in/sign-up, secure session restoration, and server-managed administrator access.
- Home, searchable discovery, species/breed/age/sex/size/location filters, favorites, and photo-led pet details.
- Six-step adoption and rehoming flows with validation, debounced draft saving, resume, image/document selection, final review, and agreement.
- Activity history, status badges, next-step explanations, and cancellation. Human review is represented without automatic approval or publication.
- Server-authorized mobile administration: operational dashboard, pet and health verification, adoption screening, post-adoption monitoring, adopter messages, system evaluation with an interactive line graph, user controls, organization verification, reports, records, announcements, audit logs, settings, and administrator profile.
- A single, simple account flow, profile editing, document inventory, local verification requests, and settings.
- Working sign-in, password reset/change, notification preferences, account removal, and migration of earlier local accounts.
- Contact for Rescue with official public animal-welfare resources and a copyable assistance message.
- Notification center, draft deletion, application cancellation, favorites, and copyable pet details.
- Canva-referenced FurYou × WHELPS identity: original logo assets, warm ivory/orange/cocoa palette, Fraunces headings and Nunito Sans body text, responsive cards, sticky form actions, and scalable text.
- Mobile photo reveal, staggered entrances, press feedback, animated favorites and navigation, with reduced-motion support. Our Story and an adoption journey adapt the desktop reference for phones.
- Reference-based landing page with a dog-and-cat hero, Adopt/Rehome/Support actions, inline sign-in, and guest/rescue access. Signup and sign-in morph form sections into an orbiting dot ring, remaining visible while the request is pending and restoring the form on failure. Social providers shown in the reference are omitted until connected.

## Structure and backend

`lib/features` contains screens. `lib/widgets` holds reusable UI components. `AppController` uses Flutter ChangeNotifier through AppScope. `WhelpsApiRepository` translates the mobile models to the website API while keeping database credentials and administrator authorization on the server.

The mobile client does not connect directly to PostgreSQL and does not contain a Supabase service-role key. It stores the WHELPS mobile session token in platform secure storage. Favorites, display settings, and unfinished drafts remain on-device; published pets, profiles, submitted adoption applications, reviews, conversations, and monitoring records use the website database.

There is no seeded or hardcoded administrator in the mobile client. Public registration creates standard WHELPS users, while administrator identity and authorization remain controlled by the website server environment.

The current website API accepts adoption applications but does not yet expose online rehoming intake, attachment upload, account deletion, or password-recovery endpoints. The app reports those limits directly instead of pretending the action succeeded.

## Source limitations

The desktop Canva reference was inspected in the user's open debug Chrome on September 21, 2026. Original FurYou and WHELPS logos and the cat photograph are bundled locally. The mobile theme and adoption-journey content now follow that reference. See [reference adaptation](docs/CANVA-REFERENCE.md). Sample pet records, donation totals, testimonials, and live shelter integrations are not verified production data.

## Validation

```powershell
flutter pub get
flutter analyze
flutter test
flutter build web --release
```

Static analysis and the release web build passed. Automated tests cover local data restoration/isolation, file reselection, review submission, cancellation/new drafts, form validation, navigation, filtering empty states, responsive widths, and large text. Browser captures are in `docs/validation`.

Native Android builds require an Android SDK/JDK (not installed here). iOS builds require macOS, Xcode, and signing. Platform folders are generated; native builds are not claimed as verified.

## Assets

Pet photos are illustrative sample listings. Font license and image sources: [assets/README.md](assets/README.md). The paw launcher icon is generated from code in `tools/generate-icons.cjs`; it is provisional branding.
