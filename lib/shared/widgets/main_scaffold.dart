import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/routes/app_router.dart';
import 'expandable_fab.dart';

/// Main scaffold with animated bottom navigation bar and expandable FAB
class MainScaffold extends StatefulWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  static const _destinations = [
    _NavDestination(
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      path: AppRoutes.home,
    ),
    _NavDestination(
      label: 'Collections',
      icon: Icons.folder_outlined,
      activeIcon: Icons.folder_rounded,
      path: AppRoutes.collections,
    ),
    _NavDestination(
      label: 'Search',
      icon: Icons.search_outlined,
      activeIcon: Icons.search_rounded,
      path: AppRoutes.search,
    ),
    _NavDestination(
      label: 'Favorites',
      icon: Icons.star_outline_rounded,
      activeIcon: Icons.star_rounded,
      path: AppRoutes.favorites,
    ),
    _NavDestination(
      label: 'Settings',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      path: AppRoutes.settings,
    ),
  ];

  void _onDestinationSelected(int index) {
    if (_selectedIndex == index) return;
    HapticFeedback.selectionClick();
    setState(() => _selectedIndex = index);
    context.go(_destinations[index].path);
  }

  @override
  Widget build(BuildContext context) {
    // Sync selected index to current route
    final location = GoRouterState.of(context).uri.toString();
    _syncIndex(location);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: _AnimatedBottomNav(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: _destinations,
      ),
      floatingActionButton: ExpandableFab(
        onNoteSelected: () => context.push(
          AppRoutes.noteEditor,
        ),
        onDocumentSelected: () => context.push(AppRoutes.documents),
        onImageSelected: () => context.push(AppRoutes.images),
        onVoiceSelected: () => context.push(AppRoutes.voice),
        onBookmarkSelected: () => _showAddBookmarkSheet(context),
        onCollectionSelected: () => _showCreateCollectionSheet(context),
      ),
    );
  }

  void _syncIndex(String location) {
    int idx = 0;
    if (location.startsWith(AppRoutes.collections) && !location.contains('/collections/')) {
      idx = 1;
    } else if (location == AppRoutes.search) {
      idx = 2;
    } else if (location == AppRoutes.favorites) {
      idx = 3;
    } else if (location == AppRoutes.settings) {
      idx = 4;
    }
    if (_selectedIndex != idx) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedIndex = idx);
      });
    }
  }

  void _showAddBookmarkSheet(BuildContext context) {
    context.push(AppRoutes.bookmarks);
  }

  void _showCreateCollectionSheet(BuildContext context) {
    context.push(AppRoutes.collections);
  }
}

class _AnimatedBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<_NavDestination> destinations;

  const _AnimatedBottomNav({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: destinations
          .map(
            (d) => NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.activeIcon),
              label: d.label,
            ),
          )
          .toList(),
    );
  }
}

class _NavDestination {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String path;

  const _NavDestination({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.path,
  });
}
