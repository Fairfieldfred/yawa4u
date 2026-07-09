# Flutter/Dart rules (condensed)

Working rules for this codebase. Full rationale lives in Effective Dart
(https://dart.dev/effective-dart) — this file keeps only what changes behavior.

## Code style

- `PascalCase` classes, `camelCase` members/variables/enums, `snake_case` files.
- Line length follows `analysis_options.yaml`: **120 chars**, trailing commas preserved.
- Short single-purpose functions (aim < 20 lines); arrow syntax for one-liners.
- No trailing comments. Comments explain *why*, not *what*.
- Meaningful names — no abbreviations.
- Run `dart format` / `dart fix`; `flutter analyze` must stay clean.

## Dart

- Soundly null-safe; avoid `!` unless non-null is guaranteed.
- Prefer exhaustive `switch` expressions, pattern matching, and records where they
  simplify code (the `Session` sealed class relies on exhaustive switches).
- `async`/`await` with real error handling — no silently swallowed failures.
  Custom exceptions for domain-specific errors.
- Logging via `dart:developer` `log(...)` (or `logging` package), never `print`.

## Flutter

- Immutable widgets; composition over inheritance.
- Small private `Widget` **classes**, not private helper methods returning widgets.
- `const` constructors wherever possible; no expensive work in `build()`.
- `ListView.builder` / slivers for long lists; `compute()` for heavy parsing.
- Overflow safety: `Expanded`/`Flexible` in rows/columns, `Wrap` for wrapping,
  builder-based scrollables for long content, `LayoutBuilder` for responsive decisions.

## State management & architecture

- **This project uses Riverpod** (see DATA_STRUCTURE_v6.md for the provider catalog):
  `StreamProvider` for reactive Drift queries, `Provider.family` for parameterized
  lookups, `Notifier` for complex screen state. Don't introduce other state solutions.
- Layered: presentation → domain (providers/controllers) → data (repositories → DAOs).
  Repositories own persistence; UI never touches DAOs directly (hot-path debounced
  writes are the sanctioned exception).
- Navigation via `go_router` for routable screens; plain `Navigator` only for
  dialogs/short-lived flows (see CLAUDE.md for the home-tab / pageless-route gotcha).

## Theming

- All styling flows through the skin system (`lib/core/theme/skins/`) and
  `Theme.of(context)` — no hardcoded colors/text styles in widgets.
- Custom design tokens go in `ThemeExtension`s.
- Dynamic text scaling and ≥ 4.5:1 text contrast; `Semantics` labels on
  interactive elements (widget tests rely on semantic identifiers).

## Testing

- Arrange-Act-Assert. Unit tests for domain/data logic, widget tests for UI.
- Prefer fakes/stubs over mocks; if mocking is unavoidable use `mocktail`.
- Override `appDatabaseProvider` with `AppDatabase.forTesting(NativeDatabase.memory())`
  in tests — see `test/helpers/`.

## Documentation

- `///` doc comments on public APIs; first sentence is a one-line summary ending
  with a period, then a blank line. Don't restate the obvious from the signature.
