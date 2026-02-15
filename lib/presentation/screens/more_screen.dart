import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/sentry_service.dart';
import '../../core/theme/skins/skin_provider.dart';
import '../../domain/providers/onboarding_providers.dart';
import '../../domain/providers/theme_provider.dart';
import '../widgets/app_icon_widget.dart';
import '../widgets/screen_background.dart';

/// More/Settings screen
class MoreScreen extends ConsumerStatefulWidget {
  const MoreScreen({super.key});

  @override
  ConsumerState<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends ConsumerState<MoreScreen>
    with SingleTickerProviderStateMixin {
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
        _version = 'Version ${packageInfo.version}';
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
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
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
    final themeMode = ref.watch(themeModeProvider);
    final selectedIconIndex = ref.watch(userProfileProvider).appIconIndex;
    final activeSkin = ref.watch(activeSkinProvider);

    // Check if using a custom theme with a custom app icon
    final hasCustomAppIcon =
        !activeSkin.isBuiltIn &&
        activeSkin.backgrounds?.appIcon != null &&
        activeSkin.backgrounds!.appIcon!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('YAWA4U'), centerTitle: true),
      body: ScreenBackground.more(
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
                    _version,
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
                      'Theme mode',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.system,
                        label: Text('System'),
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.light,
                        label: Text('Light'),
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.dark,
                        label: Text('Dark'),
                      ),
                    ],
                    selected: {themeMode},
                    onSelectionChanged: (Set<ThemeMode> newSelection) {
                      ref
                          .read(themeModeProvider.notifier)
                          .setThemeMode(newSelection.first);
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
            const Divider(height: 1),

            // Appearance / Skins
            ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: const Text('Appearance'),
              subtitle: const Text('Choose your app theme'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/skins'),
            ),
            const Divider(height: 1),

            // Statistics
            ListTile(
              leading: const Icon(Icons.bar_chart_outlined),
              title: const Text('Statistics'),
              subtitle: const Text('Volume, records, and progress'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/stats'),
            ),
            const Divider(height: 1),

            // Sync Data
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('Sync Data'),
              subtitle: const Text('Sync with another device via WiFi'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/sync'),
            ),
            const Divider(height: 1),

            // Share App
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share App'),
              subtitle: const Text('Share YAWA4U with friends'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                await SharePlus.instance.share(
                  ShareParams(
                    text:
                        'Check out YAWA4U - The best workout tracker! https://testflight.apple.com/join/YVQsRjzD',
                  ),
                );
              },
            ),
            const Divider(height: 1),

            // Share Template
            ListTile(
              leading: const Icon(Icons.file_copy_outlined),
              title: const Text('Share Template'),
              subtitle: const Text('Share workout templates via WiFi'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/template-share'),
            ),
            const Divider(height: 1),

            // Settings
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              subtitle: const Text('Units, terminology, equipment'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings'),
            ),
            const Divider(height: 1),

            // Send Feedback
            ListTile(
              title: const Text('Send feedback'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                SentryService.instance.showBetterFeedback(context);
              },
            ),
            const Divider(height: 1),

            // Sentry Debug (debug builds only)
            if (kDebugMode) ...[
              ListTile(
                leading: const Icon(Icons.bug_report, color: Colors.orange),
                title: const Text('Sentry Debug'),
                subtitle: const Text('Test Sentry integration'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/sentry-debug'),
              ),
              const Divider(height: 1),
            ],

            // Website
            ListTile(
              title: const Text('Website'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final url = Uri.parse(
                  'https://github.com/Fairfieldfred/yawa4u',
                );
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
            ),
            const Divider(height: 1),

            // Language
            ListTile(
              title: const Text('Language'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Language selection coming soon'),
                  ),
                );
              },
            ),
            const Divider(height: 1),

            // Privacy Policy
            ListTile(
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final url = Uri.parse(AppConstants.privacyPolicyUrl);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
            ),
            const Divider(height: 1),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
