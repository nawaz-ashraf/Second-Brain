import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Loading skeleton widget for list and grid items
class LoadingState extends StatelessWidget {
  final int itemCount;
  final bool isGrid;

  const LoadingState({
    super.key,
    this.itemCount = 6,
    this.isGrid = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isGrid) {
      return GridView.builder(
        padding: const EdgeInsets.all(AppTheme.spaceLG),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: itemCount,
        itemBuilder: (_, i) => const _SkeletonCard(),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppTheme.spaceLG),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: AppTheme.spaceSM),
      itemBuilder: (_, i) => const _SkeletonListItem(),
    );
  }
}

class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard();

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: AppTheme.radiusMedium,
            color: Color.lerp(
              theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              theme.colorScheme.surfaceContainerHighest.withOpacity(0.6),
              _animation.value,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spaceMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: AppTheme.radiusSmall,
                    color: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: AppTheme.radiusSmall,
                    color: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SkeletonListItem extends StatefulWidget {
  const _SkeletonListItem();

  @override
  State<_SkeletonListItem> createState() => _SkeletonListItemState();
}

class _SkeletonListItemState extends State<_SkeletonListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final bg = Color.lerp(
          theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          theme.colorScheme.surfaceContainerHighest.withOpacity(0.6),
          _animation.value,
        )!;
        return Container(
          padding: const EdgeInsets.all(AppTheme.spaceLG),
          decoration: BoxDecoration(
            borderRadius: AppTheme.radiusMedium,
            color: bg,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: AppTheme.radiusMedium,
                  color: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      decoration: BoxDecoration(
                        borderRadius: AppTheme.radiusSmall,
                        color: theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 12,
                      width: 180,
                      decoration: BoxDecoration(
                        borderRadius: AppTheme.radiusSmall,
                        color: theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Full page loading indicator
class FullPageLoader extends StatelessWidget {
  final String? message;

  const FullPageLoader({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
            strokeWidth: 3,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}
