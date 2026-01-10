import 'package:intl/intl.dart';

/// Date and time utility functions for Yawa4u app
class DateHelpers {
  DateHelpers._();

  // ========== DATE FORMATTERS ==========

  /// Format: "Monday, January 1, 2025"
  static final DateFormat fullDate = DateFormat('EEEE, MMMM d, yyyy');

  /// Format: "January 1, 2025"
  static final DateFormat mediumDate = DateFormat('MMMM d, yyyy');

  /// Format: "Jan 1, 2025"
  static final DateFormat shortDate = DateFormat('MMM d, yyyy');

  /// Format: "01/31/2025"
  static final DateFormat numericDate = DateFormat('MM/dd/yyyy');

  /// Format: "2025-01-31" (ISO 8601, sortable)
  static final DateFormat isoDate = DateFormat('yyyy-MM-dd');

  /// Format: "2:30 PM"
  static final DateFormat time = DateFormat('h:mm a');

  /// Format: "14:30"
  static final DateFormat time24 = DateFormat('HH:mm');

  /// Format: "Jan 1, 2025 at 2:30 PM"
  static final DateFormat dateTime = DateFormat('MMM d, yyyy \'at\' h:mm a');

  /// Format: "Monday"
  static final DateFormat dayName = DateFormat('EEEE');

  /// Format: "Mon"
  static final DateFormat dayNameShort = DateFormat('EEE');

  /// Format: "January"
  static final DateFormat monthName = DateFormat('MMMM');

  /// Format: "Jan"
  static final DateFormat monthNameShort = DateFormat('MMM');

  // ========== DATE CALCULATIONS ==========

  /// Get today's date at midnight (time stripped)
  static DateTime get today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Get tomorrow's date at midnight
  static DateTime get tomorrow {
    return today.add(const Duration(days: 1));
  }

  /// Get yesterday's date at midnight
  static DateTime get yesterday {
    return today.subtract(const Duration(days: 1));
  }

  /// Strip time from a DateTime, returning midnight of that day
  static DateTime stripTime(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Check if two dates are on the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Check if a date is today
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  /// Check if a date is tomorrow
  static bool isTomorrow(DateTime date) {
    return isSameDay(date, tomorrow);
  }

  /// Check if a date is yesterday
  static bool isYesterday(DateTime date) {
    return isSameDay(date, yesterday);
  }

  /// Check if a date is in the past
  static bool isPast(DateTime date) {
    return date.isBefore(today);
  }

  /// Check if a date is in the future
  static bool isFuture(DateTime date) {
    return date.isAfter(today);
  }

  /// Get the number of days between two dates
  static int daysBetween(DateTime start, DateTime end) {
    final startDate = stripTime(start);
    final endDate = stripTime(end);
    return endDate.difference(startDate).inDays;
  }

  /// Get the number of periods between two dates
  static int periodsBetween(DateTime start, DateTime end, int daysPerPeriod) {
    return (daysBetween(start, end) / daysPerPeriod).ceil();
  }

  // ========== DATE ADDITIONS ==========

  /// Add days to a date
  static DateTime addDays(DateTime date, int days) {
    return date.add(Duration(days: days));
  }

  /// Add periods to a date
  static DateTime addPeriods(DateTime date, int periods, int daysPerPeriod) {
    return date.add(Duration(days: periods * daysPerPeriod));
  }

  /// Add months to a date (handles month boundaries correctly)
  static DateTime addMonths(DateTime date, int months) {
    final newMonth = date.month + months;
    final yearOffset = (newMonth - 1) ~/ 12;
    final month = ((newMonth - 1) % 12) + 1;
    final year = date.year + yearOffset;

    // Handle day overflow (e.g., Jan 31 + 1 month = Feb 28/29)
    final maxDay = DateTime(year, month + 1, 0).day;
    final day = date.day > maxDay ? maxDay : date.day;

    return DateTime(
      year,
      month,
      day,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }

  // ========== TRAINING CYCLE HELPERS ==========

  /// Calculate the end date of a trainingCycle given start date and duration
  /// Duration is in periods, each period has daysPerPeriod days
  static DateTime getTrainingCycleEndDate(
    DateTime startDate,
    int periods,
    int daysPerPeriod,
  ) {
    return addPeriods(
      startDate,
      periods,
      daysPerPeriod,
    ).subtract(const Duration(days: 1));
  }

  /// Get the date for a specific period and day in a trainingCycle
  /// Period number: 1-based (1 = first period)
  /// Day number: 1-based (1 = first day of period)
  static DateTime getWorkoutDate(
    DateTime trainingCycleStart,
    int periodNumber,
    int dayNumber,
    int daysPerPeriod,
  ) {
    final periodOffset = periodNumber - 1; // Convert to 0-based
    final daysOffset = (periodOffset * daysPerPeriod) + (dayNumber - 1);
    return addDays(trainingCycleStart, daysOffset);
  }

  /// Get the current period number in a trainingCycle (1-based)
  /// Returns null if date is before trainingCycle start
  static int? getCurrentPeriod(
    DateTime trainingCycleStart,
    DateTime date,
    int daysPerPeriod,
  ) {
    if (date.isBefore(trainingCycleStart)) return null;
    final days = daysBetween(trainingCycleStart, date);
    return (days ~/ daysPerPeriod) + 1;
  }

  // ========== RELATIVE DATE STRINGS ==========

  /// Get a relative date string (e.g., "Today", "Yesterday", "2 days ago")
  static String getRelativeDateString(DateTime date) {
    if (isToday(date)) return 'Today';
    if (isYesterday(date)) return 'Yesterday';
    if (isTomorrow(date)) return 'Tomorrow';

    final days = daysBetween(date, today);

    if (days.abs() < 7) {
      if (days > 0) {
        return '$days ${days == 1 ? 'day' : 'days'} ago';
      } else {
        return 'In ${days.abs()} ${days.abs() == 1 ? 'day' : 'days'}';
      }
    }

    final weeks = (days / 7).floor();
    if (weeks.abs() < 4) {
      if (weeks > 0) {
        return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
      } else {
        return 'In ${weeks.abs()} ${weeks.abs() == 1 ? 'week' : 'weeks'}';
      }
    }

    // For dates further away, show the actual date
    return shortDate.format(date);
  }

  /// Get "Last performed" string for exercises
  /// Example: "Last performed 10/31/2025"
  static String getLastPerformedString(DateTime? date) {
    if (date == null) return '';
    return 'Last performed ${numericDate.format(date)}';
  }

  // ========== DURATION FORMATTING ==========

  /// Format a duration in seconds to a readable string
  /// Example: "1h 23m 45s", "5m 30s", "45s"
  static String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    final parts = <String>[];
    if (hours > 0) parts.add('${hours}h');
    if (minutes > 0) parts.add('${minutes}m');
    if (secs > 0 || parts.isEmpty) parts.add('${secs}s');

    return parts.join(' ');
  }

  /// Format a Duration object to a readable string
  static String formatDurationObject(Duration duration) {
    return formatDuration(duration.inSeconds);
  }

  // ========== EXPORT/IMPORT FILENAME ==========

  /// Generate filename for export with current date
  /// Example: "yawa4u_backup_2025-01-31.json"
  static String getExportFilename({String prefix = 'yawa4u_backup'}) {
    final dateStr = isoDate.format(DateTime.now());
    return '${prefix}_$dateStr.json';
  }

  // ========== VALIDATION ==========

  /// Check if a date is valid for a trainingCycle start (not in the past)
  static bool isValidTrainingCycleStartDate(DateTime date) {
    return !isPast(date) || isToday(date);
  }

  /// Check if a date range is valid (end after start)
  static bool isValidDateRange(DateTime start, DateTime end) {
    return end.isAfter(start) || isSameDay(start, end);
  }
}
