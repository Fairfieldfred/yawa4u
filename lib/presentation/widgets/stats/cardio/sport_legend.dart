import 'package:flutter/material.dart';

import '../../../../core/constants/sports.dart';
import '../../../../l10n/app_localizations.dart';

/// Small legend row that maps each sport's color to its label.
///
/// Sits under the stacked weekly volume chart so users can map bar colors
/// to sports. Only shows sports that have any data ([include]).
class SportLegend extends StatelessWidget {
  const SportLegend({super.key, required this.include});

  /// Sports to show. Typically the keys of `cardioStats.perSport`.
  final List<Sport> include;

  @override
  Widget build(BuildContext context) {
    if (include.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 14,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: [
        for (final sport in include)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: sport.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                sport.localizedName(AppLocalizations.of(context)!),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
      ],
    );
  }
}
