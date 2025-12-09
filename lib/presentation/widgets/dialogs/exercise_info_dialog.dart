import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../core/constants/equipment_types.dart';
import '../../../core/constants/muscle_groups.dart';
import '../../../data/models/exercise.dart';
import '../../../domain/providers/repository_providers.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeYoutubeController();
  }

  void _initializeYoutubeController() {
    final videoId = _extractVideoId(widget.exercise.videoUrl);
    if (videoId != null) {
      _youtubeController = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        autoPlay: false,
        params: const YoutubePlayerParams(
          showFullscreenButton: true,
          showControls: true,
          mute: false,
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
    _youtubeController?.close();
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
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha((255 * 0.6).round()),
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
            Expanded(
              child: _buildTabButton(context, 'Detail', true),
            ),
            Expanded(
              child: _buildTabButton(context, 'History', false),
            ),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // YouTube Video
          if (_youtubeController != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: YoutubePlayer(
                  controller: _youtubeController!,
                ),
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
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withAlpha((255 * 0.4).round()),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No video available',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha((255 * 0.6).round()),
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
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
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
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withAlpha((255 * 0.6).round()),
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
    final exerciseRepo = ref.read(exerciseRepositoryProvider);
    final history = exerciseRepo.getHistoryByName(widget.exercise.name);

    // Filter to only show exercises with logged sets
    final loggedHistory = history.where((e) {
      return e.sets.any((s) => s.isLogged);
    }).toList();

    if (loggedHistory.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.history_outlined,
                size: 48,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withAlpha((255 * 0.4).round()),
              ),
              const SizedBox(height: 16),
              Text(
                'No history yet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha((255 * 0.6).round()),
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Complete sets to build your exercise history.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha((255 * 0.5).round()),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      shrinkWrap: true,
      itemCount: loggedHistory.length,
      itemBuilder: (context, index) {
        final exercise = loggedHistory[index];
        return _buildHistoryEntry(context, exercise);
      },
    );
  }

  Widget _buildHistoryEntry(BuildContext context, Exercise exercise) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final dateStr = exercise.lastPerformed != null
        ? dateFormat.format(exercise.lastPerformed!)
        : 'Unknown date';

    final loggedSets = exercise.sets.where((s) => s.isLogged).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date header
          Text(
            dateStr,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withAlpha((255 * 0.6).round()),
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8),
          // Sets
          ...loggedSets.map((set) {
            final weightStr = set.weight != null
                ? '${set.weight!.toStringAsFixed(set.weight! % 1 == 0 ? 0 : 1)} lbs'
                : 'BW';
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Text(
                      '${set.setNumber}.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha((255 * 0.6).round()),
                          ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '$weightStr × ${set.reps}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _openYouTube() async {
    final url = widget.exercise.videoUrl;
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
