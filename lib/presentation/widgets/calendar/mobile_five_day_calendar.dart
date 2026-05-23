import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/date_helpers.dart';
import '../../../domain/providers/calendar_providers.dart';
import 'calendar_drag_data.dart';
import 'desktop_calendar_day_cell.dart';

/// Number of virtual pages in the PageView. Large enough to scroll
/// years in either direction without hitting a boundary.
const _kTotalPages = 10000;

/// The page index that maps to [_referenceDate] (today at init time).
const _kCenterPage = 5000;

/// A horizontally scrollable 5-day calendar view for mobile.
///
/// Uses [PageView.builder] with `viewportFraction: 0.2` so five day
/// columns are visible simultaneously. Each column is a
/// [DesktopCalendarDayCell] — preserving drag-drop, reorder, and
/// add-exercise functionality.
///
/// The initial view positions today as the 2nd visible column
/// (index 1 of 0-4). Swiping shifts one day at a time.
class MobileFiveDayCalendar extends StatefulWidget {
  final DateTime? selectedDay;
  final DateTime focusedDay;
  final Map<DateTime, CalendarDayData> dataMap;
  final Map<int, Color> periodColors;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<DateTime> onDayLongPressed;
  final ValueChanged<DateTime> onFocusedDayChanged;
  final void Function(CalendarDragData data, DateTime targetDate)? onExerciseDropped;
  final void Function(int oldIndex, int newIndex, DateTime targetDate)? onExerciseReordered;
  final void Function(int periodNumber, int dayNumber, DateTime date)? onAddExercise;
  final String? selectedExerciseId;
  final ValueChanged<String?>? onExerciseSelected;

  const MobileFiveDayCalendar({
    super.key,
    required this.selectedDay,
    required this.focusedDay,
    required this.dataMap,
    required this.periodColors,
    required this.onDaySelected,
    required this.onDayLongPressed,
    required this.onFocusedDayChanged,
    this.onExerciseDropped,
    this.onExerciseReordered,
    this.onAddExercise,
    this.selectedExerciseId,
    this.onExerciseSelected,
  });

  @override
  State<MobileFiveDayCalendar> createState() => _MobileFiveDayCalendarState();
}

class _MobileFiveDayCalendarState extends State<MobileFiveDayCalendar> {
  late final DateTime _referenceDate;
  late final PageController _pageController;

  /// Tracks the current center page so the header can show the visible
  /// date range without waiting for a full rebuild.
  int _currentCenterPage = _kCenterPage + 1;

  @override
  void initState() {
    super.initState();
    _referenceDate = DateHelpers.stripTime(DateTime.now());

    // Initial page = _kCenterPage + 1 so the centered (3rd) column is
    // tomorrow, making the 5 visible columns:
    // [yesterday, today, tomorrow, +2, +3]
    // → today sits at position 2 (0-indexed index 1).
    _currentCenterPage = _kCenterPage + 1;
    _pageController = PageController(
      initialPage: _currentCenterPage,
      viewportFraction: 0.2,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MobileFiveDayCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // When the parent resets focusedDay (e.g. "Go to today" button),
    // animate the PageView to center on that date.
    if (!DateHelpers.isSameDay(
      widget.focusedDay,
      oldWidget.focusedDay,
    )) {
      final targetPage = _pageForDate(widget.focusedDay);
      // Offset by +1 so the focused day lands in the 2nd column.
      _pageController.animateToPage(
        targetPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Converts a [DateTime] to the corresponding PageView page index.
  int _pageForDate(DateTime date) {
    final stripped = DateHelpers.stripTime(date);
    return _kCenterPage + stripped.difference(_referenceDate).inDays;
  }

  /// Converts a page index to the corresponding [DateTime].
  DateTime _dateForPage(int page) {
    return _referenceDate.add(Duration(days: page - _kCenterPage));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        _buildDayOfWeekLabels(context),
        Expanded(child: _buildPageView(context)),
      ],
    );
  }

  /// Header showing the visible date range and navigation chevrons.
  Widget _buildHeader(BuildContext context) {
    // The 5 visible pages are [center-2 .. center+2].
    // Today is at center-1 (the 2nd column).
    final leftDate = _dateForPage(_currentCenterPage - 2);
    final rightDate = _dateForPage(_currentCenterPage + 2);

    final DateFormat headerFormat = DateFormat('MMM d');
    final String rangeText;
    if (leftDate.year == rightDate.year) {
      if (leftDate.month == rightDate.month) {
        rangeText =
            '${headerFormat.format(leftDate)} - ${rightDate.day}, '
            '${rightDate.year}';
      } else {
        rangeText =
            '${headerFormat.format(leftDate)} - '
            '${headerFormat.format(rightDate)}, ${rightDate.year}';
      }
    } else {
      rangeText =
          '${DateHelpers.shortDate.format(leftDate)} - '
          '${DateHelpers.shortDate.format(rightDate)}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {
              _pageController.animateToPage(
                _currentCenterPage - 1,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
              );
            },
          ),
          Text(
            rangeText,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {
              _pageController.animateToPage(
                _currentCenterPage + 1,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
              );
            },
          ),
        ],
      ),
    );
  }

  /// Row of abbreviated day-of-week labels above the scrollable area.
  Widget _buildDayOfWeekLabels(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
      fontWeight: FontWeight.w500,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: List.generate(5, (i) {
          // Visible pages: [center-2, center-1, center, center+1, center+2]
          final date = _dateForPage(_currentCenterPage - 2 + i);
          return Expanded(
            child: Center(
              child: Text(
                DateHelpers.dayNameShort.format(date),
                style: style,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPageView(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: _kTotalPages,
      onPageChanged: (page) {
        setState(() {
          _currentCenterPage = page;
        });

        // If the user scrolls far from the data window center,
        // notify the parent to reload data for the new date range.
        final centerDate = _dateForPage(page);
        final diff = centerDate
            .difference(
              DateHelpers.stripTime(widget.focusedDay),
            )
            .inDays
            .abs();
        if (diff > 21) {
          widget.onFocusedDayChanged(centerDate);
        }
      },
      itemBuilder: (context, pageIndex) {
        final date = _dateForPage(pageIndex);
        final strippedDate = DateHelpers.stripTime(date);
        final dayData = widget.dataMap[strippedDate];
        final isToday = DateHelpers.isSameDay(date, DateTime.now());
        final isSelected = widget.selectedDay != null && DateHelpers.isSameDay(date, widget.selectedDay!);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 4),
          child: DesktopCalendarDayCell(
            date: date,
            dayData: dayData,
            periodColors: widget.periodColors,
            isToday: isToday,
            isSelected: isSelected,
            selectedExerciseId: widget.selectedExerciseId,
            onTap: (selectedDay) => widget.onDaySelected(selectedDay),
            onLongPress: () => widget.onDayLongPressed(date),
            onExerciseSelected: widget.onExerciseSelected,
            onExerciseDropped: widget.onExerciseDropped,
            onExerciseReordered: widget.onExerciseReordered,
            onAddExercise: widget.onAddExercise,
          ),
        );
      },
    );
  }
}
