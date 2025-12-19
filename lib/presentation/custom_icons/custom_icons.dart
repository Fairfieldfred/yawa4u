import 'package:flutter_app_icon_changer/flutter_app_icon_changer.dart';

/// A class containing static instances of custom icons.
class CustomIcons {
  /// The purple icon instance.
  static final maleIcon = MaleIcon();

  /// The red icon instance.
  static final femaleIcon = FemaleIcon();

  /// A list of all available [CustomIcon] instances.
  static final List<CustomIcon> list = [
    CustomIcons.maleIcon,
    CustomIcons.femaleIcon,
  ];
}

/// A sealed class representing a custom app icon with a preview path.
///
/// This class cannot be extended outside of its library.
sealed class CustomIcon extends AppIcon {
  /// The file path to the preview image of the icon.
  final String previewPath;

  CustomIcon({
    required this.previewPath,
    required super.iOSIcon,
    required super.androidIcon,
    required super.isDefaultIcon,
  });

  /// Creates a [CustomIcon] instance from a string [icon] name.
  ///
  /// Returns the corresponding [CustomIcon] if found;
  /// Otherwise, returns the default icon.
  factory CustomIcon.fromString(String? icon) {
    if (icon == null) return CustomIcons.maleIcon;

    return CustomIcons.list.firstWhere(
      (e) => e.iOSIcon == icon || e.androidIcon == icon,
      orElse: () => CustomIcons.maleIcon,
    );
  }
}

/// A final class representing the red custom icon.

/// A final class representing the purple custom icon.
final class FemaleIcon extends CustomIcon {
  FemaleIcon()
    : super(
        iOSIcon: 'AppIcon1',
        androidIcon: 'MainActivityAlias1',
        previewPath: 'assets/common/app-icon1.png',
        isDefaultIcon: false,
      );
}

/// A final class representing the default app icon.
final class MaleIcon extends CustomIcon {
  MaleIcon()
    : super(
        iOSIcon: 'AppIcon',
        androidIcon: 'MainActivity',
        previewPath: 'assets/common/app-icon.png',
        isDefaultIcon: true,
      );
}
