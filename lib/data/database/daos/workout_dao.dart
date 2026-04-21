// WorkoutDao removed in Phase 6d — the underlying `workouts` table
// was dropped in the v6 migration. Strength sessions now live in the
// `sessions` table and are read/written via [SessionDao] /
// [SessionRepository]. [WorkoutRepository] remains as a facade that
// exposes the legacy Workout-shaped API over that session path.
//
// This file is kept as an empty stub so that any stray import of
// `workout_dao.dart` (e.g. from a `package:yawa4u/.../daos.dart`
// export) compiles cleanly. Run
//   `dart run build_runner build --delete-conflicting-outputs`
// to have build_runner delete the orphaned `workout_dao.g.dart`.
