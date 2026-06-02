import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/sentry_service.dart';
import '../../../core/theme/skins/skin_provider.dart';
import '../../../domain/providers/onboarding_providers.dart';
import '../../../domain/providers/theme_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/app_icon_widget.dart';
import '../../widgets/localization_classes.dart';
import '../../widgets/responsive_content.dart';
import '../../widgets/screen_background.dart';

/// More/Settings screen
class MoreScreen extends ConsumerStatefulWidget {
  const MoreScreen({super.key});

  @override
  ConsumerState<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends ConsumerState<MoreScreen> with SingleTickerProviderStateMixin {
  String _version = '';

  late AnimationController _animationController;
  late Animation<double> _animation;

  // Light mode icons
  static const List<String> _lightIconPaths = [
    'assets/common/app-icon.png',
    'assets/common/yawa4u-icon.png',
    'assets/common/female-app-icon.png',
  ];

  // Dark mode icons
  static const List<String> _darkIconPaths = [
    'assets/common/app-icon-dark.png',
    'assets/common/yawa4u-icon-dark.png',
    'assets/common/female-app-icon-dark.png',
  ];

  List<String> _getIconPaths(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? _darkIconPaths : _lightIconPaths;
  }

  @override
  void initState() {
    super.initState();
    _loadVersion();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = packageInfo.version;
      });
    }
  }

  void _selectIcon(int index) {
    final currentIndex = ref.read(userProfileProvider).appIconIndex;
    if (index != currentIndex) {
      // Save the new icon index
      ref.read(userProfileProvider.notifier).saveAppIconIndex(index);
      _animationController.forward(from: 0);
    }
  }

  List<int> _getOrderedIndices(int selectedIconIndex) {
    // Returns indices ordered so selected is in center
    switch (selectedIconIndex) {
      case 0:
        return [1, 0, 2]; // Move 0 to center
      case 1:
        return [0, 1, 2]; // 1 already in center
      case 2:
        return [0, 2, 1]; // Move 2 to center
      default:
        return [0, 1, 2];
    }
  }

  Widget _buildSelectableIcon(
    int iconIndex,
    int selectedIconIndex, {
    required bool isCenter,
  }) {
    final isSelected = iconIndex == selectedIconIndex;
    final size = isCenter ? 100.0 : 70.0;
    final borderWidth = isSelected ? 3.0 : 0.0;

    return GestureDetector(
      onTap: () => _selectIcon(iconIndex),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isCenter ? 20 : 14),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
            width: borderWidth,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isCenter ? 17 : 11),
          child: Image.asset(
            _getIconPaths(context)[iconIndex],
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeModeProvider);
    final selectedIconIndex = ref.watch(userProfileProvider).appIconIndex;
    final activeSkin = ref.watch(activeSkinProvider);

    // Check if using a custom theme with a custom app icon
    final hasCustomAppIcon =
        !activeSkin.isBuiltIn && activeSkin.backgrounds?.appIcon != null && activeSkin.backgrounds!.appIcon!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.moreScreenTitle), centerTitle: true),
      body: ScreenBackground.more(
        child: ResponsiveContent(
          child: ListView(
            children: [
              const SizedBox(height: 32),
              // App Logo & Info
              Center(
                child: Column(
                  children: [
                    if (hasCustomAppIcon)
                      // Show only the custom app icon (no selection)
                      const AppIconWidget(size: 100)
                    else
                      // Show selectable icons for built-in themes
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          final orderedIndices = _getOrderedIndices(
                            selectedIconIndex,
                          );
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (int i = 0; i < 3; i++)
                                _buildSelectableIcon(
                                  orderedIndices[i],
                                  selectedIconIndex,
                                  isCenter: i == 1,
                                ),
                            ],
                          );
                        },
                      ),
                    const SizedBox(height: 16),

                    const SizedBox(height: 8),
                    Text(
                      l10n.versionLabel(_version),
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Theme Mode
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12, bottom: 8),
                      child: Text(
                        l10n.themeMode,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    SegmentedButton<ThemeMode>(
                      segments: [
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.system,
                          label: Text(l10n.themeModeSystem),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.light,
                          label: Text(l10n.themeModeLight),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.dark,
                          label: Text(l10n.themeModeDark),
                        ),
                      ],
                      selected: {themeMode},
                      onSelectionChanged: (Set<ThemeMode> newSelection) {
                        ref.read(themeModeProvider.notifier).setThemeMode(newSelection.first);
                      },
                      style: ButtonStyle(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ─── Appearance ──────────────────────────────────────────────
              _MoreSectionHeader(l10n.sectionAppearance),
              ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: Text(l10n.themeTitle),
                subtitle: Text(l10n.themeSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/skins'),
              ),

              // ─── Training ────────────────────────────────────────────────
              _MoreSectionHeader(l10n.sectionTraining),
              ListTile(
                leading: const Icon(Icons.bar_chart_outlined),
                title: Text(l10n.statisticsTitle),
                subtitle: Text(l10n.statisticsSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/stats'),
              ),
              ListTile(
                leading: const Icon(Icons.straighten),
                title: Text(l10n.unitsTitle),
                subtitle: Text(l10n.unitsSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/units'),
              ),
              ListTile(
                leading: const Icon(Icons.favorite_outline),
                title: Text(l10n.zonesTitle),
                subtitle: Text(l10n.zonesSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/zones'),
              ),

              // ─── Integrations & Data ─────────────────────────────────────
              _MoreSectionHeader(l10n.sectionIntegrationsData),
              ListTile(
                leading: const Icon(Icons.integration_instructions_outlined),
                title: Text(l10n.integrationsTitle),
                subtitle: Text(l10n.integrationsSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/integrations'),
              ),
              ListTile(
                leading: const Icon(Icons.sync),
                title: Text(l10n.syncDataTitle),
                subtitle: Text(l10n.syncDataSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/sync'),
              ),
              ListTile(
                leading: const Icon(Icons.file_copy_outlined),
                title: Text(l10n.shareTemplateTitle),
                subtitle: Text(l10n.shareTemplateSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/template-share'),
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: Text(l10n.shareAppTitle),
                subtitle: Text(l10n.shareAppSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await SharePlus.instance.share(
                    ShareParams(
                      text: l10n.shareAppText,
                    ),
                  );
                },
              ),

              // ─── Preferences ─────────────────────────────────────────────
              _MoreSectionHeader(l10n.sectionPreferences),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: Text(l10n.settingsTitle),
                subtitle: Text(l10n.settingsSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings'),
              ),

              // ─── Help & feedback ─────────────────────────────────────────
              _MoreSectionHeader(l10n.sectionHelpFeedback),
              ListTile(
                leading: const Icon(Icons.feedback_outlined),
                title: Text(l10n.sendFeedbackTitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  SentryService.instance.showBetterFeedback(context);
                },
              ),

              ListTile(
                leading: const Icon(Icons.language),
                title: Text(l10n.languageTitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showModalBottomSheet<void>(
                    context: context,
                    builder: (context) {
                      final sheetL10n = AppLocalizations.of(context)!;
                      return Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sheetL10n.languageSheetTitle,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              sheetL10n.languageSheetSubtitle,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const LocaleSelector(),
                            const SizedBox(height: 16),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),

              // ─── About ───────────────────────────────────────────────────
              _MoreSectionHeader(l10n.sectionAbout),
              ListTile(
                leading: const Icon(Icons.public),
                title: Text(l10n.websiteTitle),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () async {
                  final url = Uri.parse(
                    'https://github.com/Fairfieldfred/yawa4u',
                  );
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: Text(l10n.privacyPolicyTitle),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () async {
                  final url = Uri.parse(AppConstants.privacyPolicyUrl);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
              ),

              // Debug-only tools live at the very bottom so they don't
              // clutter the normal browsing experience.
              if (kDebugMode) ...[
                _MoreSectionHeader(l10n.sectionDeveloper),
                ListTile(
                  leading: const Icon(Icons.bug_report, color: Colors.orange),
                  title: Text(l10n.sentryDebugTitle),
                  subtitle: Text(l10n.sentryDebugSubtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/sentry-debug'),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

/// Section header used inside MoreScreen's list. Lives here rather than
/// in a shared widget because it's heavily styled for this one surface --
/// if another screen needs similar section headers, extract later.
class _MoreSectionHeader extends StatelessWidget {
  const _MoreSectionHeader(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
