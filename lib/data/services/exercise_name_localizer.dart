import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

/// Provides display-time translation of built-in exercise names.
///
/// Exercise names are stored in the database as their canonical English
/// strings and are used as identity keys for history, personal records, and
/// the video map. They must never be translated at the data layer. This
/// service translates them only for display, keyed by the canonical English
/// name, and falls back to the original string on any miss — which means
/// user-created custom exercises (absent from the maps) pass through unchanged.
///
/// Translations live in `assets/i18n/exercise_names_<languageCode>.json` as a
/// flat `{ "English name": "Localized name" }` object. English has no map
/// (it is the canonical form), so lookups for `en` always pass through.
class ExerciseNameLocalizer {
  static final ExerciseNameLocalizer _instance = ExerciseNameLocalizer._internal();
  factory ExerciseNameLocalizer() => _instance;
  ExerciseNameLocalizer._internal();

  final _log = Logger('ExerciseNameLocalizer');

  /// Language codes that ship a translation asset. English is canonical and
  /// intentionally omitted (it always passes through).
  static const List<String> _localizedLanguages = ['es'];

  final Map<String, Map<String, String>> _maps = {};
  bool _loaded = false;

  /// Loads every available translation map into memory.
  ///
  /// Safe to call multiple times; subsequent calls are no-ops. Designed to be
  /// awaited once at app startup so display-time lookups are synchronous.
  Future<void> load() async {
    if (_loaded) return;
    for (final lang in _localizedLanguages) {
      try {
        final raw = await rootBundle.loadString('assets/i18n/exercise_names_$lang.json');
        final decoded = json.decode(raw) as Map<String, dynamic>;
        _maps[lang] = decoded.map((k, v) => MapEntry(k, v as String));
        _log.info('Loaded ${_maps[lang]!.length} exercise names for "$lang"');
      } catch (e, stackTrace) {
        // A missing or malformed map must not break the app — English
        // passthrough is an acceptable degradation.
        _log.warning('Could not load exercise names for "$lang"', e, stackTrace);
      }
    }
    _loaded = true;
  }

  /// Returns the localized display name for [englishName] in [languageCode],
  /// or [englishName] itself when no translation exists.
  ///
  /// Never throws and never returns null, so it is safe to call from any
  /// `build` method without guarding on load state.
  String localize(String englishName, String languageCode) {
    final map = _maps[languageCode];
    if (map == null) return englishName;
    return map[englishName] ?? englishName;
  }

  /// Clears cached maps. For testing only.
  void clear() {
    _maps.clear();
    _loaded = false;
  }
}

/// Display-time helper for localizing built-in exercise names.
///
/// Kept as a dedicated, single-member extension (rather than folded into the
/// app's larger `BuildContext` extension) so importing it never collides with
/// other extensions — notably go_router's `BuildContext.push`.
extension ExerciseNameLocalizationX on BuildContext {
  /// Localized display name for a built-in exercise.
  ///
  /// Translates the canonical English [englishName] for the active locale,
  /// falling back to [englishName] when no translation exists — which leaves
  /// user-created custom exercises untouched. Display-only: the stored name
  /// stays English so exercise history and personal records keep matching.
  String localizedExerciseName(String englishName) =>
      ExerciseNameLocalizer().localize(englishName, Localizations.localeOf(this).languageCode);
}
