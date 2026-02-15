import 'package:flutter/material.dart';

import '../../core/extensions/context_extensions.dart';

/// Constrains content width on desktop to improve readability.
///
/// On screens wider than 1200dp, centers content with a max width of 800dp.
/// On mobile/tablet, passes through without constraint.
class ResponsiveContent extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = 800,
  });

  @override
  Widget build(BuildContext context) {
    if (!context.isDesktop) return child;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
