import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/sports.dart';
import '../../../core/utils/cardio_conversions.dart';
import '../../../data/models/cardio_session_template.dart';
import '../../../domain/providers/cardio_library_providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/cardio/sport_badge.dart';
import '../../widgets/skeleton_loader.dart';

/// Modal sheet that lists bundled cardio session templates filtered by
/// sport. Returns the selected template (or null on dismiss).
///
/// Design: a scrollable list of cards, each showing name + category +
/// duration + difficulty. Tapping a card pops with the chosen template.
/// Caller is responsible for turning the template into a persisted
/// session via [CardioSessionLibraryService.instantiate].
class CardioTemplatePicker extends ConsumerWidget {
  const CardioTemplatePicker({super.key, required this.sport});

  final Sport sport;

  static Future<CardioSessionTemplate?> show(
    BuildContext context, {
    required Sport sport,
  }) {
    return showModalBottomSheet<CardioSessionTemplate>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(ctx).size.height * 0.75,
        child: CardioTemplatePicker(sport: sport),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(cardioSessionTemplatesBySportProvider(sport));
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SportBadge(sport: sport),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.cardioTemplatePickerTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.cardioTemplatePickerSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: async.when(
              loading: () => const SkeletonCardList(itemCount: 3),
              error: (e, _) => Center(
                child: Text(
                  l10n.cardioTemplatePickerLoadError('$e'),
                  textAlign: TextAlign.center,
                ),
              ),
              data: (templates) {
                if (templates.isEmpty) {
                  return Center(
                    child: Text(l10n.cardioTemplatePickerNoTemplates),
                  );
                }
                return ListView.separated(
                  itemCount: templates.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) => _TemplateCard(
                    template: templates[i],
                    onTap: () => Navigator.pop(ctx, templates[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({required this.template, required this.onTap});

  final CardioSessionTemplate template;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = template.sport.color;
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      template.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  _Pill(
                    label: template.difficulty.localizedName(AppLocalizations.of(context)!),
                    color: color,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                template.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.75),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 4,
                children: [
                  if (template.durationEstimateSec > 0)
                    _MetaChip(
                      icon: Icons.timer_outlined,
                      label: CardioConversions.formatDuration(
                        template.durationEstimateSec,
                      ),
                    ),
                  _MetaChip(
                    icon: Icons.format_list_numbered,
                    label: l10n.cardioTemplatePickerStepsCount(
                      template.intervals.length,
                    ),
                  ),
                  _MetaChip(
                    icon: Icons.label_outline,
                    label: template.category,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.7);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
        ),
      ],
    );
  }
}
