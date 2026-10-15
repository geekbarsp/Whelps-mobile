# FurU Supabase setup

The repository contains the database contract but is not linked to a Supabase project. The migration was created manually because the Supabase CLI is not installed on this workstation.

1. Install the current Supabase CLI and run `supabase login`.
2. Link the intended project: `supabase link --project-ref <project-ref>`.
3. Review and deploy: `supabase db push`.
4. Run both advisors: `supabase db lint --linked` and the Security/Performance advisors in the dashboard.
5. Start Flutter with the public client values only:

   `flutter run --dart-define=SUPABASE_URL=https://<project-ref>.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_...`

Never pass a secret or service-role key to Flutter.

## Assigning the first administrator

Create the user through Supabase Auth, then run this once in the protected SQL editor as the project owner:

```sql
update public.profiles
set role = 'admin', verification_status = 'verified'
where id = '<auth-user-uuid>';
```

There is intentionally no admin email or password in source code and public sign-up always creates a member.
