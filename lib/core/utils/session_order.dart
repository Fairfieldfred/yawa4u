import '../../data/models/exercise.dart';
import '../../data/models/session.dart';
import '../constants/enums.dart';

/// Performed-order sort for the Workout home screen card list.
///
/// Section A of `DESIGN_OPPORTUNITIES.md` calls for the day's sessions
/// to render in three buckets:
///
///   1. **Completed** — sorted by `completedDate` ascending. The user
///      reads top-to-bottom in the order they finished things.
///   2. **In-progress** — sorted by earliest `startTime` ascending.
///      Sessions with a `startTime` but no `completedDate` count as
///      in-progress; for strength sessions, having any logged set also
///      counts.
///   3. **Planned** — sorted by `scheduledDate` ascending, then by id
///      (a stable proxy for creation order) when `scheduledDate` is
///      null on both sides.
///
/// Pure function — easy to unit-test without standing up Drift.
List<Session> sortByPerformedOrder(Iterable<Session> sessions) {
  final completed = <Session>[];
  final inProgress = <Session>[];
  final planned = <Session>[];

  for (final s in sessions) {
    if (_isCompleted(s)) {
      completed.add(s);
    } else if (_isInProgress(s)) {
      inProgress.add(s);
    } else {
      planned.add(s);
    }
  }

  completed.sort(_byCompletedDateAsc);
  inProgress.sort(_byStartTimeAsc);
  planned.sort(_byScheduledDateThenId);

  return [...completed, ...inProgress, ...planned];
}

bool _isCompleted(Session s) => s.status == WorkoutStatus.completed;

bool _isInProgress(Session s) {
  if (_isCompleted(s)) return false;
  if (s.startTime != null && s.completedDate == null) return true;
  if (s is StrengthSession) {
    for (final Exercise e in s.exercises) {
      for (final set in e.sets) {
        if (set.isLogged) return true;
      }
    }
  }
  return false;
}

int _byCompletedDateAsc(Session a, Session b) {
  final ad = a.completedDate;
  final bd = b.completedDate;
  if (ad == null && bd == null) return a.id.compareTo(b.id);
  if (ad == null) return 1;
  if (bd == null) return -1;
  return ad.compareTo(bd);
}

int _byStartTimeAsc(Session a, Session b) {
  final at = a.startTime;
  final bt = b.startTime;
  if (at == null && bt == null) return a.id.compareTo(b.id);
  if (at == null) return 1;
  if (bt == null) return -1;
  return at.compareTo(bt);
}

int _byScheduledDateThenId(Session a, Session b) {
  final ad = a.scheduledDate;
  final bd = b.scheduledDate;
  if (ad == null && bd == null) return a.id.compareTo(b.id);
  if (ad == null) return 1;
  if (bd == null) return -1;
  final cmp = ad.compareTo(bd);
  return cmp != 0 ? cmp : a.id.compareTo(b.id);
}
