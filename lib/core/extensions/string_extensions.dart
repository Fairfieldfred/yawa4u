/// Extension methods for String
/// Provides convenient string manipulation and validation methods
extension StringExtensions on String {
  // ========== CASE CONVERSION ==========

  /// Capitalize first letter
  /// Example: "hello" -> "Hello"
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalize first letter of each word
  /// Example: "hello world" -> "Hello World"
  String get titleCase {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Convert to sentence case
  /// Example: "HELLO WORLD" -> "Hello world"
  String get sentenceCase {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  // ========== VALIDATION ==========

  /// Check if string is empty or contains only whitespace
  bool get isBlank => trim().isEmpty;

  /// Check if string is not blank
  bool get isNotBlank => !isBlank;

  /// Check if string is a valid number
  bool get isNumber => double.tryParse(this) != null;

  /// Check if string is a valid integer
  bool get isInteger => int.tryParse(this) != null;

  /// Check if string is a valid email (basic validation)
  bool get isEmail {
    final emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      caseSensitive: false,
    );
    return emailRegex.hasMatch(this);
  }

  /// Check if string is a valid URL
  bool get isUrl {
    final urlRegex = RegExp(
      r'^https?://[^\s/$.?#].[^\s]*$',
      caseSensitive: false,
    );
    return urlRegex.hasMatch(this);
  }

  /// Check if string contains only letters
  bool get isAlpha {
    final alphaRegex = RegExp(r'^[a-zA-Z]+$');
    return alphaRegex.hasMatch(this);
  }

  /// Check if string contains only letters and numbers
  bool get isAlphanumeric {
    final alphanumericRegex = RegExp(r'^[a-zA-Z0-9]+$');
    return alphanumericRegex.hasMatch(this);
  }

  // ========== PARSING ==========

  /// Try to parse as int, return null if invalid
  int? get toIntOrNull => int.tryParse(this);

  /// Try to parse as double, return null if invalid
  double? get toDoubleOrNull => double.tryParse(this);

  /// Try to parse as int, return default value if invalid
  int toIntOr(int defaultValue) => int.tryParse(this) ?? defaultValue;

  /// Try to parse as double, return default value if invalid
  double toDoubleOr(double defaultValue) =>
      double.tryParse(this) ?? defaultValue;

  // ========== TRUNCATION ==========

  /// Truncate string to maxLength and add ellipsis if needed
  /// Example: "Hello World".truncate(8) -> "Hello..."
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// Truncate to fit word boundaries
  /// Example: "Hello World".truncateWords(8) -> "Hello..."
  String truncateWords(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;

    final truncated = substring(0, maxLength - ellipsis.length);
    final lastSpace = truncated.lastIndexOf(' ');

    if (lastSpace > 0) {
      return '${truncated.substring(0, lastSpace)}$ellipsis';
    }

    return '$truncated$ellipsis';
  }

  // ========== REMOVAL ==========

  /// Remove all whitespace
  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');

  /// Remove all non-numeric characters
  String get removeNonNumeric => replaceAll(RegExp(r'[^0-9]'), '');

  /// Remove all non-alphanumeric characters
  String get removeNonAlphanumeric => replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

  /// Remove specific characters
  String removeAll(String pattern) => replaceAll(pattern, '');

  // ========== MANIPULATION ==========

  /// Reverse the string
  /// Example: "hello" -> "olleh"
  String get reverse => split('').reversed.join('');

  /// Repeat the string n times
  /// Example: "ha".repeat(3) -> "hahaha"
  String repeat(int times) => this * times;

  /// Wrap string with prefix and suffix
  /// Example: "hello".wrap('(', ')') -> "(hello)"
  String wrap(String prefix, [String? suffix]) {
    return '$prefix$this${suffix ?? prefix}';
  }

  /// Quote the string
  /// Example: "hello".quote() -> '"hello"'
  String quote([String quoteChar = '"']) => wrap(quoteChar);

  // ========== COMPARISON ==========

  /// Case-insensitive equality check
  bool equalsIgnoreCase(String other) {
    return toLowerCase() == other.toLowerCase();
  }

  /// Check if string contains substring (case-insensitive)
  bool containsIgnoreCase(String substring) {
    return toLowerCase().contains(substring.toLowerCase());
  }

  /// Check if string starts with prefix (case-insensitive)
  bool startsWithIgnoreCase(String prefix) {
    return toLowerCase().startsWith(prefix.toLowerCase());
  }

  /// Check if string ends with suffix (case-insensitive)
  bool endsWithIgnoreCase(String suffix) {
    return toLowerCase().endsWith(suffix.toLowerCase());
  }

  // ========== EXTRACTION ==========

  /// Extract numbers from string
  /// Example: "abc123def456" -> ["123", "456"]
  List<String> extractNumbers() {
    final regex = RegExp(r'\d+');
    return regex.allMatches(this).map((m) => m.group(0)!).toList();
  }

  /// Get first n characters
  String first(int n) {
    if (n >= length) return this;
    return substring(0, n);
  }

  /// Get last n characters
  String last(int n) {
    if (n >= length) return this;
    return substring(length - n);
  }

  // ========== UTILITY ==========

  /// Get initials from a name
  /// Example: "John Doe" -> "JD"
  String get initials {
    final words = trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '';
    if (words.length == 1) {
      return words[0].isNotEmpty ? words[0][0].toUpperCase() : '';
    }
    return words
        .take(2)
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join('');
  }

  /// Count occurrences of a substring
  int count(String substring) {
    if (substring.isEmpty) return 0;
    return split(substring).length - 1;
  }

  /// Check if string is numeric (integer or decimal)
  bool get isNumeric {
    if (isEmpty) return false;
    return double.tryParse(this) != null;
  }

  /// Pluralize a word based on count
  /// Example: "item".pluralize(1) -> "item", "item".pluralize(2) -> "items"
  String pluralize(int count, {String? plural}) {
    if (count == 1) return this;
    return plural ?? '${this}s';
  }

  /// Convert snake_case to camelCase
  /// Example: "hello_world" -> "helloWorld"
  String get snakeToCamel {
    final parts = split('_');
    if (parts.length == 1) return this;
    return parts.first +
        parts.skip(1).map((part) => part.capitalize).join('');
  }

  /// Convert camelCase to snake_case
  /// Example: "helloWorld" -> "hello_world"
  String get camelToSnake {
    return replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    );
  }

  /// Convert to slug (URL-friendly)
  /// Example: "Hello World!" -> "hello-world"
  String get toSlug {
    return toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'[\s_]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  // ========== RIR-SPECIFIC ==========

  /// Check if string is in RIR format (e.g., "2 RIR")
  bool get isRIR {
    final rirPattern = RegExp(r'^\d+\s*RIR$', caseSensitive: false);
    return rirPattern.hasMatch(trim().toUpperCase());
  }

  /// Extract RIR value from string
  /// Example: "2 RIR" -> 2
  int? get rirValue {
    if (!isRIR) return null;
    final match = RegExp(r'\d+').firstMatch(this);
    if (match == null) return null;
    return int.tryParse(match.group(0)!);
  }

  // ========== MUSCLE GROUP HELPERS ==========

  /// Normalize muscle group name from CSV
  /// Example: "Chest " -> "Chest", "BACK" -> "Back"
  String get normalizeMuscleGroup => trim().sentenceCase;

  /// Normalize equipment type from CSV
  /// Example: "Bodyweight Loadable " -> "Bodyweight Loadable"
  String get normalizeEquipmentType => trim().titleCase;

  // ========== DEFAULT VALUES ==========

  /// Return default value if string is empty or null
  String orDefault(String defaultValue) {
    return isBlank ? defaultValue : this;
  }

  /// Return null if string is empty
  String? get orNull => isBlank ? null : this;
}

/// Extension methods for nullable String
extension NullableStringExtensions on String? {
  /// Check if string is null or blank
  bool get isNullOrBlank {
    return this == null || this!.isBlank;
  }

  /// Check if string is not null and not blank
  bool get isNotNullOrBlank => !isNullOrBlank;

  /// Get value or default if null or blank
  String orDefault(String defaultValue) {
    return isNullOrBlank ? defaultValue : this!;
  }

  /// Get value or empty string if null
  String get orEmpty => this ?? '';
}
