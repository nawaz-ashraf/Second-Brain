import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/models/app_models.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/loading_state.dart';

/// Voice notes screen — record, playback, list, and manage recordings
class VoiceNotesScreen extends ConsumerStatefulWidget {
  const VoiceNotesScreen({super.key});

  @override
  ConsumerState<VoiceNotesScreen> createState() => _VoiceNotesScreenState();
}

final _voiceNotesStreamProvider = StreamProvider.autoDispose<List<VoiceNoteModel>>((ref) {
  return ref.watch(voiceNotesRepositoryProvider).watchAll();
});

class _VoiceNotesScreenState extends ConsumerState<VoiceNotesScreen> {
  final _recorder = AudioRecorder();
  final _player = AudioPlayer();
  bool _isRecording = false;
  String? _currentlyPlayingId;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;

  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission required')),
        );
      }
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    final id = const Uuid().v4();
    final path = '${dir.path}/voice_$id.m4a';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000),
      path: path,
    );

    _recordingDuration = Duration.zero;
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _recordingDuration += const Duration(seconds: 1));
    });

    setState(() => _isRecording = true);
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    final path = await _recorder.stop();
    setState(() => _isRecording = false);

    if (path != null) {
      // Show rename dialog
      final title = await _showRenameDialog();
      final now = DateTime.now();
      final name = title ?? DateFormat('Recording MMM d, yyyy HH:mm').format(now);

      await ref.read(voiceNotesRepositoryProvider).create(
        title: name,
        filePath: path,
        durationMs: _recordingDuration.inMilliseconds,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Voice note saved')),
        );
      }
    }
  }

  Future<String?> _showRenameDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Name your recording'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Recording name'),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Skip'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final min = d.inMinutes.toString().padLeft(2, '0');
    final sec = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final voiceNotesAsync = ref.watch(_voiceNotesStreamProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Voice Notes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: Column(
        children: [
          // Recording card
          _RecordingCard(
            isRecording: _isRecording,
            duration: _recordingDuration,
            onStart: _startRecording,
            onStop: _stopRecording,
            formatDuration: _formatDuration,
          ),

          const Divider(height: 1),

          // Voice notes list
          Expanded(
            child: voiceNotesAsync.when(
              data: (voices) {
                if (voices.isEmpty) {
                  return const EmptyState(
                    icon: Icons.mic_none_rounded,
                    title: 'No voice notes',
                    subtitle: 'Tap the record button above to start',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  physics: const BouncingScrollPhysics(),
                  itemCount: voices.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _VoiceNoteCard(
                    voiceNote: voices[i],
                    player: _player,
                    isPlaying: _currentlyPlayingId == voices[i].id,
                    onPlayToggle: (id) async {
                      if (_currentlyPlayingId == id) {
                        await _player.stop();
                        setState(() => _currentlyPlayingId = null);
                      } else {
                        await _player.setFilePath(voices[i].filePath);
                        await _player.play();
                        setState(() => _currentlyPlayingId = id);
                      }
                    },
                  )
                      .animate(delay: (i * 30).ms)
                      .fadeIn(duration: 250.ms)
                      .slideY(
                        begin: 0.05,
                        duration: 250.ms,
                        curve: Curves.easeOut,
                      ),
                );
              },
              loading: () => const LoadingState(),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordingCard extends StatelessWidget {
  final bool isRecording;
  final Duration duration;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final String Function(Duration) formatDuration;

  const _RecordingCard({
    required this.isRecording,
    required this.duration,
    required this.onStart,
    required this.onStop,
    required this.formatDuration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceXL),
      child: Column(
        children: [
          // Duration display
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              key: ValueKey(isRecording),
              isRecording ? formatDuration(duration) : 'Ready to record',
              style: isRecording
                  ? theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.red,
                      letterSpacing: 2,
                    )
                  : theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
            ),
          ),

          const SizedBox(height: AppTheme.spaceXL),

          // Record button
          GestureDetector(
            onTap: isRecording ? onStop : onStart,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isRecording ? 72 : 80,
              height: isRecording ? 72 : 80,
              decoration: BoxDecoration(
                color: isRecording ? Colors.red : theme.colorScheme.primary,
                shape: isRecording ? BoxShape.rectangle : BoxShape.circle,
                borderRadius: isRecording ? BorderRadius.circular(16) : null,
                boxShadow: [
                  BoxShadow(
                    color: (isRecording ? Colors.red : theme.colorScheme.primary)
                        .withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),

          const SizedBox(height: AppTheme.spaceMD),

          Text(
            isRecording ? 'Tap to stop' : 'Tap to record',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _VoiceNoteCard extends ConsumerWidget {
  final VoiceNoteModel voiceNote;
  final AudioPlayer player;
  final bool isPlaying;
  final void Function(String) onPlayToggle;

  const _VoiceNoteCard({
    required this.voiceNote,
    required this.player,
    required this.isPlaying,
    required this.onPlayToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      decoration: BoxDecoration(
        borderRadius: AppTheme.radiusMedium,
        color: isPlaying
            ? theme.colorScheme.primaryContainer.withOpacity(0.3)
            : theme.colorScheme.surface,
        border: Border.all(
          color: isPlaying
              ? theme.colorScheme.primary.withOpacity(0.3)
              : theme.colorScheme.outline.withOpacity(0.12),
        ),
      ),
      child: Row(
        children: [
          // Play button
          GestureDetector(
            onTap: () => onPlayToggle(voiceNote.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isPlaying
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: isPlaying
                    ? Colors.white
                    : theme.colorScheme.onPrimaryContainer,
                size: 28,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  voiceNote.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      voiceNote.durationDisplay,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('MMM d').format(voiceNote.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Favorite and more
          if (voiceNote.isFavorite)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(Icons.star_rounded, size: 16, color: Colors.amber),
            ),

          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, size: 18),
            shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMedium),
            onSelected: (val) async {
              if (val == 'favorite') {
                await ref.read(voiceNotesRepositoryProvider).toggleFavorite(
                  voiceNote.id,
                  !voiceNote.isFavorite,
                );
              } else if (val == 'delete') {
                await ref.read(voiceNotesRepositoryProvider).delete(voiceNote.id);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'favorite',
                child: Row(
                  children: [
                    Icon(voiceNote.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text(voiceNote.isFavorite ? 'Unfavorite' : 'Favorite'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
