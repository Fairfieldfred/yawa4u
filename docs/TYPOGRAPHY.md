# Typography — the textTheme ramp

All text styling flows through the skin system's type ramp. Do **not** write inline
`TextStyle(fontSize: …, fontWeight: …)` in presentation code — use
`context.textTheme.*` (via `core/extensions/context_extensions.dart`) or
`Theme.of(context).textTheme.*`, matching the file's existing idiom.

## The ramp (`lib/core/theme/text_styles.dart` — custom sizes, not stock M3)

| Style          | Size | Weight | Typical role                          |
|----------------|------|--------|---------------------------------------|
| displayLarge   | 32   | bold   | Hero numerals                          |
| displayMedium  | 28   | bold   |                                        |
| displaySmall   | 24   | bold   |                                        |
| headlineLarge  | 22   | bold   | Screen titles                          |
| headlineMedium | 20   | bold   | Dialog titles                          |
| headlineSmall  | 18   | w600   | Section headers, big stats             |
| titleLarge     | 20   | w600   | Card titles (large)                    |
| titleMedium    | 16   | w600   | Card/list titles, filled-button labels |
| titleSmall     | 14   | w600   | List item titles                       |
| bodyLarge      | 16   | normal | Prominent body copy                    |
| bodyMedium     | 14   | normal | Default body copy                      |
| bodySmall      | 12   | normal | Captions, metadata                     |
| labelLarge     | 14   | w600   | Buttons, badges                        |
| labelMedium    | 12   | w600   | Column headers, chips, menu headers    |
| labelSmall     | 10   | w600   | Micro badges, tiny captions            |

Skins recolor the whole ramp via `TextTheme.apply()` in `skin_builder.dart`, so an
inline TextStyle silently opts that text out of skinning — this is the bug class the
2026-07-12 sweep removed (~170 conversions across 37 files; see
`ai_specs/ux-audit-fixes-plan.md`, Phase 7).

## Rules when styling text

- **Need a different color?** `context.textTheme.bodySmall?.copyWith(color: …)` —
  always via `copyWith`, never a bare `TextStyle`. The ramp's own colors are
  overridden by the active skin, so explicit colors must be carried explicitly.
- **Off-ramp size/weight** (rare, e.g. 48px timer numerals, monospace log output):
  nearest ramp style + `copyWith(fontSize: …)`. Don't invent new ramp entries ad hoc.
- **Color-only tweaks** (`TextStyle(color: …)`) are acceptable where the size/weight
  should inherit from the ambient `DefaultTextStyle` (e.g. popup-menu item labels,
  TextSpans inheriting a parent style). ~80 such styles intentionally remain.
- **Weight-only conditional emphasis** (e.g. `fontWeight: isSelected ? bold : normal`
  on chip labels with no fontSize) may stay inline when a component theme owns the
  size — converting would clobber the inherited metrics.
- `const` fallout: a theme lookup can't be `const`; remove the narrowest `const`
  only.

## Visual regression harness

Baseline/after screenshots for typography-affecting changes:

```bash
flutter drive --driver=test_driver/screenshot_driver.dart \
  --target=integration_test/ui_baseline_screenshots_test.dart -d <ios-simulator>
```

- Output lands in `ai_specs/screenshots/current/` (gitignored; regenerable).
- The test is **self-seeding**: `flutter drive` fresh-installs the app (wiping
  simulator app data!), skips onboarding via SharedPreferences, and creates/starts a
  "5 Day Full Body" cycle through the app's own repositories — so runs are
  deterministic and directly diffable. Diff runs with a small PIL script comparing
  `baseline/` vs `current/` per-pixel.
- Harness gotchas (documented in the test header): finders must be `.hitTestable()`
  because hidden StatefulShellRoute branches stay in the widget tree; re-tapping the
  active tab pops its branch to root. Known issue: the light-theme pass sticks after
  its first screen (deterministically, so diffs are still stable); dark has full
  coverage.
