# FurU implementation decisions

## Evidence and limitations
- The supplied workspace was empty on 19 September 2026: no existing code, requirements, documents, or assets.
- Initial Canva access failed. On September 21, 2026, the user's open Chrome session provided access to `DAHU85AwgH0`. The mobile visual identity now uses its original logos and photograph, with ivory/orange/cocoa styling. See [reference adaptation](CANVA-REFERENCE.md).
- Existing functional workflows derive from the original brief and supplied references. The administrator workspace adapts the Whelps website hierarchy for phones: dashboard, pet and health review, application screening, monitoring updates, approved-adopter conversations, and system evaluation. The client actions are implemented against audited backend RPCs; they become durable after the included migration is deployed.

## Architecture
Flutter / Dart / Material 3. Feature folders contain screens. AppController (ChangeNotifier) owns session and presentation state. FurURepository is the backend boundary. SupabaseFurURepository implements Auth, PostgreSQL, Storage, admin RPCs, session restoration, and password-reset delivery when public project values are supplied. LocalFurURepository remains a member-only offline development fallback.

## Provisional workflows
Users share one simple account flow and can adopt or rehome. The earlier Individual/Organization selection was removed to keep onboarding short. Account verification is unverified/pending human review. No instant approval.

The app never seeds an administrator. A server-stored `profiles.role` value routes verified administrators into a five-tab workspace. Privileged changes call `admin_action`; it verifies the current user, validates transitions, updates records transactionally, and appends an audit entry. Application screening cannot override the pet owner's final adoption decision.
Adoption: contact → household → experience/care → reason → optional documents → review/consent → submitted.
Rehome: pet → photos → health → personality/reason → contact → review/consent → submitted. A submission does not publish an animal.
Draft, submitted, under review, approved, rejected and cancelled are provisional states from the brief. Only draft → submitted and submitted/under review → cancelled are user actions. Staff decisions require a future authenticated backend.
Supporting documents, ID and financial proof are optional because no source establishes a mandatory requirement. Avoid sensitive identity or income documents until private storage is connected. Attachments are kept in memory; names persist with drafts, and files must be reselected after restart before submission. Pet photos are bundled assets.
Messages are omitted because no available source establishes a messaging workflow. Bottom navigation: Home, Discover, Activity, Profile.

## Supabase backend
The migration in `supabase/migrations` defines profiles, pets, applications, rehome submissions, organization verification, reports, notifications, adoption records, monitoring updates, conversations, messages, system feedback, account restrictions, and append-only audit logs. Every exposed table has RLS. Private documents use owner-scoped buckets; administrators read them only through server authorization. The Flutter app accepts only a project URL and publishable key. See `supabase/README.md` for deployment and first-admin assignment.

## Preview
The installed lirobi.phone-preview extension renders a web URL. Workspace settings target http://localhost:8080; run the Flutter web preview task, then Mobile Preview: Show. This is responsive UI preview, not a native-device test.
