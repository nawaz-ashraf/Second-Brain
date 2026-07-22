import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

/// Sort and filter bar with view mode toggle
class SortFilterBar extends StatelessWidget {
  final SortOrder currentSort;
  final ViewMode viewMode;
  final ValueChanged<SortOrder> onSortChanged;
  final VoidCallback onViewModeToggled;
  final List<String>? filterOptions;
  final String? selectedFilter;
  final ValueChanged<String?>? onFilterChanged;

  const SortFilterBar({
    super.key,
    required this.currentSort,
    required this.viewMode,
    required this.onSortChanged,
    required this.onViewModeToggled,
    this.filterOptions,
    this.selectedFilter,
    this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLG, vertical: 8),
      child: Row(
        children: [
          // Sort button
          _SortButton(
            currentSort: currentSort,
            onChanged: onSortChanged,
          ),

          if (filterOptions != null) ...[
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: filterOptions!.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (context, i) {
                    final filter = filterOptions![i];
                    final isSelected = selectedFilter == filter;
                    return FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (val) {
                        onFilterChanged?.call(val ? filter : null);
                      },
                      visualDensity: VisualDensity.compact,
                    );
                  },
                ),
              ),
            ),
          ] else
            const Spacer(),

          const SizedBox(width: 8),

          // View toggle
          AnimatedSwitcher(
            duration: AppConstants.animationFast,
            child: IconButton.outlined(
              key: ValueKey(viewMode),
              onPressed: onViewModeToggled,
              icon: Icon(
                viewMode == ViewMode.grid
                    ? Icons.view_list_rounded
                    : Icons.grid_view_rounded,
                size: 20,
              ),
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: AppTheme.radiusSmall,
                ),
                padding: const EdgeInsets.all(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  final SortOrder currentSort;
  final ValueChanged<SortOrder> onChanged;

  const _SortButton({required this.currentSort, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SortOrder>(
      initialValue: currentSort,
      onSelected: onChanged,
      shape: RoundedRectangleBorder(
        borderRadius: AppTheme.radiusMedium,
      ),
      itemBuilder: (context) => SortOrder.values
          .map(
            (order) => PopupMenuItem(
              value: order,
              child: Row(
                children: [
                  Icon(
                    _iconForSort(order),
                    size: 18,
                    color: order == currentSort
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(order.displayName),
                ],
              ),
            ),
          )
          .toList(),
      child: Chip(
        avatar: const Icon(Icons.sort_rounded, size: 16),
        label: Text(
          currentSort.displayName,
          style: const TextStyle(fontSize: 12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  IconData _iconForSort(SortOrder order) {
    switch (order) {
      case SortOrder.newest: return Icons.schedule_rounded;
      case SortOrder.oldest: return Icons.history_rounded;
      case SortOrder.alphabetical: return Icons.sort_by_alpha_rounded;
      case SortOrder.reverseAlphabetical: return Icons.sort_by_alpha_rounded;
      case SortOrder.modified: return Icons.edit_calendar_rounded;
      case SortOrder.favorites: return Icons.star_rounded;
    }
  }
}
