import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_theme.dart';

/// Settings screen with theme, storage info, and app meta
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          // ─── Appearance ──────────────────────────────────────────────────
          _SectionHeader(label: 'Appearance'),
          _SettingsCard(
            children: [
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                    borderRadius: AppTheme.radiusMedium,
                  ),
                  child: Icon(Icons.palette_rounded, color: theme.colorScheme.primary, size: 20),
                ),
                title: const Text('Theme'),
                subtitle: Text(
                  themeMode == ThemeMode.system
                      ? 'System'
                      : themeMode == ThemeMode.dark
                          ? 'Dark'
                          : 'Light',
                ),
                trailing: PopupMenuButton<ThemeMode>(
                  initialValue: themeMode,
                  shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMedium),
                  onSelected: (mode) =>
                      ref.read(themeModeProvider.notifier).setTheme(mode),
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: ThemeMode.system,
                      child: Row(
                        children: [
                          Icon(Icons.brightness_auto_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('System'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: ThemeMode.light,
                      child: Row(
                        children: [
                          Icon(Icons.light_mode_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Light'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: ThemeMode.dark,
                      child: Row(
                        children: [
                          Icon(Icons.dark_mode_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Dark'),
                        ],
                      ),
                    ),
                  ],
                  child: Chip(
                    label: Text(
                      themeMode == ThemeMode.system
                          ? 'System'
                          : themeMode == ThemeMode.dark
                              ? 'Dark'
                              : 'Light',
                    ),
                    avatar: Icon(
                      themeMode == ThemeMode.system
                          ? Icons.brightness_auto_rounded
                          : themeMode == ThemeMode.dark
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spaceLG),

          // ─── Storage ─────────────────────────────────────────────────────
          _SectionHeader(label: 'Storage'),
          _SettingsCard(
            children: [
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: AppTheme.radiusMedium,
                  ),
                  child: const Icon(Icons.storage_rounded, color: Colors.blue, size: 20),
                ),
                title: const Text('Local Storage'),
                subtitle: const Text('All data stored on device'),
                trailing: const Icon(Icons.lock_rounded, size: 18, color: Colors.green),
              ),
              const Divider(height: 1, indent: 60),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: AppTheme.radiusMedium,
                  ),
                  child: const Icon(Icons.delete_sweep_rounded, color: Colors.red, size: 20),
                ),
                title: const Text('Clear Recent Searches'),
                onTap: () async {
                  await ref.read(recentSearchesProvider.notifier).clearAll();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Recent searches cleared')),
                    );
                  }
                },
              ),
            ],
          ),

        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppTheme.radiusLarge,
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.12),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}
