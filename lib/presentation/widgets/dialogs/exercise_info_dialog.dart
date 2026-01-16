import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../core/constants/enums.dart';
import '../../../core/constants/equipment_types.dart';
import '../../../core/constants/muscle_groups.dart';
import '../../../core/theme/skins/skins.dart';
import '../../../data/models/exercise.dart';
import '../../../data/models/exercise_set.dart';
import '../../../data/models/training_cycle.dart';
import '../../../data/models/workout.dart';
import '../../../domain/providers/database_providers.dart';

/// Check if running on desktop platform
bool get _isDesktop =>
    Platform.isMacOS || Platform.isWindows || Platform.isLinux;

/// Hardcoded YouTube video URLs for exercises
/// Add video URLs here - supports full URLs or just video IDs
const Map<String, String> _exerciseVideos = {
  // Chest
  'Bench Press':
      'https://www.youtube.com/watch?v=fGm-ef-4PVk', // TODO: Add YouTube URL
  'Bench Press (Incline)': 'https://www.youtube.com/watch?v=fGm-ef-4PVk',
  'Incline Dumbbell Press': '',
  'Dumbbell Bench Press': '',

  // Back
  'Barbell Row': '',
  'Cable Row': '',
  'Lat Pulldown': '',
  'Face Pull': '',

  // Shoulders
  'Overhead Press': '',
  'Dumbbell Lateral Raise': '',

  // Arms
  'Barbell Curl': '',
  'Hammer Curl': '',
  'Cable Triceps Pushdown (Bar)': '',
  'Tricep Pushdown': '',
  'Barbell Overhead Triceps Extension': '',
  'Overhead Tricep Extension': '',
  'Assisted Dip': '',

  // Legs
  'Barbell Squat': '',
  'Front Squat': '',
  'Belt Squat': '',
  'Bulgarian Split Squat': '',
  'Leg Press': '',
  'Leg Extension': '',
  'Leg Curl': '',
  'Romanian Deadlift': '',

  // Calves
  'Calf Raise': '',
  'Seated Calf Raise': '',
  'Belt Squat Calves': '',
};

/// Dialog for displaying exercise information with Detail and History tabs.
class ExerciseInfoDialog extends ConsumerStatefulWidget {
  final Exercise exercise;

  const ExerciseInfoDialog({super.key, required this.exercise});

  @override
  ConsumerState<ExerciseInfoDialog> createState() => _ExerciseInfoDialogState();
}

class _ExerciseInfoDialogState extends ConsumerState<ExerciseInfoDialog> {
  bool _showDetail = true;
  YoutubePlayerController? _youtubeController;
  String? _videoUrl;

  @override
  void initState() {
    super.initState();
    _initializeYoutubeController();
  }

  void _initializeYoutubeController() {
    // Try exercise.videoUrl first, then fall back to hardcoded map
    _videoUrl =
        widget.exercise.videoUrl ?? _exerciseVideos[widget.exercise.name];
    final videoId = _extractVideoId(_videoUrl);
    if (videoId != null) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: false,
        ),
      );
    }
  }

  String? _extractVideoId(String? url) {
    if (url == null || url.isEmpty) return null;

    // Handle various YouTube URL formats
    final patterns = [
      RegExp(r'youtube\.com/watch\?v=([a-zA-Z0-9_-]+)'),
      RegExp(r'youtu\.be/([a-zA-Z0-9_-]+)'),
      RegExp(r'youtube\.com/embed/([a-zA-Z0-9_-]+)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null) {
        return match.group(1);
      }
    }

    // If it's just a video ID
    if (url.length == 11 && RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(url)) {
      return url;
    }

    return null;
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            _buildTabSelector(context),
            Flexible(
              child: _showDetail
                  ? _buildDetailTab(context)
                  : _buildHistoryTab(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Muscle group + Equipment type
                    Text(
                      '${widget.exercise.muscleGroup.displayName} · ${widget.exercise.equipmentType.displayName}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha((255 * 0.6).round()),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Exercise name
                    Text(
                      widget.exercise.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Expanded(child: _buildTabButton(context, 'Detail', true)),
            Expanded(child: _buildTabButton(context, 'History', false)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(BuildContext context, String label, bool isDetail) {
    final isSelected = _showDetail == isDetail;
    return GestureDetector(
      onTap: () => setState(() => _showDetail = isDetail),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailTab(BuildContext context) {
    final hasVideo = _videoUrl != null && _videoUrl!.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // YouTube Video - Desktop shows button only, mobile shows embedded player
          if (hasVideo && _isDesktop) ...[
            // Desktop: Show a nice card with "Watch on YouTube" button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.play_circle_outline,
                    size: 64,
                    color: context.youtubeColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Video Available',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _openYouTube(),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Watch on YouTube'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.youtubeColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ] else if (_youtubeController != null && !_isDesktop) ...[
            // Mobile: Show embedded player
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: YoutubePlayer(
                controller: _youtubeController!,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            // View on YouTube button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openYouTube(),
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('View on YouTube'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.videocam_off_outlined,
                    size: 48,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha((255 * 0.4).round()),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No video available',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha((255 * 0.6).round()),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Exercise Notes
          Text(
            'Notes',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.exercise.notes?.isNotEmpty == true
                  ? widget.exercise.notes!
                  : 'No notes added yet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: widget.exercise.notes?.isNotEmpty == true
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha((255 * 0.6).round()),
                fontStyle: widget.exercise.notes?.isNotEmpty == true
                    ? FontStyle.normal
                    : FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(BuildContext context) {
    final workoutRepo = ref.read(workoutRepositoryProvider);
    final trainingCycleRepo = ref.read(trainingCycleRepositoryProvider);

    return FutureBuilder<List<dynamic>>(
      future: Future.wait([workoutRepo.getAll(), trainingCycleRepo.getAll()]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading history: ${snapshot.error}'),
          );
        }

        final allWorkouts = snapshot.data![0] as List<Workout>;
        final allTrainingCycles = snapshot.data![1] as List<TrainingCycle>;

        // Create a map of trainingCycleId -> trainingCycle for quick lookup
        final trainingCycleMap = {for (var m in allTrainingCycles) m.id: m};

        // Find all exercises with the same name from all workouts (across all trainingCycles)
        final List<_HistoryEntry> historyEntries = [];

        for (final workout in allWorkouts) {
          for (final exercise in workout.exercises) {
            if (exercise.name.toLowerCase() ==
                widget.exercise.name.toLowerCase()) {
              // Only include exercises with at least one logged set
              if (exercise.sets.any((s) => s.isLogged)) {
                final trainingCycle = trainingCycleMap[workout.trainingCycleId];
                historyEntries.add(
                  _HistoryEntry(
                    exercise: exercise,
                    workout: workout,
                    trainingCycle: trainingCycle,
                    completedDate:
                        workout.completedDate ?? exercise.lastPerformed,
                  ),
                );
              }
            }
          }
        }

        // Sort by date (most recent first)
        historyEntries.sort((a, b) {
          if (a.completedDate == null && b.completedDate == null) return 0;
          if (a.completedDate == null) return 1;
          if (b.completedDate == null) return -1;
          return b.completedDate!.compareTo(a.completedDate!);
        });

        // Exclude the current exercise instance from history
        final filteredHistory = historyEntries
            .where((entry) => entry.exercise.id != widget.exercise.id)
            .toList();

        if (filteredHistory.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.history_outlined,
                    size: 48,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha((255 * 0.4).round()),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No history yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha((255 * 0.6).round()),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete sets to build your exercise history.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha((255 * 0.5).round()),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // Group entries by trainingCycle
        final Map<String, List<_HistoryEntry>> groupedByTrainingCycle = {};
        for (final entry in filteredHistory) {
          final trainingCycleId = entry.trainingCycle?.id ?? 'unknown';
          groupedByTrainingCycle
              .putIfAbsent(trainingCycleId, () => [])
              .add(entry);
        }

        // Build list with trainingCycle headers
        final List<Widget> children = [];
        for (final trainingCycleId in groupedByTrainingCycle.keys) {
          final entries = groupedByTrainingCycle[trainingCycleId]!;
          final trainingCycle = entries.first.trainingCycle;

          // Add trainingCycle header
          children.add(_buildTrainingCycleHeader(context, trainingCycle));

          // Add entries for this trainingCycle
          for (final entry in entries) {
            children.add(_buildHistoryRow(context, entry));
          }
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          shrinkWrap: true,
          children: children,
        );
      },
    );
  }

  Widget _buildTrainingCycleHeader(
    BuildContext context,
    TrainingCycle? trainingCycle,
  ) {
    final name = trainingCycle?.name ?? 'Unknown TrainingCycle';
    final periods = trainingCycle?.periodsTotal ?? 0;

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Text(
        '$name - $periods PERIODS'.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withAlpha((255 * 0.6).round()),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildHistoryRow(BuildContext context, _HistoryEntry entry) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final dateStr = entry.completedDate != null
        ? dateFormat.format(entry.completedDate!)
        : 'Unknown date';

    final loggedSets = entry.exercise.sets.where((s) => s.isLogged).toList();
    final isRecovery =
        entry.trainingCycle != null &&
        entry.workout.periodNumber == entry.trainingCycle!.recoveryPeriod;

    // Group sets by weight and build weight × reps string
    // This properly handles sets with different weights (e.g., "1 lbs x 1, 10 lbs x 1")
    final weightGroups = <double?, List<ExerciseSet>>{};
    for (final set in loggedSets) {
      weightGroups.putIfAbsent(set.weight, () => []).add(set);
    }

    // Build formatted string for each weight group
    final List<_WeightRepsGroup> groups = [];
    for (final weightEntry in weightGroups.entries) {
      final weight = weightEntry.key;
      final sets = weightEntry.value;

      final weightStr = weight != null
          ? weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1)
          : 'BW';

      // Collect reps with their badges for this weight group
      final repsWithBadges = sets.map((set) {
        final badge = set.setType.badge;
        if (badge != null) {
          return '${set.reps} $badge';
        }
        return set.reps;
      }).toList();

      groups.add(
        _WeightRepsGroup(
          weightStr: weightStr,
          repsStr: repsWithBadges.join(', '),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withAlpha((255 * 0.1).round()),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side: Weight × Reps + Deload indicator
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    children: _buildWeightRepsSpans(context, groups),
                  ),
                ),
                if (isRecovery) ...[
                  const SizedBox(height: 2),
                  Text(
                    'RECOVERY',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha((255 * 0.5).round()),
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Right side: Period/Day + Date
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha((255 * 0.6).round()),
                  ),
                  children: [
                    const TextSpan(text: 'PERIOD '),
                    TextSpan(
                      text: '${entry.workout.periodNumber}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const TextSpan(text: ' - DAY '),
                    TextSpan(
                      text: '${entry.workout.dayNumber}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                dateStr,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withAlpha((255 * 0.5).round()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build TextSpan children for weight × reps display, properly grouping by weight
  List<InlineSpan> _buildWeightRepsSpans(
    BuildContext context,
    List<_WeightRepsGroup> groups,
  ) {
    final List<InlineSpan> spans = [];

    for (var i = 0; i < groups.length; i++) {
      final group = groups[i];

      // Add separator between groups
      if (i > 0) {
        spans.add(const TextSpan(text: ',  '));
      }

      spans.add(
        TextSpan(text: group.weightStr, style: const TextStyle(fontSize: 18)),
      );
      spans.add(
        TextSpan(
          text: ' lbs',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withAlpha((255 * 0.7).round()),
          ),
        ),
      );
      spans.add(const TextSpan(text: '  x  '));
      spans.add(
        TextSpan(text: group.repsStr, style: const TextStyle(fontSize: 18)),
      );
    }

    return spans;
  }

  Future<void> _openYouTube() async {
    // Try exercise.videoUrl first, then fall back to hardcoded map
    final url =
        widget.exercise.videoUrl ?? _exerciseVideos[widget.exercise.name];
    if (url == null || url.isEmpty) return;

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

/// Shows the exercise info dialog.
Future<void> showExerciseInfoDialog(
  BuildContext context,
  Exercise exercise,
) async {
  return showDialog(
    context: context,
    builder: (context) => ExerciseInfoDialog(exercise: exercise),
  );
}

/// Helper class to hold history entry data
class _HistoryEntry {
  final Exercise exercise;
  final Workout workout;
  final TrainingCycle? trainingCycle;
  final DateTime? completedDate;

  _HistoryEntry({
    required this.exercise,
    required this.workout,
    this.trainingCycle,
    this.completedDate,
  });
}

/// Helper class for grouping weight and reps in history display
class _WeightRepsGroup {
  final String weightStr;
  final String repsStr;

  _WeightRepsGroup({required this.weightStr, required this.repsStr});
}
