-- SPPB (Short Physical Performance Battery) data collection schema
-- UCF Healthy Aging Lab — PI: Dr. Megha Parikh
--
-- Run this in the Supabase SQL editor (or via `supabase db push` /
-- migrations) on a fresh project. It creates:
--   1. assessments            — one row per administered SPPB
--   2. balance_trials         — one row per stance attempted (up to 3)
--   3. gait_trials            — one row per walk trial (up to 2)
--   4. chair_stand_trials     — one row per assessment's chair stand data
--
-- Every raw timing/observation is stored on the trial tables; the
-- computed sub-scores and total live on `assessments` once the
-- assessment is finished, so you can query final scores without
-- re-deriving them, while still having the raw data for auditing,
-- re-scoring, or research analysis.

create extension if not exists pgcrypto;

-- ---------------------------------------------------------------------
-- assessments
-- ---------------------------------------------------------------------
create table if not exists public.assessments (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),

  assessment_date timestamptz not null,
  assessment_type text not null check (assessment_type in ('clinical', 'research')),

  patient_first_name text not null,
  patient_last_name text not null,
  physician_first_name text,
  physician_last_name text,

  test_location text not null check (test_location in ('medicalFacility', 'home', 'nursingHome')),
  test_administrator_1 text not null,
  test_administrator_2 text,

  -- Populated once all three components are complete.
  balance_score smallint check (balance_score between 0 and 4),
  gait_score smallint check (gait_score between 0 and 4),
  chair_stand_score smallint check (chair_stand_score between 0 and 4),
  total_score smallint check (total_score between 0 and 12),

  status text not null default 'in_progress' check (status in ('in_progress', 'completed')),
  completed_at timestamptz
);

create index if not exists assessments_patient_idx
  on public.assessments (patient_last_name, patient_first_name);
create index if not exists assessments_date_idx
  on public.assessments (assessment_date);

-- ---------------------------------------------------------------------
-- balance_trials  (side-by-side / semi-tandem / tandem)
-- ---------------------------------------------------------------------
create table if not exists public.balance_trials (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  assessment_id uuid not null references public.assessments (id) on delete cascade,

  stance text not null check (stance in ('sideBySide', 'semiTandem', 'tandem')),
  attempted boolean not null,
  held_seconds numeric(5, 2), -- raw stopwatch reading, capped at 10.00 by the app
  not_performed_reason text check (
    not_performed_reason in (
      'triedButUnable', 'notAttemptedFeltUnsafe', 'unableToFollowInstruction',
      'administratorStoppedTest', 'refused'
    )
  ),

  unique (assessment_id, stance)
);

-- ---------------------------------------------------------------------
-- gait_trials  (up to 2 walk trials)
-- ---------------------------------------------------------------------
create table if not exists public.gait_trials (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  assessment_id uuid not null references public.assessments (id) on delete cascade,

  trial_number smallint not null check (trial_number in (1, 2)),
  distance_meters numeric(4, 2) not null default 4.0,
  attempted boolean not null,
  time_seconds numeric(6, 2), -- raw stopwatch reading
  not_performed_reason text check (
    not_performed_reason in (
      'triedButUnable', 'notAttemptedFeltUnsafe', 'unableToFollowInstruction',
      'administratorStoppedTest', 'refused'
    )
  ),

  unique (assessment_id, trial_number)
);

-- ---------------------------------------------------------------------
-- chair_stand_trials  (single-stand check + timed 5x sit-to-stand)
-- ---------------------------------------------------------------------
create table if not exists public.chair_stand_trials (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  assessment_id uuid not null unique references public.assessments (id) on delete cascade,

  single_stand_attempted boolean not null default false,
  single_stand_successful boolean,
  single_stand_not_performed_reason text check (
    single_stand_not_performed_reason in (
      'triedButUnable', 'notAttemptedFeltUnsafe', 'unableToFollowInstruction',
      'administratorStoppedTest', 'refused'
    )
  ),

  five_stand_attempted boolean not null default false,
  five_stand_time_seconds numeric(6, 2), -- raw stopwatch reading
  five_stand_completed boolean not null default false, -- all 5 reps done, <60s
  five_stand_not_performed_reason text check (
    five_stand_not_performed_reason in (
      'triedButUnable', 'notAttemptedFeltUnsafe', 'unableToFollowInstruction',
      'administratorStoppedTest', 'refused'
    )
  )
);

-- ---------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------
-- The app is a kiosk-mode iPad with no per-user login: it talks to
-- Supabase with the project's anon key. That key is bundled into the
-- compiled app, so anyone who extracted it could reach the tables it's
-- allowed to reach — the policies below are what stand between "the
-- lab's iPad" and "the public internet". They allow the anon key to
-- INSERT and SELECT/UPDATE, which is what the app needs to create and
-- complete an assessment; they do NOT allow anon to DELETE. If this
-- app should never be able to alter a row once it's saved, tighten the
-- update policy to `false` for anything other than the fields the
-- summary screen writes, or move the completion write behind a Supabase
-- Edge Function instead.

alter table public.assessments enable row level security;
alter table public.balance_trials enable row level security;
alter table public.gait_trials enable row level security;
alter table public.chair_stand_trials enable row level security;

create policy "anon can insert assessments" on public.assessments
  for insert to anon with check (true);
create policy "anon can select assessments" on public.assessments
  for select to anon using (true);
create policy "anon can update assessments" on public.assessments
  for update to anon using (true) with check (true);

create policy "anon can insert balance_trials" on public.balance_trials
  for insert to anon with check (true);
create policy "anon can select balance_trials" on public.balance_trials
  for select to anon using (true);
create policy "anon can update balance_trials" on public.balance_trials
  for update to anon using (true) with check (true);

create policy "anon can insert gait_trials" on public.gait_trials
  for insert to anon with check (true);
create policy "anon can select gait_trials" on public.gait_trials
  for select to anon using (true);
create policy "anon can update gait_trials" on public.gait_trials
  for update to anon using (true) with check (true);

create policy "anon can insert chair_stand_trials" on public.chair_stand_trials
  for insert to anon with check (true);
create policy "anon can select chair_stand_trials" on public.chair_stand_trials
  for select to anon using (true);
create policy "anon can update chair_stand_trials" on public.chair_stand_trials
  for update to anon using (true) with check (true);
