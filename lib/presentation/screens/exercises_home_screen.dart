import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/enums.dart';
import '../../data/models/exercise.dart';
import '../../data/models/exercise_set.dart';
import '../../data/models/workout.dart';
import '../../domain/providers/mesocycle_providers.dart';
import '../../domain/providers/repository_providers.dart';
import '../../domain/providers/workout_providers.dart';

/// Exercises library home screen
class ExercisesHomeScreen extends ConsumerWidget {
  const ExercisesHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMesocycle = ref.watch(currentMesocycleProvider);

    if (currentMesocycle == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Exercises')),
        body: const Center(child: Text('No active mesocycle')),
      );
    }

    // Check loading state of the base provider
    final workoutsState = ref.watch(workoutsProvider);
    if (workoutsState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Get workouts for the current mesocycle
    final workouts = ref.watch(
      workoutsByMesocycleProvider(currentMesocycle.id),
    );

    // Find the first incomplete workout
    final activeWorkout = workouts.cast<Workout?>().firstWhere(
      (w) => w?.status == WorkoutStatus.incomplete,
      orElse: () => null,
    );

    if (activeWorkout == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Exercises')),
        body: const Center(child: Text('All workouts completed!')),
      );
    }

    return _WorkoutSessionView(
      key: ValueKey(activeWorkout.id), // Rebuild if workout changes
      workout: activeWorkout,
    );
  }
}

class _WorkoutSessionView extends ConsumerStatefulWidget {
  final Workout workout;

  const _WorkoutSessionView({required Key key, required this.workout})
    : super(key: key);

  @override
  ConsumerState<_WorkoutSessionView> createState() =>
      _WorkoutSessionViewState();
}

class _WorkoutSessionViewState extends ConsumerState<_WorkoutSessionView> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workout = widget.workout;
    final exercises = workout.exercises;

    return Scaffold(
      appBar: AppBar(title: Text(workout.displayName), centerTitle: true),
      body: Column(
        children: [
          // Progress Indicator
          LinearProgressIndicator(
            value: (exercises.isEmpty)
                ? 0
                : (_currentPage + 1) / exercises.length,
            backgroundColor: Theme.of(context).dividerColor,
          ),

          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: exercises.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return _ExercisePage(
                  workout: workout,
                  exercise: exercises[index],
                  exerciseIndex: index,
                );
              },
            ),
          ),

          _BottomActionBar(
            workout: workout,
            currentPage: _currentPage,
            totalPages: exercises.length,
            onNext: _goToNextPage,
          ),
        ],
      ),
    );
  }

  void _goToNextPage() {
    if (_currentPage < widget.workout.exercises.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishWorkout();
    }
  }

  void _finishWorkout() {
    final workoutRepo = ref.read(workoutRepositoryProvider);
    workoutRepo.markAsCompleted(widget.workout.id);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Workout Completed!')));
  }
}

class _ExercisePage extends ConsumerWidget {
  final Workout workout;
  final Exercise exercise;
  final int exerciseIndex;

  const _ExercisePage({
    required this.workout,
    required this.exercise,
    required this.exerciseIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            exercise.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '${exercise.muscleGroup.name} • ${exercise.sets.length} Sets',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 32),

          // Sets List
          ...exercise.sets.asMap().entries.map((entry) {
            final setIndex = entry.key;
            final set = entry.value;
            return _SetRow(
              workout: workout,
              exerciseIndex: exerciseIndex,
              setIndex: setIndex,
              set: set,
            );
          }),
        ],
      ),
    );
  }
}

class _SetRow extends ConsumerStatefulWidget {
  final Workout workout;
  final int exerciseIndex;
  final int setIndex;
  final ExerciseSet set;

  const _SetRow({
    required this.workout,
    required this.exerciseIndex,
    required this.setIndex,
    required this.set,
  });

  @override
  ConsumerState<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends ConsumerState<_SetRow> {
  late TextEditingController _weightController;
  late TextEditingController _repsController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: _formatWeight(widget.set.weight),
    );
    _repsController = TextEditingController(text: widget.set.reps);
  }

  @override
  void didUpdateWidget(covariant _SetRow oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.set.weight != widget.set.weight) {
      final text = _formatWeight(widget.set.weight);
      // Avoid overwriting if the user is typing a decimal point or trailing zeros
      // This is a heuristic: if the parsed value of current text equals the new weight,
      // don't overwrite.
      final currentVal = double.tryParse(_weightController.text);
      if (currentVal != widget.set.weight) {
        if (_weightController.text != text) {
          _weightController.text = text;
        }
      }
    }
    if (oldWidget.set.reps != widget.set.reps) {
      if (_repsController.text != widget.set.reps) {
        _repsController.text = widget.set.reps;
      }
    }
  }

  String _formatWeight(double? weight) {
    if (weight == null) return '';
    // If it's an integer (e.g. 10.0), return "10"
    if (weight % 1 == 0) return weight.toInt().toString();
    // Otherwise return as is (e.g. 10.5)
    return weight.toString();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _updateSet() {
    final weightText = _weightController.text;
    final repsText = _repsController.text;

    final double? weight = double.tryParse(weightText);
    // Reps is a string in the model (to support "2 RIR" etc), but usually just a number.
    // The user asked for text entry, so we pass the string directly.

    final updatedSet = widget.set.copyWith(weight: weight, reps: repsText);

    // Only update if changed
    if (updatedSet == widget.set) return;

    final workoutRepo = ref.read(workoutRepositoryProvider);
    final updatedExercise = widget.workout.exercises[widget.exerciseIndex]
        .updateSet(widget.setIndex, updatedSet);
    final updatedWorkout = widget.workout.updateExercise(
      widget.exerciseIndex,
      updatedExercise,
    );

    workoutRepo.update(updatedWorkout);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.set.isLogged
              ? Colors.green.withValues(alpha: 0.5)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Set Number
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Text(
              '${widget.set.setNumber}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),

          // Weight and Reps Inputs
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Weight Input
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                      hintText: '0',
                      border: UnderlineInputBorder(),
                    ),
                    onChanged: (_) => _updateSet(),
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'lbs',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),

                const SizedBox(width: 24),

                // Reps Input
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: _repsController,
                    keyboardType: TextInputType.text, // Allow "10" or "2 RIR"
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                      hintText: '0',
                      border: UnderlineInputBorder(),
                    ),
                    onChanged: (_) => _updateSet(),
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'reps',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Checkbox
          IconButton(
            onPressed: () => _toggleSetComplete(),
            icon: Icon(
              widget.set.isLogged ? Icons.check_circle : Icons.circle_outlined,
              color: widget.set.isLogged ? Colors.green : Colors.grey,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleSetComplete() {
    final workoutRepo = ref.read(workoutRepositoryProvider);

    final updatedSet = widget.set.copyWith(isLogged: !widget.set.isLogged);
    final updatedExercise = widget.workout.exercises[widget.exerciseIndex]
        .updateSet(widget.setIndex, updatedSet);
    final updatedWorkout = widget.workout.updateExercise(
      widget.exerciseIndex,
      updatedExercise,
    );

    workoutRepo.update(updatedWorkout);
  }
}

class _BottomActionBar extends StatelessWidget {
  final Workout workout;
  final int currentPage;
  final int totalPages;
  final VoidCallback onNext;

  const _BottomActionBar({
    required this.workout,
    required this.currentPage,
    required this.totalPages,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final currentExercise = workout.exercises[currentPage];
    final isExerciseCompleted = currentExercise.isCompleted;
    final isLastPage = currentPage == totalPages - 1;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          if (isExerciseCompleted)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onNext,
                icon: Icon(isLastPage ? Icons.check : Icons.arrow_forward),
                label: Text(isLastPage ? 'Finish Workout' : 'Next Exercise'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLastPage ? Colors.green : Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Optional: Maybe a "Mark Exercise Done" button here if they want to skip logging sets?
                  // For now, let's just allow moving to next even if not fully logged,
                  // or we can force them to log.
                  // The user said "row with either a checkmark fo rfinished, or a next arrow".
                  // This implies if NOT finished, show checkmark.
                  // If finished, show next arrow.

                  // But "Checkmark" usually means "Mark as Done".
                  // If I click Checkmark, it should probably mark all sets as logged?
                  // Or just visually mark exercise as done?

                  // Let's assume "Checkmark" means "I am done with this exercise".
                  onNext();
                },
                icon: const Icon(Icons.check),
                label: const Text('Done'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
