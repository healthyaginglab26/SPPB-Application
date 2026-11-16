# SPPB App — UCF Healthy Aging Lab

A standalone iPad (Flutter) app for administering the Short Physical
Performance Battery (SPPB): balance (side-by-side / semi-tandem /
tandem holds), gait speed (two 4-meter walk trials), and chair stand
(5x sit-to-stand). The guided flow mirrors the NIA SPPB reference app.
Every raw timing/observation is written straight to Supabase alongside
the computed sub-scores (0-4 each) and total score (0-12).

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

## Design decisions 

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
