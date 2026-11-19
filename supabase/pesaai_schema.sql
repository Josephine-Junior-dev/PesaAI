-- PesaAI independent schema. Run in the existing Garage Operations Supabase project.
-- Uses Supabase Auth ownership. No service-role key is required by the browser.

create extension if not exists pgcrypto;

create table if not exists public.pa_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '',
  preferred_currency text not null default 'KES',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint pa_profiles_currency_check check (preferred_currency ~ '^[A-Z]{3}$')
);

create table if not exists public.pa_financial_spaces (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  space_type text not null check (space_type in ('personal','business')),
  name text not null,
  currency text not null default 'KES' check (currency ~ '^[A-Z]{3}$'),
  created_at timestamptz not null default now()
);

create table if not exists public.pa_business_profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  space_id uuid not null references public.pa_financial_spaces(id) on delete cascade,
  business_name text not null,
  business_type text,
  country_code text,
  created_at timestamptz not null default now(),
  unique(space_id)
);

create table if not exists public.pa_transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  space_id uuid not null references public.pa_financial_spaces(id) on delete cascade,
  business_id uuid references public.pa_business_profiles(id) on delete set null,
  transaction_type text not null check (transaction_type in ('income','expense','transfer_in','transfer_out')),
  amount numeric(18,2) not null check (amount > 0),
  currency text not null default 'KES' check (currency ~ '^[A-Z]{3}$'),
  description text not null,
  category text not null default 'Other',
  transaction_date date not null default current_date,
  source text not null default 'manual',
  external_reference text,
  transfer_group_id uuid,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists pa_transactions_user_date_idx on public.pa_transactions(user_id, transaction_date desc);
create index if not exists pa_transactions_space_idx on public.pa_transactions(space_id, transaction_date desc);
create unique index if not exists pa_transactions_external_reference_unique
  on public.pa_transactions(user_id, external_reference) where external_reference is not null;

create table if not exists public.pa_transfers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  from_space_id uuid not null references public.pa_financial_spaces(id) on delete cascade,
  to_space_id uuid not null references public.pa_financial_spaces(id) on delete cascade,
  amount numeric(18,2) not null check (amount > 0),
  currency text not null default 'KES',
  transfer_date date not null default current_date,
  description text,
  created_at timestamptz not null default now(),
  check (from_space_id <> to_space_id)
);

create table if not exists public.pa_budgets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  space_id uuid not null references public.pa_financial_spaces(id) on delete cascade,
  name text not null,
  category text not null default 'General',
  amount numeric(18,2) not null check (amount > 0),
  currency text not null default 'KES',
  period text not null default 'monthly' check (period in ('weekly','monthly','yearly')),
  starts_on date not null default current_date,
  created_at timestamptz not null default now()
);

create table if not exists public.pa_savings_goals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  space_id uuid not null references public.pa_financial_spaces(id) on delete cascade,
  name text not null,
  target_amount numeric(18,2) not null check (target_amount > 0),
  current_amount numeric(18,2) not null default 0 check (current_amount >= 0),
  currency text not null default 'KES',
  target_date date,
  created_at timestamptz not null default now()
);

create table if not exists public.pa_debts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  space_id uuid not null references public.pa_financial_spaces(id) on delete cascade,
  creditor text not null,
  description text,
  original_amount numeric(18,2) not null check (original_amount > 0),
  outstanding_amount numeric(18,2) not null check (outstanding_amount >= 0),
  currency text not null default 'KES',
  due_date date,
  status text not null default 'active' check (status in ('active','paid','settled')),
  created_at timestamptz not null default now()
);

create table if not exists public.pa_financial_scores (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  score integer not null check (score between 0 and 100),
  components jsonb not null default '{}'::jsonb,
  explanation text,
  calculated_at timestamptz not null default now()
);

create table if not exists public.pa_financial_twins (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  twin_type text not null check (twin_type in ('personal','business','combined')),
  snapshot jsonb not null default '{}'::jsonb,
  assumptions jsonb not null default '{}'::jsonb,
  generated_at timestamptz not null default now()
);

create table if not exists public.pa_simulations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  scenario_type text not null default 'savings',
  inputs jsonb not null default '{}'::jsonb,
  results jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.pa_life_goals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  space_id uuid references public.pa_financial_spaces(id) on delete cascade,
  title text not null,
  goal_type text not null default 'general',
  target_amount numeric(18,2) not null check (target_amount > 0),
  current_amount numeric(18,2) not null default 0 check (current_amount >= 0),
  currency text not null default 'KES',
  target_date date,
  created_at timestamptz not null default now()
);

create table if not exists public.pa_family_members (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  display_name text not null,
  relationship text,
  invitation_email text,
  status text not null default 'pending' check (status in ('pending','active','revoked')),
  created_at timestamptz not null default now()
);

create table if not exists public.pa_alerts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  alert_type text not null,
  severity text not null default 'info' check (severity in ('info','warning','critical')),
  title text not null,
  message text not null,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.pa_ai_conversations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null default 'New conversation',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.pa_ai_messages (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  conversation_id uuid not null references public.pa_ai_conversations(id) on delete cascade,
  role text not null check (role in ('user','assistant')),
  content text not null,
  created_at timestamptz not null default now()
);

-- Enable RLS and enforce user ownership on all PesaAI user data.
do $$
declare t text;
begin
  foreach t in array array[
    'pa_financial_spaces','pa_business_profiles','pa_transactions',
    'pa_transfers','pa_budgets','pa_savings_goals','pa_debts','pa_financial_scores',
    'pa_financial_twins','pa_simulations','pa_life_goals','pa_family_members',
    'pa_alerts','pa_ai_conversations','pa_ai_messages'
  ] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('drop policy if exists %I on public.%I', t || '_own', t);
    execute format(
      'create policy %I on public.%I for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid())',
      t || '_own', t
    );
    execute format('grant select, insert, update, delete on public.%I to authenticated', t);
  end loop;
end $$;

-- Profiles use id as their ownership key (all other tables use user_id).
alter table public.pa_profiles enable row level security;
drop policy if exists pa_profiles_own on public.pa_profiles;
create policy pa_profiles_own on public.pa_profiles
  for all to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());
grant select, insert, update, delete on public.pa_profiles to authenticated;

-- Profile and default financial spaces are provisioned on first account creation.
create or replace function public.pa_handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.pa_profiles(id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name',''))
  on conflict (id) do nothing;

  insert into public.pa_financial_spaces(user_id, space_type, name, currency)
  values
    (new.id, 'personal', 'Personal', coalesce(new.raw_user_meta_data->>'currency','KES')),
    (new.id, 'business', 'My Business', coalesce(new.raw_user_meta_data->>'currency','KES'));

  return new;
end;
$$;

drop trigger if exists pa_on_auth_user_created on auth.users;
create trigger pa_on_auth_user_created
after insert on auth.users
for each row execute procedure public.pa_handle_new_user();

-- Backfill profiles/spaces for accounts created before this trigger is installed.
insert into public.pa_profiles(id, full_name)
select id, coalesce(raw_user_meta_data->>'full_name','') from auth.users
on conflict (id) do nothing;

insert into public.pa_financial_spaces(user_id, space_type, name, currency)
select u.id, v.space_type, v.space_name, coalesce(u.raw_user_meta_data->>'currency','KES')
from auth.users u
cross join (values ('personal','Personal'),('business','My Business')) as v(space_type,space_name)
where not exists (
  select 1 from public.pa_financial_spaces s
  where s.user_id = u.id and s.space_type = v.space_type
);

grant usage on schema public to authenticated;
