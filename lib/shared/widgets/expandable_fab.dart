import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';

/// Expandable FAB with animated options for all content types
class ExpandableFab extends StatefulWidget {
  final VoidCallback onNoteSelected;
  final VoidCallback onDocumentSelected;
  final VoidCallback onImageSelected;
  final VoidCallback onVoiceSelected;
  final VoidCallback onBookmarkSelected;
  final VoidCallback onCollectionSelected;

  const ExpandableFab({
    super.key,
    required this.onNoteSelected,
    required this.onDocumentSelected,
    required this.onImageSelected,
    required this.onVoiceSelected,
    required this.onBookmarkSelected,
    required this.onCollectionSelected,
  });

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotateAnim;
  late final Animation<double> _scaleAnim;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _rotateAnim = Tween<double>(begin: 0, end: 0.375).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.mediumImpact();
    setState(() => _isOpen = !_isOpen);
    if (_isOpen) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _close() {
    if (_isOpen) _toggle();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isOpen) ...[
          _FabOption(
            icon: Icons.folder_outlined,
            label: 'Collection',
            color: Colors.deepPurple,
            scaleAnim: _scaleAnim,
            delay: 0,
            onTap: () {
              _close();
              widget.onCollectionSelected();
            },
          ),
          const SizedBox(height: 8),
          _FabOption(
            icon: Icons.bookmark_outline_rounded,
            label: 'Bookmark',
            color: Colors.orange,
            scaleAnim: _scaleAnim,
            delay: 30,
            onTap: () {
              _close();
              widget.onBookmarkSelected();
            },
          ),
          const SizedBox(height: 8),
          _FabOption(
            icon: Icons.mic_outlined,
            label: 'Voice Note',
            color: Colors.red,
            scaleAnim: _scaleAnim,
            delay: 60,
            onTap: () {
              _close();
              widget.onVoiceSelected();
            },
          ),
          const SizedBox(height: 8),
          _FabOption(
            icon: Icons.image_outlined,
            label: 'Image',
            color: Colors.teal,
            scaleAnim: _scaleAnim,
            delay: 90,
            onTap: () {
              _close();
              widget.onImageSelected();
            },
          ),
          const SizedBox(height: 8),
          _FabOption(
            icon: Icons.description_outlined,
            label: 'Document',
            color: Colors.blue,
            scaleAnim: _scaleAnim,
            delay: 120,
            onTap: () {
              _close();
              widget.onDocumentSelected();
            },
          ),
          const SizedBox(height: 8),
          _FabOption(
            icon: Icons.edit_note_rounded,
            label: 'Note',
            color: Theme.of(context).colorScheme.primary,
            scaleAnim: _scaleAnim,
            delay: 150,
            onTap: () {
              _close();
              widget.onNoteSelected();
            },
          ),
          const SizedBox(height: 12),
        ],

        // Main FAB
        FloatingActionButton(
          onPressed: _toggle,
          elevation: 4,
          child: AnimatedBuilder(
            animation: _rotateAnim,
            builder: (context, child) => Transform.rotate(
              angle: _rotateAnim.value * 2 * 3.14159,
              child: child,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _isOpen ? Icons.close_rounded : Icons.add_rounded,
                key: ValueKey(_isOpen),
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FabOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Animation<double> scaleAnim;
  final int delay;
  final VoidCallback onTap;

  const _FabOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.scaleAnim,
    required this.delay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScaleTransition(
      scale: scaleAnim,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label bubble
          Material(
            color: theme.colorScheme.surface,
            elevation: 2,
            borderRadius: AppTheme.radiusMedium,
            child: InkWell(
              onTap: onTap,
              borderRadius: AppTheme.radiusMedium,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Icon button
          Material(
            color: color,
            shape: const CircleBorder(),
            elevation: 2,
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(icon, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
