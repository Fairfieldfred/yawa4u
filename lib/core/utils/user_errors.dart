/// Maps raw exceptions + DB errors into concise, user-friendly strings.
///
/// Use this at every `catch (e)` site that surfaces into a SnackBar /
/// dialog / inline error — so users never see Dart exception stack
/// fragments. Keep the strings short, actionable, and tense-neutral
/// (works for both "save" and "load" contexts).
///
/// The mapping is deliberately coarse. If a specific error needs bespoke
/// copy, handle it at the call site and pass a [context] string that wins
/// over the generic mapping.
///
/// **Localization note:** Localized equivalents of every message below are
/// available in `AppLocalizations`:
///   - [userErrorCouldnt]  — "Couldn't {context} — {message}"
///   - [userErrorNetwork]  — network error
///   - [userErrorBadState] — state error
///   - [userErrorPermission] — permission denied
///   - [userErrorConflict] — data conflict
///   - [userErrorNotFound] — not found
///   - [userErrorGeneric]  — generic fallback
///
/// This class does not accept `BuildContext`, so it returns hard-coded
/// English strings. Call sites that have a `BuildContext` available may
/// prefer using `AppLocalizations` directly for full l10n support.
class UserErrors {
  const UserErrors._();

  /// Turn an arbitrary error into a short user-facing phrase.
  ///
  /// [context] is an optional verb phrase the caller can supply
  /// ("Save session", "Load stats", "Delete cycle"). Appears as the
  /// "Couldn't {context}" prefix when set.
  static String describe(Object error, {String? context}) {
    final message = _classify(error);
    if (context == null || context.trim().isEmpty) return message;
    if (message.startsWith('Couldn\'t')) return message;
    return "Couldn't $context — $message";
  }

  /// Best-effort user-facing message based on the error shape.
  static String _classify(Object error) {
    final raw = error.toString();
    final lower = raw.toLowerCase();

    if (_looksNetwork(lower)) {
      return 'Check your connection and try again.';
    }

    if (error is StateError) {
      // Usually "Bad state: …" from Drift / futures completing twice.
      return 'Something got into a bad state. Try again.';
    }

    if (_looksPermission(lower)) {
      return 'Permission was denied. Open Settings to grant access.';
    }

    if (_looksDbConstraint(lower)) {
      return 'That change conflicts with existing data.';
    }

    if (_looksNotFound(lower)) {
      return 'Not found — it may have been deleted.';
    }

    // Generic fallback. Deliberately terse + non-accusatory.
    return 'Something went wrong. Try again in a moment.';
  }

  static bool _looksNetwork(String lower) {
    return lower.contains('socket') ||
        lower.contains('connection refused') ||
        lower.contains('host lookup') ||
        lower.contains('network is unreachable') ||
        lower.contains('timeout') ||
        lower.contains('no internet');
  }

  static bool _looksPermission(String lower) {
    return lower.contains('permission') || lower.contains('unauthoriz') || lower.contains('authoriz');
  }

  static bool _looksDbConstraint(String lower) {
    return lower.contains('unique constraint') ||
        lower.contains('foreign key constraint') ||
        lower.contains('not null constraint');
  }

  static bool _looksNotFound(String lower) {
    return lower.contains('no element') || lower.contains('not found') || lower.contains('does not exist');
  }
}
