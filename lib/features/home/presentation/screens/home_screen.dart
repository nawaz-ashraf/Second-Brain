import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/home_provider.dart';
import '../../../../core/routes/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/loading_state.dart';
import '../widgets/home_greeting.dart';
import '../widgets/quick_action_cards.dart';
import '../widgets/recent_items_section.dart';
import '../widgets/collections_preview.dart';
import '../widgets/storage_summary.dart';

/// Home screen — beautiful dashboard with greeting, quick actions, recents, collections
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final homeState = ref.watch(homeProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── Sliver App Bar ─────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            pinned: false,
            snap: true,
            elevation: 0,
            backgroundColor: theme.colorScheme.surface,
            titleSpacing: 0,
            title: Padding(
              padding: const EdgeInsets.only(left: AppTheme.spaceLG),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '🧠 Second Brain',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded),
                onPressed: () => context.go(AppRoutes.search),
                tooltip: 'Search',
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
                tooltip: 'Notifications',
              ),
              const SizedBox(width: 8),
            ],
          ),

          // ─── Greeting ──────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spaceLG,
              AppTheme.spaceSM,
              AppTheme.spaceLG,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: const HomeGreeting().animate().fadeIn(
                    duration: 400.ms,
                    curve: Curves.easeOut,
                  ),
            ),
          ),

          // ─── Quick Action Cards ────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spaceLG,
              AppTheme.spaceXL,
              AppTheme.spaceLG,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceMD),
                  const QuickActionCards(),
                ],
              )
                  .animate()
                  .slideY(
                    begin: 0.1,
                    duration: 400.ms,
                    delay: 100.ms,
                    curve: Curves.easeOut,
                  )
                  .fadeIn(duration: 400.ms, delay: 100.ms),
            ),
          ),

          // ─── Recent Items ──────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spaceLG,
              AppTheme.spaceXL,
              AppTheme.spaceLG,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Recent',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.search),
                        child: const Text('See all'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spaceMD),
                  const RecentItemsSection(),
                ],
              )
                  .animate()
                  .slideY(
                    begin: 0.1,
                    duration: 400.ms,
                    delay: 200.ms,
                    curve: Curves.easeOut,
                  )
                  .fadeIn(duration: 400.ms, delay: 200.ms),
            ),
          ),

          // ─── Collections Preview ───────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spaceLG,
              AppTheme.spaceXL,
              AppTheme.spaceLG,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Collections',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.collections),
                        child: const Text('See all'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spaceMD),
                  const CollectionsPreview(),
                ],
              )
                  .animate()
                  .slideY(
                    begin: 0.1,
                    duration: 400.ms,
                    delay: 300.ms,
                    curve: Curves.easeOut,
                  )
                  .fadeIn(duration: 400.ms, delay: 300.ms),
            ),
          ),

          // ─── Storage Summary ───────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spaceLG,
              AppTheme.spaceXL,
              AppTheme.spaceLG,
              AppTheme.spaceXXXL,
            ),
            sliver: SliverToBoxAdapter(
              child: const StorageSummary()
                  .animate()
                  .slideY(
                    begin: 0.1,
                    duration: 400.ms,
                    delay: 400.ms,
                    curve: Curves.easeOut,
                  )
                  .fadeIn(duration: 400.ms, delay: 400.ms),
            ),
          ),
        ],
      ),
    );
  }
}
