# SPPB App — UCF Healthy Aging Lab

A standalone iPad (Flutter) app for administering the Short Physical
Performance Battery (SPPB): balance (side-by-side / semi-tandem /
tandem holds), gait speed (two 4-meter walk trials), and chair stand
(5x sit-to-stand). The guided flow mirrors the NIA SPPB reference app.
Every raw timing/observation is written straight to Supabase alongside
the computed sub-scores (0-4 each) and total score (0-12).

## 1. Set up Supabase

1. Create the Supabase project (Robert).
2. In the Supabase SQL editor, run `supabase/schema.sql` from this
   repo. It creates four tables (`assessments`, `balance_trials`,
   `gait_trials`, `chair_stand_trials`) with row-level security
   policies that allow the app's anon key to insert/select/update but
   not delete. Read the comment above the RLS section — the anon key
   ships inside the compiled app, so those policies are the only thing
   standing between the iPad and the tables.
3. Grab the project URL and anon key from Project Settings → API.

## 2. Configure the app

Either edit the fallback constants in
`lib/config/supabase_config.dart`, or (safer — keeps the keys out of
source control) pass them at run/build time:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJ...
```

If you build a release IPA, pass the same `--dart-define` flags to
`flutter build ipa`.

## 3. Run it

```bash
flutter pub get
flutter run   # with an iPad simulator or a connected iPad selected
```

Run the unit tests for the scoring logic with:

```bash
flutter test
```

> **Note on how this project was built:** this codebase was written
> without access to a Flutter/Dart toolchain in the authoring
> environment (no network access to install the SDK), so it has not
> been run through `flutter pub get` / `flutter analyze` / `flutter
> run` yet. The scoring algorithm itself (`lib/services/scoring_service.dart`)
> was independently verified by porting it to Python and checking it
> against the full set of cases in `test/scoring_service_test.dart` —
> those all pass. But the Flutter/Dart code has only been reviewed by
> eye for syntax, so please run `flutter pub get` and `flutter run` as
> your first step and send me anything that doesn't compile — that's
> normal for a first pass like this and quick to fix once I can see the
> actual error.

## App flow

1. **Home** → "New Assessment"
2. **New Assessment** — date/time, assessment type (Clinical/Research),
   patient name, physician name, test location, administrator(s). This
   creates the `assessments` row immediately so every later screen has
   an `assessment_id` to attach trials to.
3. **SPPB instructions** (read-aloud script)
4. **Balance**: side-by-side → (if held ≥10s) semi-tandem → (if held
   ≥10s) tandem. Each stance has an instructions screen ("Not
   performed" / "Go to test") and a timed dial that auto-stops at
   10.00s. Skip logic matches the standard SPPB protocol.
5. **Gait speed**: instructions, then two timed walk trials (manual
   start/stop stopwatch — no auto-stop, since it's a fixed-distance
   walk with no fixed max time).
6. **Chair stand**: instructions → single-stand safety check (yes/no,
   not timed) → if successful, timed 5-repetition stand (tap "+1
   Stand" per rep; auto-stops at 5 reps or at 60 seconds).
7. **Summary** — shows Balance / Gait / Chair Stand / Total scores,
   writes them to the `assessments` row, and returns to Home.

## Scoring reference

Implemented in `lib/services/scoring_service.dart`, following the
standard Guralnik et al. SPPB algorithm (see also
https://sppbguide.com):

- **Balance (0-4):** 0 if side-by-side held <10s. 1 if side-by-side
  ≥10s but semi-tandem <10s. If semi-tandem ≥10s, tandem is attempted:
  2 for 0-2.99s, 3 for 3-9.99s, 4 for ≥10s.
- **Gait speed (0-4):** from the faster of two 4m walk trials — 4 for
  ≤4.81s, 3 for 4.82-6.20s, 2 for 6.21-8.70s, 1 for >8.70s, 0 if
  unable.
- **Chair stand (0-4):** 0 if unable to do a single stand, unable to
  complete all 5 reps, or ≥60s. Otherwise 4 for ≤11.19s, 3 for
  11.20-13.69s, 2 for 13.70-16.69s, 1 for 16.70-59.99s.
- **Total:** sum of the three, 0-12.

## Design decisions (per project discussion)

- **No login / kiosk mode**: administrator name is a free-text field
  per assessment, matching the reference app. No Supabase Auth.
- **Online-only writes**: each Save button writes directly to
  Supabase; there's no local offline cache or retry queue. If a save
  fails (e.g. a dropped connection), the app surfaces the error so the
  trial can be redone — data is not silently queued.
- **Raw + derived data**: every stance/trial row stores the raw
  stopwatch reading (and "not performed" reason, if applicable); the
  `assessments` row stores only the final computed sub-scores/total,
  written once the summary screen's Save completes.

## Project structure

```
lib/
  config/supabase_config.dart     Supabase URL/anon key
  models/                         Assessment, trial, and enum types
  services/
    scoring_service.dart          Pure SPPB scoring functions
    supabase_service.dart         All Supabase reads/writes
  state/assessment_session.dart   In-memory state for one assessment
  theme/app_theme.dart            Colors/styles matching the NIA app
  widgets/
    circular_timer.dart           Stopwatch controller + dial widget
    sppb_scaffold.dart            Shared header/footer page chrome
    action_buttons.dart           "Not performed"/"Go to test", "Save"/"Redo"
    not_performed_dialog.dart     Reason picker bottom sheet
  screens/
    home_screen.dart
    new_assessment_screen.dart
    sppb_intro_screen.dart
    balance/                      Intro + timed test screens
    gait/                         Intro + timed test screens
    chair_stand/                  Intro, single-stand, timed screens
    summary_screen.dart
supabase/schema.sql                Run this in the Supabase SQL editor
test/scoring_service_test.dart     Unit tests for the scoring algorithm
```

## Known follow-ups / things to decide together

- **Gait course distance**: the model supports a configurable
  `distanceMeters` per trial (stored per row), but the UI currently
  assumes the standard 4m course and doesn't expose a picker for a 3m
  alternative. Easy to add if the lab uses a shorter course sometimes.
- **Editing a saved assessment**: there's currently no screen to pull
  up a past assessment and review/correct it — only forward data
  entry. Worth adding if data QA is part of the workflow.
- **iPad orientation/sizing**: built with standard responsive Flutter
  layouts, but hasn't been visually tuned against an actual iPad
  screen yet — recommend a pass on real hardware before hitting the
  reference-app's UI closely.
