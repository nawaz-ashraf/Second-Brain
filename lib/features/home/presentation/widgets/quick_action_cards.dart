import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_theme.dart';

/// Quick action cards grid for the home screen
class QuickActionCards extends StatelessWidget {
  const QuickActionCards({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        label: 'Notes',
        icon: Icons.edit_note_rounded,
        color: const Color(0xFF4CAF50),
        count: null,
        onTap: () => context.push(AppRoutes.notes),
      ),
      _QuickAction(
        label: 'Documents',
        icon: Icons.description_rounded,
        color: const Color(0xFF2196F3),
        count: null,
        onTap: () => context.push(AppRoutes.documents),
      ),
      _QuickAction(
        label: 'Images',
        icon: Icons.image_rounded,
        color: const Color(0xFF009688),
        count: null,
        onTap: () => context.push(AppRoutes.images),
      ),
      _QuickAction(
        label: 'Voice',
        icon: Icons.mic_rounded,
        color: const Color(0xFFF44336),
        count: null,
        onTap: () => context.push(AppRoutes.voice),
      ),
      _QuickAction(
        label: 'Bookmarks',
        icon: Icons.bookmark_rounded,
        color: const Color(0xFFFF9800),
        count: null,
        onTap: () => context.push(AppRoutes.bookmarks),
      ),
      _QuickAction(
        label: 'Favorites',
        icon: Icons.star_rounded,
        color: const Color(0xFFFFC107),
        count: null,
        onTap: () => context.go(AppRoutes.favorites),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.1,
      ),
      itemCount: actions.length,
      itemBuilder: (context, i) {
        return actions[i]
            .animate(delay: (i * 50).ms)
            .scale(
              duration: 300.ms,
              curve: Curves.easeOutBack,
              begin: const Offset(0.8, 0.8),
            )
            .fadeIn(duration: 300.ms);
      },
    );
  }
}

class _QuickAction extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final int? count;
  final VoidCallback onTap;

  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    this.count,
    required this.onTap,
  });

  @override
  State<_QuickAction> createState() => _QuickActionState();
}

class _QuickActionState extends State<_QuickAction>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppTheme.radiusMedium,
            color: widget.color.withOpacity(0.12),
            border: Border.all(
              color: widget.color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  color: widget.color,
                  size: 22,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
