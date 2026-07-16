import 'dart:convert';

/// Display-ready content for the live rest-timer notification on the lock
/// screen: exercise name, next-set line, and action button labels.
///
/// All strings are localized by the UI layer before being passed in. The
/// background isolate that reposts the notification after a +/-/skip action
/// has no BuildContext to localize with, so this object round-trips through
/// SharedPreferences as JSON.
class LiveSetInfo {
  final String title;
  final String body;
  final String addLabel;
  final String subtractLabel;
  final String skipLabel;

  const LiveSetInfo({
    required this.title,
    required this.body,
    required this.addLabel,
    required this.subtractLabel,
    required this.skipLabel,
  });

  String toJsonString() => jsonEncode(<String, String>{
    'title': title,
    'body': body,
    'add': addLabel,
    'subtract': subtractLabel,
    'skip': skipLabel,
  });

  static LiveSetInfo? fromJsonString(String? source) {
    if (source == null || source.isEmpty) return null;
    try {
      final decoded = jsonDecode(source);
      if (decoded is! Map<String, dynamic>) return null;
      return LiveSetInfo(
        title: decoded['title'] as String? ?? '',
        body: decoded['body'] as String? ?? '',
        addLabel: decoded['add'] as String? ?? '+30s',
        subtractLabel: decoded['subtract'] as String? ?? '-30s',
        skipLabel: decoded['skip'] as String? ?? 'Skip',
      );
    } on FormatException {
      return null;
    }
  }
}
