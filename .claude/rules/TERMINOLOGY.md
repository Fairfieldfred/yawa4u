# YAWA4U — Terminology Convention

Post-v6 multi-sport: how to name things consistently in code and UI.

## TL;DR

| Concept | User-facing label | Code / model |
| --- | --- | --- |
| A single training action | **Workout** | `Session` (sealed), `StrengthSession`, `CardioSession` |
| The repeating-period plan | **Training Cycle** (or user's term: Block / Mesocycle / …) | `TrainingCycle` |
| A 7-ish day segment of a cycle | **Period** | `CyclePeriod` |
| One interval of a cardio workout | **Step** (in UI) / **Interval** (in code comments) | `SessionInterval` |
| A sport (run / bike / swim / strength) | **Sport** | `Sport` enum |

## The "Workout vs. Session" question

**Keep "Workout" as the user-facing label.** It works for every sport — runners do workouts, cyclists do workouts, swimmers do workouts. It's more natural English than "session".

**Keep "Session" as the code-level term.** The polymorphic data model built in Phase 2 is `Session` / `StrengthSession` / `CardioSession`, and repositories / providers / mappers all follow that name. Don't rename these back to Workout — the sealed-class pattern loses its meaning.

**Mixed routes are acceptable.** `/trainingCycles/:id/workouts` (legacy strength) and `/cardio-session/:id` (v5+) coexist. Users never see URLs, so consistency there is cosmetic.

**WorkoutRepository is a facade (v6).** The `workouts` table was dropped in v6. `WorkoutRepository` now wraps `SessionRepository` and translates between the legacy `Workout` shape and `StrengthSession`. New code should use `SessionRepository` directly; existing call sites can migrate at their leisure.

## Period vs. Week

Always use **"Period"** when referring to a repeating unit of a training cycle. Reason: cardio periods aren't always 7 days. A 10-day block or 5-day microcycle is a Period. "Week" only if the specific plan really is calendar-week-aligned.

## Training Cycle terminology

The user picks their preferred term in onboarding (Block / Mesocycle / Phase / Module / Wave / default "Training Cycle"). **Always read the stored term via `trainingCycleTermProvider`** in user-facing strings. Don't hardcode "Cycle" or "Training Cycle" in new UI copy — use the provider.

## Don't invent new terms

- ❌ "Training Session" — two "training"s, confusing with "Training Cycle"
- ❌ "Activity" — muddies the water with Android's Activity class
- ❌ "Block" as a generic session term — it's already taken as a terminology option
- ✅ "Session" (code), "Workout" (UI), "Period" (repeating unit), "Step" (interval UI)

## Sport naming

Sport enum values: `strength`, `run`, `bike`, `swim`, `other`. In UI:
- "Strength" (not "Lifting" or "Weights" — keep it broad)
- "Run" (not "Running" in labels, though "Running" is fine in prose)
- "Bike" (not "Cycling" — but "Cycling" works in prose)
- "Swim" (not "Swimming" in labels)

This matches `Sport.displayName`.

## Data model reminders

- `Session` is a sealed class → exhaustive switches are checked at compile time. Don't add new variants without updating every `switch (session)` site.
- `CyclePeriod.phase` is the cardio periodization type (base / build / peak / taper / transition). Distinct from `TrainingCycle.recoveryPeriodType` which is strength (deload / taper / recovery).
- `Session.source` marks where data came from — `userPlanned`, `userLogged`, `healthKit`, `healthConnect`, `peloton`, `strava`, `garmin`, `imported`. Sources other than `userPlanned` and `userLogged` are considered external (`.isExternal` extension). External sessions are read-only for aggregate data.
- **Planned vs Logged:** A cardio session created during draft cycle planning uses `SessionSource.userPlanned` and `WorkoutStatus.incomplete`. The card shows a "Log" button to promote it to completed. This mirrors how strength exercises work with the "Log" affordance.
