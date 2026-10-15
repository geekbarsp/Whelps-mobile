-- FurU administration schema. Apply to a linked Supabase project after review.
create schema if not exists private;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  full_name text not null default '',
  phone text not null default '',
  location text not null default '',
  organization_name text not null default '',
  account_type text not null default 'individual'
    check (account_type in ('individual','organization')),
  role text not null default 'adopter'
    check (role in ('adopter','individual_rehomer','organization','admin')),
  verification_status text not null default 'not_requested'
    check (verification_status in ('not_requested','pending','more_information','verified','rejected','revoked')),
  account_status text not null default 'active'
    check (account_status in ('active','suspended','banned')),
  notifications_enabled boolean not null default true,
  theme_preference text not null default 'defaultTheme',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.pets (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id) on delete restrict,
  name text not null,
  species text not null,
  breed text not null default '',
  sex text not null default 'Unknown',
  size text not null default 'Unknown',
  location text not null default '',
  age_months integer not null default 0 check (age_months >= 0),
  description text not null default '',
  traits text[] not null default '{}',
  health text[] not null default '{}',
  photo_url text,
  listing_status text not null default 'pending'
    check (listing_status in ('pending','corrections_requested','approved','active','rejected','adopted','removed')),
  review_note text not null default '',
  reviewed_by uuid references public.profiles(id),
  reviewed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.adoption_applications (
  id uuid primary key default gen_random_uuid(),
  pet_id uuid not null references public.pets(id) on delete restrict,
  applicant_id uuid not null references public.profiles(id) on delete restrict,
  answers jsonb not null default '{}',
  document_names text[] not null default '{}',
  status text not null default 'draft'
    check (status in ('draft','submitted','under_review','more_information','screened','owner_review','approved','rejected','handover','completed','cancelled','flagged','disputed')),
  draft_step integer not null default 0 check (draft_step >= 0),
  review_note text not null default '',
  reviewed_by uuid references public.profiles(id),
  reviewed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.rehome_submissions (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id) on delete restrict,
  pet_id uuid references public.pets(id) on delete set null,
  answers jsonb not null default '{}',
  document_names text[] not null default '{}',
  status text not null default 'draft'
    check (status in ('draft','submitted','under_review','more_information','approved','rejected','cancelled')),
  draft_step integer not null default 0 check (draft_step >= 0),
  review_note text not null default '',
  reviewed_by uuid references public.profiles(id),
  reviewed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.favorites (
  user_id uuid not null references public.profiles(id) on delete cascade,
  pet_id uuid not null references public.pets(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, pet_id)
);

create table if not exists public.organization_verifications (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.profiles(id) on delete restrict,
  registration_number text not null default '',
  document_paths text[] not null default '{}',
  status text not null default 'pending'
    check (status in ('pending','under_review','more_information','verified','rejected','revoked')),
  decision_reason text not null default '',
  reviewed_by uuid references public.profiles(id),
  reviewed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references public.profiles(id) on delete restrict,
  reported_user_id uuid references public.profiles(id) on delete set null,
  pet_id uuid references public.pets(id) on delete set null,
  category text not null check (category in ('fake_listing','suspicious_adoption','fraudulent_organization','harassment','inappropriate_content','animal_welfare','other')),
  details text not null,
  evidence_paths text[] not null default '{}',
  status text not null default 'new' check (status in ('new','under_review','resolved','dismissed')),
  assigned_admin_id uuid references public.profiles(id),
  resolution text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  recipient_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  body text not null,
  kind text not null default 'system',
  data jsonb not null default '{}',
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.adoption_records (
  id uuid primary key default gen_random_uuid(),
  application_id uuid not null unique references public.adoption_applications(id) on delete restrict,
  pet_id uuid not null unique references public.pets(id) on delete restrict,
  adopter_id uuid not null references public.profiles(id) on delete restrict,
  rehomer_id uuid not null references public.profiles(id) on delete restrict,
  approved_at timestamptz not null,
  adopter_handover_confirmed_at timestamptz,
  rehomer_handover_confirmed_at timestamptz,
  completed_at timestamptz,
  status text not null default 'handover_pending'
    check (status in ('handover_pending','completed','disputed','cancelled')),
  created_at timestamptz not null default now()
);

create table if not exists public.monitoring_updates (
  id uuid primary key default gen_random_uuid(),
  adoption_record_id uuid not null references public.adoption_records(id) on delete cascade,
  submitted_by uuid not null references public.profiles(id) on delete restrict,
  pet_condition text not null default '',
  feeding text not null default '',
  health text not null default '',
  behavior text not null default '',
  photo_paths text[] not null default '{}',
  status text not null default 'pending_review'
    check (status in ('pending_review','reviewed','needs_clarification')),
  review_note text not null default '',
  reviewed_by uuid references public.profiles(id),
  reviewed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.conversations (
  id uuid primary key default gen_random_uuid(),
  application_id uuid references public.adoption_applications(id) on delete set null,
  pet_id uuid not null references public.pets(id) on delete restrict,
  participant_id uuid not null references public.profiles(id) on delete restrict,
  category text not null default 'approved' check (category in ('approved','adopted')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (pet_id, participant_id)
);

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  sender_id uuid not null references public.profiles(id) on delete restrict,
  body text not null check (length(trim(body)) between 1 and 4000),
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.system_feedback (
  id uuid primary key default gen_random_uuid(),
  submitted_by uuid not null references public.profiles(id) on delete cascade,
  rating integer not null check (rating between 1 and 5),
  comments text not null default '',
  adoption_record_id uuid references public.adoption_records(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.account_restrictions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete restrict,
  restriction_type text not null check (restriction_type in ('suspension','ban')),
  reason text not null,
  starts_at timestamptz not null default now(),
  ends_at timestamptz,
  lifted_at timestamptz,
  created_by uuid not null references public.profiles(id),
  created_at timestamptz not null default now()
);

create table if not exists public.admin_audit_logs (
  id bigint generated always as identity primary key,
  administrator_id uuid not null references public.profiles(id),
  action_type text not null,
  target_table text not null,
  target_id text not null,
  previous_status text,
  new_status text,
  reason text not null default '',
  metadata jsonb not null default '{}',
  created_at timestamptz not null default now()
);

create index if not exists pets_status_created_idx on public.pets(listing_status, created_at desc);
create index if not exists applications_status_created_idx on public.adoption_applications(status, created_at desc);
create unique index if not exists one_open_application_per_pet_user_idx
  on public.adoption_applications(pet_id, applicant_id)
  where status not in ('rejected','cancelled','completed');
create index if not exists rehome_status_created_idx on public.rehome_submissions(status, created_at desc);
create index if not exists reports_status_created_idx on public.reports(status, created_at desc);
create index if not exists notifications_recipient_created_idx on public.notifications(recipient_id, created_at desc);
create index if not exists audit_admin_created_idx on public.admin_audit_logs(administrator_id, created_at desc);
create index if not exists profiles_role_status_idx on public.profiles(role, account_status);
create index if not exists monitoring_status_created_idx on public.monitoring_updates(status, created_at desc);
create index if not exists messages_conversation_created_idx on public.messages(conversation_id, created_at);
create index if not exists conversations_participant_idx on public.conversations(participant_id, updated_at desc);

create or replace function private.is_admin(p_user_id uuid default auth.uid())
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.profiles
    where id = p_user_id and role = 'admin' and account_status = 'active'
  );
$$;
revoke all on function private.is_admin(uuid) from public;
grant execute on function private.is_admin(uuid) to authenticated;

create or replace function private.is_active_user(p_user_id uuid default auth.uid())
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.profiles where id = p_user_id and account_status = 'active');
$$;
revoke all on function private.is_active_user(uuid) from public;
grant execute on function private.is_active_user(uuid) to authenticated;

create or replace function private.user_role(p_user_id uuid default auth.uid())
returns text language sql stable security definer set search_path = '' as $$
  select role from public.profiles where id = p_user_id;
$$;
revoke all on function private.user_role(uuid) from public;
grant execute on function private.user_role(uuid) to authenticated;

alter table public.profiles enable row level security;
alter table public.pets enable row level security;
alter table public.adoption_applications enable row level security;
alter table public.rehome_submissions enable row level security;
alter table public.favorites enable row level security;
alter table public.organization_verifications enable row level security;
alter table public.reports enable row level security;
alter table public.notifications enable row level security;
alter table public.adoption_records enable row level security;
alter table public.account_restrictions enable row level security;
alter table public.admin_audit_logs enable row level security;
alter table public.monitoring_updates enable row level security;
alter table public.conversations enable row level security;
alter table public.messages enable row level security;
alter table public.system_feedback enable row level security;

create policy profiles_read_own_or_admin on public.profiles for select to authenticated
using ((select auth.uid()) = id or (select private.is_admin()));
create policy profiles_update_own on public.profiles for update to authenticated
using ((select auth.uid()) = id and (select private.is_active_user()))
with check ((select auth.uid()) = id and role = (select p.role from public.profiles p where p.id = (select auth.uid())));
-- The role comparison above is enforced through a protected lookup to avoid
-- trusting any value supplied by the client.
drop policy profiles_update_own on public.profiles;
create policy profiles_update_own on public.profiles for update to authenticated
using ((select auth.uid()) = id and (select private.is_active_user()))
with check ((select auth.uid()) = id and role = (select private.user_role()));
create policy active_pets_public on public.pets for select to anon, authenticated
using (listing_status = 'active' or owner_id = (select auth.uid()) or (select private.is_admin()));
create policy pets_owner_insert on public.pets for insert to authenticated
with check (owner_id = (select auth.uid()) and listing_status = 'pending' and (select private.is_active_user()));
create policy pets_owner_update on public.pets for update to authenticated
using (owner_id = (select auth.uid()) and listing_status in ('pending','corrections_requested'))
with check (owner_id = (select auth.uid()) and listing_status in ('pending','corrections_requested'));
create policy applications_participant_read on public.adoption_applications for select to authenticated
using (applicant_id = (select auth.uid()) or exists (select 1 from public.pets p where p.id = pet_id and p.owner_id = (select auth.uid())) or (select private.is_admin()));
create policy applications_applicant_insert on public.adoption_applications for insert to authenticated
with check (applicant_id = (select auth.uid()) and status in ('draft','submitted') and (select private.is_active_user()));
create policy applications_applicant_update on public.adoption_applications for update to authenticated
using (applicant_id = (select auth.uid()) and status in ('draft','submitted','more_information') and (select private.is_active_user()))
with check (applicant_id = (select auth.uid()) and status in ('draft','submitted','cancelled') and (select private.is_active_user()));
create policy rehome_owner_all on public.rehome_submissions for all to authenticated
using ((owner_id = (select auth.uid()) and (select private.is_active_user())) or (select private.is_admin()))
with check (owner_id = (select auth.uid()) and status in ('draft','submitted','cancelled') and (select private.is_active_user()));
create policy favorites_own on public.favorites for all to authenticated
using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()) and (select private.is_active_user()));
create policy verification_owner_read on public.organization_verifications for select to authenticated
using (organization_id = (select auth.uid()) or (select private.is_admin()));
create policy verification_owner_insert on public.organization_verifications for insert to authenticated
with check (organization_id = (select auth.uid()) and status = 'pending' and (select private.is_active_user()));
create policy reports_reporter_read on public.reports for select to authenticated
using (reporter_id = (select auth.uid()) or (select private.is_admin()));
create policy reports_reporter_insert on public.reports for insert to authenticated
with check (reporter_id = (select auth.uid()) and status = 'new' and (select private.is_active_user()));
create policy notifications_recipient_read on public.notifications for select to authenticated
using (recipient_id = (select auth.uid()));
create policy notifications_recipient_update on public.notifications for update to authenticated
using (recipient_id = (select auth.uid())) with check (recipient_id = (select auth.uid()));
create policy records_participant_read on public.adoption_records for select to authenticated
using (adopter_id = (select auth.uid()) or rehomer_id = (select auth.uid()) or (select private.is_admin()));
create policy restrictions_admin_read on public.account_restrictions for select to authenticated using ((select private.is_admin()));
create policy audit_admin_read on public.admin_audit_logs for select to authenticated using ((select private.is_admin()));
create policy monitoring_participant_read on public.monitoring_updates for select to authenticated
using (submitted_by = (select auth.uid()) or (select private.is_admin()));
create policy monitoring_adopter_insert on public.monitoring_updates for insert to authenticated
with check (submitted_by = (select auth.uid()) and status = 'pending_review' and exists (
  select 1 from public.adoption_records a where a.id = adoption_record_id and a.adopter_id = (select auth.uid())
));
create policy conversations_participant_read on public.conversations for select to authenticated
using (participant_id = (select auth.uid()) or (select private.is_admin()));
create policy messages_participant_read on public.messages for select to authenticated
using (exists (select 1 from public.conversations c where c.id = conversation_id and (c.participant_id = (select auth.uid()) or (select private.is_admin()))));
create policy messages_participant_insert on public.messages for insert to authenticated
with check (sender_id = (select auth.uid()) and exists (select 1 from public.conversations c where c.id = conversation_id and (c.participant_id = (select auth.uid()) or (select private.is_admin()))));
create policy feedback_own_insert on public.system_feedback for insert to authenticated
with check (submitted_by = (select auth.uid()) and (select private.is_active_user()));
create policy feedback_own_or_admin_read on public.system_feedback for select to authenticated
using (submitted_by = (select auth.uid()) or (select private.is_admin()));

-- A fresh auth user always starts as a non-admin member. raw_user_meta_data is
-- used only for display name; it is never used for authorization.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id, email, full_name, role)
  values (new.id, coalesce(new.email, ''), coalesce(new.raw_user_meta_data->>'full_name', ''), 'adopter');
  return new;
end;
$$;
revoke all on function public.handle_new_user() from public;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute function public.handle_new_user();

create or replace function public.mark_rehomer_role()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  update public.profiles
  set role = 'individual_rehomer', updated_at = now()
  where id = new.owner_id and role = 'adopter';
  return new;
end;
$$;
revoke all on function public.mark_rehomer_role() from public;
drop trigger if exists on_rehome_created on public.rehome_submissions;
create trigger on_rehome_created after insert on public.rehome_submissions
for each row execute function public.mark_rehomer_role();

create or replace function public.admin_workspace()
returns jsonb language plpgsql security definer set search_path = '' as $$
begin
  if not private.is_admin(auth.uid()) then raise exception 'administrator access required' using errcode = '42501'; end if;
  return jsonb_build_object(
    'stats', jsonb_build_object(
      'total_users', (select count(*) from public.profiles where role <> 'admin'),
      'adopters', (select count(*) from public.profiles where role = 'adopter'),
      'individual_rehomers', (select count(*) from public.profiles where role = 'individual_rehomer'),
      'organizations', (select count(*) from public.profiles where role = 'organization'),
      'active_pets', (select count(*) from public.pets where listing_status = 'active'),
      'pending_pets', (select count(*) from public.pets where listing_status = 'pending'),
      'pending_applications', (select count(*) from public.adoption_applications where status in ('submitted','under_review','more_information','screened','owner_review')),
      'completed_adoptions', (select count(*) from public.adoption_records where status = 'completed'),
      'pending_verifications', (select count(*) from public.organization_verifications where status in ('pending','under_review','more_information')),
      'unresolved_reports', (select count(*) from public.reports where status in ('new','under_review')),
      'unread_messages', (select count(*) from public.messages m join public.profiles p on p.id = m.sender_id where p.role <> 'admin' and m.read_at is null),
      'monitoring_updates', (select count(*) from public.monitoring_updates),
      'feedback_submissions', (select count(*) from public.system_feedback),
      'average_rating', coalesce((select round(avg(rating), 1) from public.system_feedback), 0)
    ),
    'users', coalesce((select jsonb_agg(to_jsonb(p) order by p.created_at desc) from public.profiles p where role <> 'admin'), '[]'::jsonb),
    'pets', coalesce((select jsonb_agg(to_jsonb(p) order by p.created_at desc) from public.pets p), '[]'::jsonb),
    'applications', coalesce((select jsonb_agg(
      to_jsonb(a) || jsonb_build_object(
        'applicant_name', pr.full_name,
        'applicant_email', pr.email,
        'pet_name', p.name,
        'pet_breed', p.breed
      ) order by a.created_at desc)
      from public.adoption_applications a
      join public.profiles pr on pr.id = a.applicant_id
      join public.pets p on p.id = a.pet_id), '[]'::jsonb),
    'rehome_submissions', coalesce((select jsonb_agg(to_jsonb(r) order by r.created_at desc) from public.rehome_submissions r), '[]'::jsonb),
    'verifications', coalesce((select jsonb_agg(to_jsonb(v) order by v.created_at desc) from public.organization_verifications v), '[]'::jsonb),
    'reports', coalesce((select jsonb_agg(to_jsonb(r) order by r.created_at desc) from public.reports r), '[]'::jsonb),
    'notifications', coalesce((select jsonb_agg(to_jsonb(n) order by n.created_at desc) from public.notifications n limit 100), '[]'::jsonb),
    'adoption_records', coalesce((select jsonb_agg(
      to_jsonb(a) || jsonb_build_object('pet_name', p.name, 'adopter_name', pr.full_name)
      order by a.created_at desc)
      from public.adoption_records a
      join public.pets p on p.id = a.pet_id
      join public.profiles pr on pr.id = a.adopter_id), '[]'::jsonb),
    'monitoring_updates', coalesce((select jsonb_agg(
      to_jsonb(mu) || jsonb_build_object('pet_name', p.name, 'adopter_name', pr.full_name)
      order by mu.created_at desc)
      from public.monitoring_updates mu
      join public.adoption_records ar on ar.id = mu.adoption_record_id
      join public.pets p on p.id = ar.pet_id
      join public.profiles pr on pr.id = ar.adopter_id), '[]'::jsonb),
    'conversations', coalesce((select jsonb_agg(
      to_jsonb(c) || jsonb_build_object(
        'participant_name', pr.full_name,
        'pet_name', p.name,
        'last_message', (select m.body from public.messages m where m.conversation_id = c.id order by m.created_at desc limit 1),
        'messages', coalesce((select jsonb_agg(
          to_jsonb(m) || jsonb_build_object('sender_role', sp.role) order by m.created_at
        ) from public.messages m join public.profiles sp on sp.id = m.sender_id where m.conversation_id = c.id), '[]'::jsonb)
      ) order by c.updated_at desc)
      from public.conversations c
      join public.profiles pr on pr.id = c.participant_id
      join public.pets p on p.id = c.pet_id), '[]'::jsonb),
    'feedback', coalesce((select jsonb_agg(to_jsonb(f) order by f.created_at desc) from public.system_feedback f), '[]'::jsonb),
    'audit_logs', coalesce((select jsonb_agg(to_jsonb(a) order by a.created_at desc) from public.admin_audit_logs a limit 100), '[]'::jsonb)
    , 'analytics', jsonb_build_object(
      'monthly_applications', coalesce((select jsonb_agg(x order by x.month) from (
        select date_trunc('month', created_at)::date month, count(*) total
        from public.adoption_applications where created_at >= now() - interval '12 months'
        group by 1
      ) x), '[]'::jsonb),
      'monthly_adoptions', coalesce((select jsonb_agg(x order by x.month) from (
        select date_trunc('month', completed_at)::date month, count(*) total
        from public.adoption_records where completed_at >= now() - interval '12 months'
        group by 1
      ) x), '[]'::jsonb),
      'pet_categories', coalesce((select jsonb_agg(x order by x.total desc) from (
        select species, count(*) total from public.pets group by species
      ) x), '[]'::jsonb),
      'completion_rate', coalesce((select round(100.0 * count(*) filter (where status='completed') / nullif(count(*),0), 1) from public.adoption_records), 0),
      'report_resolution_rate', coalesce((select round(100.0 * count(*) filter (where status in ('resolved','dismissed')) / nullif(count(*),0), 1) from public.reports), 0)
    )
  );
end;
$$;
revoke all on function public.admin_workspace() from public;
grant execute on function public.admin_workspace() to authenticated;

create or replace function public.admin_action(p_action text, p_payload jsonb)
returns void language plpgsql security definer set search_path = '' as $$
declare
  v_target text := coalesce(p_payload->>'user_id', p_payload->>'pet_id', p_payload->>'application_id', p_payload->>'report_id', p_payload->>'monitoring_update_id', p_payload->>'conversation_id', 'all');
  v_previous text;
  v_new text := p_payload->>'status';
  v_reason text := trim(coalesce(p_payload->>'reason', ''));
begin
  if not private.is_admin(auth.uid()) then raise exception 'administrator access required' using errcode = '42501'; end if;
  if p_action in ('set_user_status','verify_organization','review_pet','review_application','resolve_report','review_monitoring') and v_reason = '' then
    raise exception 'a reason is required';
  end if;
  case p_action
    when 'set_user_status' then
      if v_new not in ('active','suspended','banned') then raise exception 'invalid account status'; end if;
      select account_status into v_previous from public.profiles where id = (p_payload->>'user_id')::uuid for update;
      update public.profiles set account_status = v_new, updated_at = now() where id = (p_payload->>'user_id')::uuid and role <> 'admin';
      if v_new in ('suspended','banned') then
        insert into public.account_restrictions(user_id, restriction_type, reason, created_by)
        values ((p_payload->>'user_id')::uuid, case when v_new='banned' then 'ban' else 'suspension' end, v_reason, auth.uid());
      else
        update public.account_restrictions set lifted_at = now() where user_id = (p_payload->>'user_id')::uuid and lifted_at is null;
      end if;
    when 'verify_organization' then
      select verification_status into v_previous from public.profiles where id = (p_payload->>'user_id')::uuid for update;
      update public.profiles set verification_status = v_new,
        role = case when v_new = 'verified' then 'organization' when v_new = 'revoked' then 'adopter' else role end,
        account_type = case when v_new = 'verified' then 'organization' else account_type end,
        updated_at = now()
      where id = (p_payload->>'user_id')::uuid;
      update public.organization_verifications set status = v_new, decision_reason = v_reason, reviewed_by = auth.uid(), reviewed_at = now(), updated_at = now() where organization_id = (p_payload->>'user_id')::uuid and status in ('pending','under_review','more_information');
    when 'review_pet' then
      if v_new not in ('approved','active','rejected','corrections_requested','removed') then raise exception 'invalid listing status'; end if;
      select listing_status into v_previous from public.pets where id = (p_payload->>'pet_id')::uuid for update;
      update public.pets set listing_status = v_new, review_note = v_reason, reviewed_by = auth.uid(), reviewed_at = now(), updated_at = now() where id = (p_payload->>'pet_id')::uuid;
    when 'set_pet_status' then
      select listing_status into v_previous from public.pets where id = (p_payload->>'pet_id')::uuid for update;
      update public.pets set listing_status = v_new, reviewed_by = auth.uid(), reviewed_at = now(), updated_at = now() where id = (p_payload->>'pet_id')::uuid;
    when 'review_application' then
      if v_new not in ('under_review','more_information','screened','flagged','disputed') then raise exception 'admins cannot make the pet owner''s final adoption decision'; end if;
      select status into v_previous from public.adoption_applications where id = (p_payload->>'application_id')::uuid for update;
      update public.adoption_applications set status = v_new, review_note = v_reason, reviewed_by = auth.uid(), reviewed_at = now(), updated_at = now() where id = (p_payload->>'application_id')::uuid;
    when 'resolve_report' then
      if v_new not in ('under_review','resolved','dismissed') then raise exception 'invalid report status'; end if;
      select status into v_previous from public.reports where id = (p_payload->>'report_id')::uuid for update;
      update public.reports set status = v_new, resolution = v_reason, assigned_admin_id = auth.uid(), updated_at = now() where id = (p_payload->>'report_id')::uuid;
    when 'send_announcement' then
      insert into public.notifications(recipient_id,title,body,kind)
      select id, p_payload->>'title', p_payload->>'body', 'announcement' from public.profiles where account_status <> 'banned' and notifications_enabled;
      v_new := 'sent';
    when 'review_monitoring' then
      if v_new not in ('reviewed','needs_clarification') then raise exception 'invalid monitoring status'; end if;
      select status into v_previous from public.monitoring_updates where id = (p_payload->>'monitoring_update_id')::uuid for update;
      update public.monitoring_updates
      set status = v_new, review_note = v_reason, reviewed_by = auth.uid(), reviewed_at = now(), updated_at = now()
      where id = (p_payload->>'monitoring_update_id')::uuid;
    when 'send_message' then
      if length(trim(coalesce(p_payload->>'body',''))) < 1 or length(trim(coalesce(p_payload->>'body',''))) > 4000 then raise exception 'message body is required'; end if;
      insert into public.messages(conversation_id, sender_id, body)
      values ((p_payload->>'conversation_id')::uuid, auth.uid(), trim(p_payload->>'body'));
      update public.conversations set updated_at = now() where id = (p_payload->>'conversation_id')::uuid;
      v_new := 'sent';
    else raise exception 'unsupported admin action';
  end case;
  insert into public.admin_audit_logs(administrator_id,action_type,target_table,target_id,previous_status,new_status,reason,metadata)
  values (auth.uid(), p_action, split_part(p_action,'_',2), v_target, v_previous, v_new, v_reason, p_payload - 'reason');
end;
$$;
revoke all on function public.admin_action(text,jsonb) from public;
grant execute on function public.admin_action(text,jsonb) to authenticated;

insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values ('pet-images','pet-images',true,10485760,array['image/jpeg','image/png','image/webp']),
       ('verification-documents','verification-documents',false,10485760,array['image/jpeg','image/png','application/pdf']),
       ('adoption-documents','adoption-documents',false,10485760,array['image/jpeg','image/png','application/pdf'])
on conflict (id) do nothing;

create policy pet_images_public_read on storage.objects for select to anon, authenticated using (bucket_id = 'pet-images');
create policy pet_images_owner_insert on storage.objects for insert to authenticated
with check (bucket_id = 'pet-images' and (storage.foldername(name))[1] = (select auth.uid())::text and (select private.is_active_user()));
create policy pet_images_owner_update on storage.objects for update to authenticated
using (bucket_id = 'pet-images' and owner_id = (select auth.uid())::text)
with check (bucket_id = 'pet-images' and owner_id = (select auth.uid())::text);
create policy private_docs_owner_read on storage.objects for select to authenticated
using (bucket_id in ('verification-documents','adoption-documents') and ((storage.foldername(name))[1] = (select auth.uid())::text or (select private.is_admin())));
create policy private_docs_owner_insert on storage.objects for insert to authenticated
with check (bucket_id in ('verification-documents','adoption-documents') and (storage.foldername(name))[1] = (select auth.uid())::text and (select private.is_active_user()));
create policy private_docs_owner_update on storage.objects for update to authenticated
using (bucket_id in ('verification-documents','adoption-documents') and owner_id = (select auth.uid())::text)
with check (bucket_id in ('verification-documents','adoption-documents') and owner_id = (select auth.uid())::text);
create policy private_docs_owner_delete on storage.objects for delete to authenticated
using (bucket_id in ('verification-documents','adoption-documents') and owner_id = (select auth.uid())::text);

grant select, insert, update, delete on public.profiles, public.pets, public.adoption_applications,
  public.rehome_submissions, public.favorites, public.organization_verifications, public.reports,
  public.notifications, public.adoption_records, public.monitoring_updates, public.conversations,
  public.messages, public.system_feedback to authenticated;
grant select on public.pets to anon;
