import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/skins/skin_model.dart';
import '../../core/theme/skins/skin_provider.dart';
import '../../data/services/theme_image_service.dart';

/// Screen for creating or editing a custom theme.
///
/// Provides a multi-step wizard to:
/// 1. Set theme name and description
/// 2. Select background images for each screen
/// 3. Select app icon image
/// 4. Choose accent colors (with auto-extraction from images)
class ThemeEditorScreen extends ConsumerStatefulWidget {
  /// Optional skin ID for editing an existing custom theme.
  /// If null, a new theme is being created.
  final String? skinId;

  const ThemeEditorScreen({super.key, this.skinId});

  @override
  ConsumerState<ThemeEditorScreen> createState() => _ThemeEditorScreenState();
}

class _ThemeEditorScreenState extends ConsumerState<ThemeEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();

  int _currentPage = 0;
  bool _isLoading = false;
  bool _isSaving = false;

  // Theme metadata
  late String _themeId;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Image paths (null = no image selected)
  String? _workoutImagePath;
  String? _cyclesImagePath;
  String? _exercisesImagePath;
  String? _moreImagePath;
  String? _defaultImagePath;
  String? _appIconImagePath;

  // Colors
  Color _primaryColor = const Color(0xFFE53935);
  Color _secondaryColor = const Color(0xFF42A5F5);
  List<Color> _extractedColors = [];

  // Original skin for editing
  SkinModel? _originalSkin;

  @override
  void initState() {
    super.initState();
    _themeId = widget.skinId ?? const Uuid().v4();
    if (widget.skinId != null) {
      _loadExistingSkin();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingSkin() async {
    setState(() => _isLoading = true);

    try {
      final skinState = ref.read(skinProvider);
      final skin = skinState.availableSkins.firstWhere(
        (s) => s.id == widget.skinId,
        orElse: () => throw Exception('Skin not found'),
      );

      _originalSkin = skin;
      _nameController.text = skin.name;
      _descriptionController.text = skin.description;
      _primaryColor = skin.colors.primaryColor;
      _secondaryColor = skin.colors.secondaryColor;

      // Resolve paths from the saved skin model (handles both relative and legacy absolute)
      final imageService = ref.read(themeImageServiceProvider);
      final backgrounds = skin.backgrounds;
      if (backgrounds != null) {
        // Resolve all paths to absolute paths for display
        _workoutImagePath = await imageService.resolveImagePath(
          backgrounds.workout,
        );
        _cyclesImagePath = await imageService.resolveImagePath(
          backgrounds.cycles,
        );
        _exercisesImagePath = await imageService.resolveImagePath(
          backgrounds.exercises,
        );
        _moreImagePath = await imageService.resolveImagePath(backgrounds.more);
        _defaultImagePath = await imageService.resolveImagePath(
          backgrounds.defaultBackground,
        );
        _appIconImagePath = await imageService.resolveImagePath(
          backgrounds.appIcon,
        );
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading theme: $e')));
      }
    }
  }

  void _nextPage() {
    if (_currentPage == 0) {
      if (!_formKey.currentState!.validate()) return;
    }

    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _pickImage(String imageType) async {
    final imageService = ref.read(themeImageServiceProvider);

    // Show picker dialog
    final source = await showModalBottomSheet<ImagePickerSource>(
      context: context,
      builder: (context) => _ImageSourcePicker(),
    );

    if (source == null) return;

    setState(() => _isLoading = true);

    try {
      final xFile = source == ImagePickerSource.gallery
          ? await imageService.pickImageFromGallery()
          : await imageService.pickImageFromCamera();

      if (xFile == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Save the image
      final savedPath = await imageService.saveThemeImage(
        themeId: _themeId,
        imageType: imageType,
        sourcePath: xFile.path,
      );

      if (savedPath != null) {
        setState(() {
          switch (imageType) {
            case 'workout':
              _workoutImagePath = savedPath;
            case 'cycles':
              _cyclesImagePath = savedPath;
            case 'exercises':
              _exercisesImagePath = savedPath;
            case 'more':
              _moreImagePath = savedPath;
            case 'default':
              _defaultImagePath = savedPath;
            case 'app_icon':
              _appIconImagePath = savedPath;
          }
        });

        // Extract colors if this is a background image
        if (imageType != 'app_icon') {
          final colors = await imageService.extractDominantColors(savedPath);
          if (colors.isNotEmpty && mounted) {
            setState(() {
              _extractedColors = colors;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _removeImage(String imageType) async {
    final imageService = ref.read(themeImageServiceProvider);

    await imageService.deleteThemeImage(
      themeId: _themeId,
      imageType: imageType,
    );

    setState(() {
      switch (imageType) {
        case 'workout':
          _workoutImagePath = null;
        case 'cycles':
          _cyclesImagePath = null;
        case 'exercises':
          _exercisesImagePath = null;
        case 'more':
          _moreImagePath = null;
        case 'default':
          _defaultImagePath = null;
        case 'app_icon':
          _appIconImagePath = null;
      }
    });
  }

  Future<void> _saveTheme() async {
    // Validate form if it's been built
    final formState = _formKey.currentState;
    if (formState != null && !formState.validate()) {
      _pageController.jumpToPage(0);
      return;
    }

    // Also check that name is not empty
    if (_nameController.text.trim().isEmpty) {
      _pageController.jumpToPage(0);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a theme name')),
        );
      }
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Build the skin model
      final skin = _buildSkinModel();

      // Debug: Print the backgrounds being saved
      debugPrint('[ThemeEditor] Saving theme with backgrounds:');
      debugPrint('  workout: ${skin.backgrounds?.workout}');
      debugPrint('  cycles: ${skin.backgrounds?.cycles}');
      debugPrint('  exercises: ${skin.backgrounds?.exercises}');
      debugPrint('  more: ${skin.backgrounds?.more}');
      debugPrint('  default: ${skin.backgrounds?.defaultBackground}');
      debugPrint('  appIcon: ${skin.backgrounds?.appIcon}');

      // Save to repository
      await ref.read(skinProvider.notifier).saveCustomSkin(skin);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.skinId != null ? 'Theme updated!' : 'Theme created!',
            ),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving theme: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  SkinModel _buildSkinModel() {
    // Start with original or default values
    final base = _originalSkin;

    // Get image service for path conversion
    final imageService = ref.read(themeImageServiceProvider);

    return SkinModel(
      id: _themeId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      author: 'Custom',
      version: '1.0.0',
      isPremium: false,
      isBuiltIn: false,
      colors: SkinColors(
        primary: _colorToHex(_primaryColor),
        primaryDark: _colorToHex(_darkenColor(_primaryColor)),
        primaryLight: _colorToHex(_lightenColor(_primaryColor)),
        secondary: _colorToHex(_secondaryColor),
        success: base?.colors.success ?? '#4CAF50',
        warning: base?.colors.warning ?? '#FFA726',
        error: base?.colors.error ?? '#EF5350',
        info: base?.colors.info ?? '#42A5F5',
      ),
      lightMode:
          base?.lightMode ??
          const SkinModeColors(
            scaffoldBackground: '#F2F2F7',
            cardBackground: '#FFFFFF',
            inputBackground: '#F9F9F9',
            divider: '#E0E0E0',
            textPrimary: '#212121',
            textSecondary: '#757575',
            textDisabled: '#BDBDBD',
          ),
      darkMode:
          base?.darkMode ??
          const SkinModeColors(
            scaffoldBackground: '#1C1C1E',
            cardBackground: '#2C2C2E',
            inputBackground: '#151516',
            divider: '#48484A',
            textPrimary: '#FFFFFF',
            textSecondary: '#9E9E9E',
            textDisabled: '#616161',
          ),
      muscleGroups:
          base?.muscleGroups ??
          const SkinMuscleGroupColors(
            upperPush: '#E91E63',
            upperPull: '#00BCD4',
            legs: '#009688',
            coreAndAccessories: '#9C27B0',
          ),
      workoutStatus:
          base?.workoutStatus ??
          SkinWorkoutStatusColors(
            current: _colorToHex(_primaryColor),
            completed: '#4CAF50',
            skipped: '#757575',
            deload: '#FFA726',
          ),
      components:
          base?.components ??
          const SkinComponents(
            cardBorderRadius: 12,
            buttonBorderRadius: 8,
            inputBorderRadius: 8,
            cardElevation: 2,
            buttonElevation: 2,
          ),
      backgrounds: SkinBackgrounds(
        workout: imageService.toRelativePath(_workoutImagePath),
        cycles: imageService.toRelativePath(_cyclesImagePath),
        exercises: imageService.toRelativePath(_exercisesImagePath),
        more: imageService.toRelativePath(_moreImagePath),
        defaultBackground: imageService.toRelativePath(_defaultImagePath),
        appIcon: imageService.toRelativePath(_appIconImagePath),
      ),
    );
  }

  String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }

  Color _darkenColor(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  Color _lightenColor(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.skinId != null ? 'Edit Theme' : 'Create Theme'),
        actions: [
          if (_currentPage == 3)
            TextButton(
              onPressed: _isSaving ? null : _saveTheme,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Step indicator
                _buildStepIndicator(),

                // Page content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) {
                      setState(() => _currentPage = page);
                    },
                    children: [
                      _buildNamePage(),
                      _buildBackgroundsPage(),
                      _buildAppIconPage(),
                      _buildColorsPage(),
                    ],
                  ),
                ),

                // Navigation buttons
                _buildNavigationButtons(),
              ],
            ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Info', 'Backgrounds', 'Icon', 'Colors'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(steps.length, (index) {
          final isActive = index == _currentPage;
          final isCompleted = index < _currentPage;

          return Row(
            children: [
              if (index > 0)
                Container(
                  width: 32,
                  height: 2,
                  color: isCompleted
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive || isCompleted
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: Border.all(
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: Theme.of(context).colorScheme.onPrimary,
                        )
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isActive
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildNamePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theme Info',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Give your theme a name and description.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Theme Name',
                hintText: 'My Custom Theme',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a theme name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'A brief description of your theme',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Screen Backgrounds',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Choose background images for each screen. Tap to add, long press to remove.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          _buildImagePicker(
            label: 'Workout Screen',
            imagePath: _workoutImagePath,
            imageType: 'workout',
            icon: Icons.fitness_center,
          ),
          _buildImagePicker(
            label: 'Mesocycles Screen',
            imagePath: _cyclesImagePath,
            imageType: 'cycles',
            icon: Icons.calendar_month,
          ),
          _buildImagePicker(
            label: 'Exercises Screen',
            imagePath: _exercisesImagePath,
            imageType: 'exercises',
            icon: Icons.list_alt,
          ),
          _buildImagePicker(
            label: 'More Screen',
            imagePath: _moreImagePath,
            imageType: 'more',
            icon: Icons.more_horiz,
          ),
          _buildImagePicker(
            label: 'Default (Calendar & Others)',
            imagePath: _defaultImagePath,
            imageType: 'default',
            icon: Icons.wallpaper,
          ),
        ],
      ),
    );
  }

  Widget _buildAppIconPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('App Icon', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Choose an image to use as your app\'s accent icon (displayed in the app bar).',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: GestureDetector(
              onTap: () => _pickImage('app_icon'),
              onLongPress: _appIconImagePath != null
                  ? () => _removeImage('app_icon')
                  : null,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                child: _appIconImagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(
                          File(_appIconImagePath!),
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 48,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to add',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          if (_appIconImagePath != null) ...[
            const SizedBox(height: 16),
            Center(
              child: TextButton.icon(
                onPressed: () => _removeImage('app_icon'),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Remove'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildColorsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Accent Colors',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Choose your theme\'s primary and secondary colors.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Extracted colors suggestion
          if (_extractedColors.isNotEmpty) ...[
            Text(
              'Suggested from your images:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _extractedColors.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() => _primaryColor = color);
                  },
                  onDoubleTap: () {
                    setState(() => _secondaryColor = color);
                  },
                  child: Tooltip(
                    message: 'Tap: Primary\nDouble-tap: Secondary',
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Primary color
          _buildColorSelector(
            label: 'Primary Color',
            color: _primaryColor,
            onColorChanged: (color) => setState(() => _primaryColor = color),
          ),
          const SizedBox(height: 16),

          // Secondary color
          _buildColorSelector(
            label: 'Secondary Color',
            color: _secondaryColor,
            onColorChanged: (color) => setState(() => _secondaryColor = color),
          ),
          const SizedBox(height: 24),

          // Preview
          Text('Preview', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.check, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nameController.text.isEmpty
                                  ? 'Theme Name'
                                  : _nameController.text,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: _primaryColor),
                            ),
                            Text(
                              'Custom Theme',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: _primaryColor,
                          ),
                          onPressed: () {},
                          child: const Text('Primary'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.tonal(
                          style: FilledButton.styleFrom(
                            backgroundColor: _secondaryColor.withValues(
                              alpha: 0.2,
                            ),
                            foregroundColor: _secondaryColor,
                          ),
                          onPressed: () {},
                          child: const Text('Secondary'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker({
    required String label,
    required String? imagePath,
    required String imageType,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => _pickImage(imageType),
        onLongPress: imagePath != null ? () => _removeImage(imageType) : null,
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: Row(
            children: [
              // Image preview or placeholder
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(11),
                  ),
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                ),
                child: imagePath != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(11),
                        ),
                        child: Image.file(File(imagePath), fit: BoxFit.cover),
                      )
                    : Icon(
                        icon,
                        size: 32,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
              ),
              // Label and actions
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        imagePath != null
                            ? 'Tap to change, hold to remove'
                            : 'Tap to add image',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Action icon
              Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  imagePath != null ? Icons.edit : Icons.add_photo_alternate,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorSelector({
    required String label,
    required Color color,
    required ValueChanged<Color> onColorChanged,
  }) {
    final presetColors = [
      const Color(0xFFE53935), // Red
      const Color(0xFFD81B60), // Pink
      const Color(0xFF8E24AA), // Purple
      const Color(0xFF5E35B1), // Deep Purple
      const Color(0xFF3949AB), // Indigo
      const Color(0xFF1E88E5), // Blue
      const Color(0xFF039BE5), // Light Blue
      const Color(0xFF00ACC1), // Cyan
      const Color(0xFF00897B), // Teal
      const Color(0xFF43A047), // Green
      const Color(0xFF7CB342), // Light Green
      const Color(0xFFFDD835), // Yellow
      const Color(0xFFFFB300), // Amber
      const Color(0xFFFB8C00), // Orange
      const Color(0xFFF4511E), // Deep Orange
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(label, style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: presetColors.map((presetColor) {
            final isSelected = presetColor.toARGB32() == color.toARGB32();
            return GestureDetector(
              onTap: () => onColorChanged(presetColor),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: presetColor,
                  borderRadius: BorderRadius.circular(6),
                  border: isSelected
                      ? Border.all(
                          color: Theme.of(context).colorScheme.onSurface,
                          width: 3,
                        )
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentPage > 0)
              OutlinedButton(
                onPressed: _previousPage,
                child: const Text('Back'),
              ),
            const Spacer(),
            if (_currentPage < 3)
              FilledButton(onPressed: _nextPage, child: const Text('Next'))
            else
              FilledButton(
                onPressed: _isSaving ? null : _saveTheme,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save Theme'),
              ),
          ],
        ),
      ),
    );
  }
}

enum ImagePickerSource { gallery, camera }

class _ImageSourcePicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from Gallery'),
            onTap: () => Navigator.pop(context, ImagePickerSource.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take a Photo'),
            onTap: () => Navigator.pop(context, ImagePickerSource.camera),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
