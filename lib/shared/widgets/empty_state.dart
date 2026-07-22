import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';

/// Reusable empty state widget with icon, title, and optional action
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceXXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: theme.colorScheme.primary.withOpacity(0.7),
              ),
            )
                .animate()
                .scale(duration: 400.ms, curve: Curves.easeOutBack)
                .fadeIn(duration: 300.ms),

            const SizedBox(height: AppTheme.spaceXL),

            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            )
                .animate(delay: 100.ms)
                .slideY(begin: 0.2, duration: 300.ms, curve: Curves.easeOut)
                .fadeIn(duration: 300.ms),

            if (subtitle != null) ...[
              const SizedBox(height: AppTheme.spaceSM),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              )
                  .animate(delay: 150.ms)
                  .slideY(begin: 0.2, duration: 300.ms, curve: Curves.easeOut)
                  .fadeIn(duration: 300.ms),
            ],

            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppTheme.spaceXL),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded),
                label: Text(actionLabel!),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spaceXL,
                    vertical: AppTheme.spaceMD,
                  ),
                  shape: const StadiumBorder(),
                ),
              )
                  .animate(delay: 200.ms)
                  .scale(
                    duration: 300.ms,
                    curve: Curves.easeOutBack,
                    begin: const Offset(0.8, 0.8),
                  )
                  .fadeIn(duration: 300.ms),
            ],
          ],
        ),
      ),
    );
  }
}
