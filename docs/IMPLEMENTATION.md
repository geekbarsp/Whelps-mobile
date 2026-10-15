# FurU implementation decisions

## Architecture

Flutter, Dart, and Material 3 power a feature-oriented mobile application. `AppController` owns session and presentation state through `ChangeNotifier`. `WhelpsApiRepository` is the production data boundary: it calls the protected WHELPS website API, keeps the mobile session token in platform secure storage, and maps website records into mobile models. `LocalFurURepository` is retained for deterministic automated tests.

## Workflows

The mobile experience adapts the supplied Canva identity and the existing WHELPS website hierarchy for phones. Members use Home, Discover, Activity, and Profile. Administrators receive Dashboard, Pets, Applications, Monitoring, and More.

Adoption follows contact, household, experience and care, reason, optional documents, review, and submission. The server remains authoritative for submitted, under-review, information-requested, approved, rejected, cancelled, and completed applications. Drafts remain on the device until submission. Every decision is represented as human review.

The website currently has no online rehoming-intake or mobile attachment-upload endpoint. Users can prepare rehoming details locally, but final online submission reports that WHELPS support is required. Account deletion and password recovery likewise require future website endpoints.

## Security

The mobile repository contains no PostgreSQL password, Supabase service-role key, or administrator credential. Public registration creates standard WHELPS users. Administrator identity and privileged transitions remain controlled by the website server. Flutter accepts only the public `WHELPS_API_URL`.

## Preview

The installed Mobile Preview extension renders `http://localhost:8080`. The website server patch must be deployed before browser previews can authenticate because browsers require the new CORS preflight handling. Native Android and iOS requests use the same API without exposing database credentials.
