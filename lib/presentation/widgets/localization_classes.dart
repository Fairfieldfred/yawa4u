import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/providers/locale_provider.dart';
import '../../l10n/app_localizations.dart';

/// Displays a list of tappable language options.
///
/// Each item has a [Semantics] identifier (e.g. `locale_en`) so automated
/// tests can reliably find it in the widget tree. Selecting a language
/// sets the app locale via [LocaleNotifier] and closes the parent dialog.
class LocaleSelector extends ConsumerWidget {
  const LocaleSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locales = [
      (null, l10n.localeSystem, 'locale_system'),
      (const Locale('en'), l10n.localeEnglish, 'locale_en'),
      (const Locale('es'), l10n.localeSpanish, 'locale_es'),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: locales.map((entry) {
        final (locale, label, id) = entry;
        return Semantics(
          identifier: id,
          child: ListTile(
            title: Text(label, textAlign: TextAlign.center),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onTap: () {
              ref.read(localeProvider.notifier).setLocale(locale);
              Navigator.of(context).pop();
            },
          ),
        );
      }).toList(),
    );
  }
}
