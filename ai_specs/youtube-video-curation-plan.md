# YouTube Per-Exercise Video Curation — Plan (YAWA4U port)

## Overview

Offline curation pipeline: Dart CLI searches YouTube per exercise, verifies embeddability, has Claude rank candidates by title/description, emits a generated Dart video map + human review report. The tool was built for another app and copied here (`tool/video_curator/`) — it is config-driven, so this port is **reconfigure + swap the emitter**, not a rebuild.

## Context

- **Tool status**: `tool/video_curator/` already contains the working CLI (`bin/curate.dart` with `--exercise`, `--workout`, `--all`, `--budget`, `--exclude`, `--emit`), `youtube_client.dart`, `ranker.dart`, `pipeline.dart` (resume + quota tracking), `report.dart`, and tests. `.env` with `YOUTUBE_API_KEY` came along and is gitignored — **no API-key setup needed**.
- **Stale artifacts from the old app** (must be cleared before first run): `results/*.json` + `results/review.html` (P90X exercise names) and `config/exercises.json` (old app's workout lists).
- **Exercise source (this app)**: `exercises.csv` at repo root — **344 unique names** (first column), plus Muscle Group and Equipment columns. Names are **identity keys** stored in English in the DB (CLAUDE.md pitfall #4): the generated map must key on them **byte-for-byte**, and the CSV itself must never be modified. Localization is display-time only — irrelevant to this pipeline.
- **No "workouts" grouping here**: the config's `workout` field is just a grouping/context key, so repurpose it as **Muscle Group** (`Chest`, `Back`, …). That makes `--workout "Chest"` batch by muscle group with zero pipeline changes, and gives the ranker better context than the old workout names did. Equipment goes into `searchHints` (e.g. "Cable Row" + "cable" disambiguates from barbell rows).
- **No "X 2" duplicate variants** in this CSV — the old plan's duplicate-dedupe/second-pick logic is unused here (harmless to leave in place).
- **Integration point (this app)**: `lib/presentation/widgets/dialogs/exercise_info_dialog.dart` resolves the Information-tab video as `exercise.videoUrl ?? _exerciseVideos[exercise.name]`, where `_exerciseVideos` is a small hand-curated map (~27 entries, mostly empty strings). The player is `youtube_player_flutter` via `initialVideoId` — **start/end timestamps are not used in this app**, so the old `[videoId, start, end]` output format is dropped.
- **Custom exercises are out of scope** — users set `videoUrl` on their own definitions; that field already overrides everything.
- **Quota**: `search.list` = 100 units, `videos.list` = 1 unit; default 10,000 units/day ≈ 99 exercises/day → 344 names ≈ **4 daily runs** (resume already built) — or batch one muscle-group cluster per day, or request a quota increase.

## Emitter swap (the app-specific piece)

The old `lib/emitter.dart` wrote `lib/model/video_lists.g.dart` — per-workout `List<List<dynamic>>` of `[videoId, start, end]` keyed by workout name. None of that matches YAWA4U. Replace its `emitDart()` body to write:

- **Output file**: `lib/core/constants/exercise_videos.g.dart`
- **Shape**: `const Map<String, String> generatedExerciseVideos = { 'Arnold Press': 'https://www.youtube.com/watch?v=…', … };`
- Keys: canonical CSV names verbatim, **Dart-escaped** (names contain apostrophes: `Dumbbell Farmer's Walk`).
- Values: full watch URLs (the dialog's `_extractVideoId` handles URLs and bare IDs; URLs are nicer for human review).
- Not-yet-curated exercises: **omit** (no fallback entry — the dialog already shows a "no video" state); list them in a trailing comment block so coverage gaps are visible.
- Keep the GENERATED header + regenerate command comment.

Everything else in the tool (client, ranker, pipeline, report, CLI) is reused unmodified.

## Plan

### Phase 1: Port hygiene + one-exercise vertical slice

- **Goal**: clean tool state; `dart run bin/curate.dart --exercise "Arnold Press"` picks an embeddable video end-to-end.
- [x] Delete stale `results/*.json` + `results/review.html` (old app's picks — wrong exercise names)
- [x] Regenerate `tool/video_curator/config/exercises.json` from `exercises.csv` via `tool/video_curator/gen_config.py` — 344 unique names, muscle group as `workout`, equipment as `searchHints`
- [x] Confirm `.env` key still valid; `dart pub get` inside `tool/video_curator`
- [x] Verify: `dart analyze` clean, 9/9 tests pass, live run on "Arnold Press" → embeddable pick at 0.92 confidence (101 quota units)

### Phase 2: Full curation run — quota-aware, resumable

- **Goal**: all 344 exercises curated across ~4 daily runs (or fewer with a quota bump).
- [x] Batch 1 (2026-07-25): 92 curated, 251 left; 1 flagged no-embeddable ("Crouching Cowen Curls"), 9 picks < 0.7 confidence → review pass
- [x] Batch 2 (2026-07-26): 94 curated, 157 left (9,494 units); low-confidence total now 20; map re-emitted (186 entries)
- [x] Batch 3 (2026-07-27): 94 curated, 63 left (9,494 units); low-confidence total now 30; map re-emitted (280 entries)
- [x] Batch 4 (2026-07-28): final 63 curated (6,363 units) — **all 344 done**; map re-emitted (343 entries; 1 no-pick)
- [x] Verify: result JSON count == 344; `flutter analyze` clean

### Phase 3: Emitter swap, review, wire into app

- **Goal**: generated map compiled into the app; Information tab shows videos for built-in exercises.
- [x] Rewrite `tool/video_curator/lib/emitter.dart` per "Emitter swap" above; `--emit` output path updated in `bin/curate.dart`
- [x] TDD: emitter escapes apostrophes; omits uncurated names (tests in `test/pipeline_test.dart`)
- [x] `--emit` → `lib/core/constants/exercise_videos.g.dart` (92 entries so far; re-run after each batch)
- [x] `exercise_info_dialog.dart`: `resolveExerciseVideoUrl()` chain (videoUrl → hand map → generated map, empty strings skipped); empty-string entries pruned from the hand map
- [ ] Human review pass over `results/review.html` (start with the 38 low-confidence picks + the no-embeddable flag); `--exercise <name> --exclude <id>` re-picks, then re-`--emit`. For obscure CSV names that search poorly, add `--query "<common name> how to proper form"` — the search changes but the exercise name stays the result key (flag added 2026-07-28; first use fixed "Dumbbell Bent Lateral Raise" 0.45 → 0.9)
- [ ] Verify: on-device spot-check of ~10 exercises across muscle groups (embeddability false-positives only show up at play time) — `flutter analyze` && `flutter test` (1193) already green

## Risks / Out of scope

- **Risks**: (1) Quota — 344 searches ≈ 4 days; mitigated by resume + muscle-group batching. (2) Embeddability false positives — API says embeddable but playback blocks in-app; mitigated by review report + `--exclude` re-pick. (3) Generic exercise names ("Superman", "Bird Dog", "Clean") can rank irrelevant videos — muscle group + equipment context in the ranker prompt mitigates; human review catches the rest.
- **Out of scope**: start/end timestamps (player doesn't use them here); custom-exercise videos (user-provided); in-app runtime search; modifying `exercises.csv` (identity keys); localized video picks (names/keys stay English).
