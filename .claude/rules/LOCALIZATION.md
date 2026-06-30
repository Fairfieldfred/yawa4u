# YAWA4U — Adding a New Language

How to add full localization for a new language. There are **two independent
translation surfaces**:

1. **UI strings** — buttons, labels, dialogs (ARB / `flutter gen-l10n`).
2. **Built-in exercise names** — the ~344 entries from `exercises.csv`
   (a separate JSON asset, translated at display time).

Both must be done for a complete translation. The example below uses French
(`fr`); substitute the [ISO 639-1 code](https://en.wikipedia.org/wiki/List_of_ISO_639_language_codes)
for your language.

---

## Overview / files involved

| Surface | File(s) to touch |
| --- | --- |
| UI strings | `lib/l10n/app_<code>.arb` (new), `app_en.arb` (one label) |
| UI codegen | run `flutter gen-l10n` (regenerates `app_localizations*.dart`) |
| Language picker | `lib/presentation/widgets/localization_classes.dart` |
| Exercise names | `assets/i18n/exercise_names_<code>.json` (new) |
| Exercise localizer | `lib/data/services/exercise_name_localizer.dart` (one list) |

`supportedLocales` and `assets/i18n/` are already wired — you do **not** edit
`main.dart` or `pubspec.yaml` for a new language.

---

## Part 1 — UI strings (ARB)

The l10n config is `l10n.yaml` (arb-dir `lib/l10n`, template `app_en.arb`,
output `app_localizations.dart`). `app_en.arb` is the source of truth — it has
~1,407 message keys, each with `@key` metadata (placeholders, descriptions).

### Steps

1. **Add a picker label to `app_en.arb`.** Next to `localeEnglish` /
   `localeSpanish`, add a key for the new language's name (written in that
   language, the convention used by the picker):
   ```json
   "localeFrench": "Français",
   ```

2. **Create `lib/l10n/app_<code>.arb`.** It needs `"@@locale": "<code>"` as the
   first entry, then **every translatable key** from `app_en.arb` with its value
   translated. You do **not** need the `@key` metadata blocks (those only live in
   the template) — just the `"key": "translated value"` pairs, including the new
   `localeFrench` key.

   The fastest reliable way to build it (used for `es`):
   - Extract the message pairs from `app_en.arb` (every key not starting with
     `@`, value is a String).
   - Translate the values (split into chunks + parallel translator agents for
     large volumes — see "Translation tooling" below).
   - Reassemble into `app_<code>.arb`, preserving the English key order.

3. **Preserve placeholders and ICU exactly.** Tokens like `{name}`, `{count}`,
   `{cycleTerm}`, `{error}` must appear verbatim. For ICU plural/select messages
   (there are ~13, e.g. `strengthSessionCount`), keep the structure
   `{count, plural, =1{…} other{…}}` and the selectors — translate only the
   human-readable sub-messages. Keep JSON escaping valid (`\"`, `\n`).

4. **Regenerate.** From the project root:
   ```bash
   flutter gen-l10n
   ```
   This creates `lib/l10n/app_localizations_<code>.dart` and adds the locale to
   `AppLocalizations.supportedLocales` automatically. `MaterialApp` in
   `main.dart` already reads `supportedLocales`, so no change needed there.

### Validate the ARB before regenerating

The translation must have the **same key set** as the English source (no missing
/ extra keys) and **matching placeholders**. A quick parity check:
```bash
python3 - <<'PY'
import json, re
en = {k: v for k, v in json.load(open('lib/l10n/app_en.arb')).items()
      if not k.startswith('@') and isinstance(v, str)}
fr = {k: v for k, v in json.load(open('lib/l10n/app_fr.arb')).items()
      if not k.startswith('@')}
print("missing:", sorted(set(en) - set(fr)))
print("extra:", sorted(set(fr) - set(en)))
def ph(s): return set(re.findall(r'\{([a-zA-Z0-9_]+)', s))
print("placeholder mismatches:",
      [k for k in set(en) & set(fr) if ph(en[k]) != ph(fr[k])])
PY
```
(Words inside ICU sub-messages can show as false-positive "placeholder
mismatches" — eyeball those few against the source.)

---

## Part 2 — Language picker

Add the locale to the in-app selector so users can choose it.

`lib/presentation/widgets/localization_classes.dart` → the `locales` list:
```dart
final locales = [
  (null, l10n.localeSystem, 'locale_system'),
  (const Locale('en'), l10n.localeEnglish, 'locale_en'),
  (const Locale('es'), l10n.localeSpanish, 'locale_es'),
  (const Locale('fr'), l10n.localeFrench, 'locale_fr'),   // <-- add
];
```
The third tuple element is a `Semantics` identifier (`locale_<code>`) used by
widget tests — keep the `locale_<code>` convention. Selection is persisted by
`localeProvider` (`lib/domain/providers/locale_provider.dart`); no change there.

---

## Part 3 — Exercise names (JSON asset)

Built-in exercise names are **stored in the DB as their canonical English
string** and used as identity keys (exercise history, "last performed",
auto-populate weight, personal records, frequency, cross-cycle PR comparison,
the video map). **Never translate stored names or `exercises.csv`** — translate
only at display time, keyed by the English name, with passthrough on miss (which
also leaves user-created custom exercises untouched).

### Steps

1. **Create `assets/i18n/exercise_names_<code>.json`** — a flat object mapping
   each canonical English name (exactly as in `exercises.csv`) to its
   translation:
   ```json
   {
     "Arnold Press": "Développé Arnold",
     "Air Squats": "Squats au poids du corps",
     ...
   }
   ```
   Source the 344 unique names from `exercises.csv` (first column). Use a
   fitness/gym-fluent translator; keep brand/program names (e.g. "Ab Ripper X")
   and established lift names (Clean, Snatch) as-is where appropriate.

2. **Register the language** in
   `lib/data/services/exercise_name_localizer.dart`:
   ```dart
   static const List<String> _localizedLanguages = ['es', 'fr'];   // <-- add
   ```
   English is intentionally absent (it's the canonical form → always passthrough).

That's it — `assets/i18n/` is already declared in `pubspec.yaml`, the service is
loaded at startup in `main.dart`, and display sites already call
`context.localizedExerciseName(name)`.

### Validate coverage
```bash
python3 - <<'PY'
import csv, json
names = []
with open('exercises.csv', newline='', encoding='utf-8') as f:
    r = csv.reader(f); next(r)
    for row in r:
        if row and row[0].strip() and row[0].strip() not in names:
            names.append(row[0].strip())
tr = json.load(open('assets/i18n/exercise_names_fr.json', encoding='utf-8'))
print("missing:", [n for n in names if n not in tr])
print("extra:", [k for k in tr if k not in names])
PY
```

---

## Part 4 — Verify

```bash
flutter analyze            # must be clean
flutter pub get            # refresh asset manifest (after adding the JSON)
flutter run                # switch language in-app, spot-check screens
```

Spot-check: the exercise picker + search (search matches English *and* the
localized name), workout/exercise cards, the exercise info & feedback dialogs,
and the Stats screen's "Most used" / "Personal records" lists.

---

## Translation tooling (for large volumes)

The UI ARB (~1,407 strings) and exercise names (344) are large. The approach
used for Spanish:

1. Extract the source strings to JSON (UI: key→value pairs; exercises: an array
   of names) and split into N chunks written to a scratch dir.
2. Launch N parallel translator subagents (the `Agent` tool), each translating
   one chunk and **writing its output JSON directly to disk** (keeps the bulk out
   of the main context). Give them explicit rules: keep keys byte-for-byte,
   preserve `{placeholders}` and ICU structure, use the target locale's plural
   categories, output valid UTF-8 JSON.
3. Merge the chunks programmatically, run the parity/placeholder checks above,
   then write the final `app_<code>.arb` / `exercise_names_<code>.json`.

---

## Design rationale (why two surfaces)

- **UI strings** are static and keyed by a stable slug → standard Flutter ARB /
  `gen-l10n` is the right tool.
- **Exercise names** are data that is *denormalized into stored rows* and used as
  match keys. They must round-trip as English for history/PRs to work, so they
  are translated **only for display** via `ExerciseNameLocalizer` +
  `context.localizedExerciseName(...)`. This mirrors the
  `MuscleGroup.localizedName(l10n)` / `EquipmentType.localizedName(l10n)` pattern
  (stable enum identity, localized display).

See also: `TERMINOLOGY.md` (user-facing wording) and
`DATA_STRUCTURE_v6.md` (why exercise names are identity keys).
