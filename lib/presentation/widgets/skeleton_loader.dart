import 'package:flutter/material.dart';

/// A single pulsing placeholder rectangle used to indicate loading content.
///
/// Combine multiple [SkeletonBox]es inside a [SkeletonLoader] to build
/// skeleton screens that mirror the layout of the real content.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
  });

  /// Width of the placeholder. Defaults to fill available space.
  final double? width;

  /// Height of the placeholder.
  final double height;

  /// Corner radius.
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Wraps children in a gentle pulse animation to signal loading.
///
/// Place [SkeletonBox] widgets inside to build a skeleton screen.
class SkeletonLoader extends StatefulWidget {
  const SkeletonLoader({super.key, required this.child});

  final Widget child;

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.4, end: 1.0).animate(_animation),
      child: widget.child,
    );
  }
}

// ---------------------------------------------------------------------------
// Pre-built skeleton screens
// ---------------------------------------------------------------------------

/// Skeleton for a list of cards (cycle list, template list, etc.).
class SkeletonCardList extends StatelessWidget {
  const SkeletonCardList({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, _) => const _SkeletonCard(),
      ),
    );
  }
}

/// Skeleton for a stats-style screen with summary row + chart + details.
class SkeletonStats extends StatelessWidget {
  const SkeletonStats({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary row — three small cards
            Row(
              children: List.generate(
                3,
                (_) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: SkeletonBox(height: 72, borderRadius: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Chart placeholder
            const SkeletonBox(height: 180, borderRadius: 12),
            const SizedBox(height: 24),
            // Detail rows
            for (var i = 0; i < 4; i++) ...[
              const _SkeletonDetailRow(),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

/// Skeleton for a zone / settings list.
class SkeletonZoneList extends StatelessWidget {
  const SkeletonZoneList({super.key, this.rows = 5});

  final int rows;

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBox(width: 120, height: 14),
            const SizedBox(height: 16),
            for (var i = 0; i < rows; i++) ...[
              Row(
                children: [
                  const SkeletonBox(width: 56, height: 20),
                  const SizedBox(width: 12),
                  const Expanded(child: SkeletonBox(height: 20)),
                  const SizedBox(width: 12),
                  const Expanded(child: SkeletonBox(height: 20)),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBox(width: 160, height: 18),
            const SizedBox(height: 12),
            const SkeletonBox(height: 14),
            const SizedBox(height: 8),
            SkeletonBox(
              width: MediaQuery.of(context).size.width * 0.6,
              height: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonDetailRow extends StatelessWidget {
  const _SkeletonDetailRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SkeletonBox(width: 100, height: 14),
        Spacer(),
        SkeletonBox(width: 60, height: 14),
      ],
    );
  }
}
