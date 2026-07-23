import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'dart:convert';
import '../../../../core/models/app_models.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

/// Note editor screen with rich text editing, auto-save, pin, favorite, color
class NoteEditorScreen extends ConsumerStatefulWidget {
  final String? noteId;
  final String? collectionId;

  const NoteEditorScreen({super.key, this.noteId, this.collectionId});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late final QuillController _quillController;
  late final TextEditingController _titleController;
  late final FocusNode _editorFocusNode;
  late final FocusNode _titleFocusNode;

  NoteModel? _existingNote;
  bool _isLoading = true;
  bool _isDirty = false;
  bool _isPinned = false;
  bool _isFavorite = false;
  int _selectedColor = 0;
  Timer? _autoSaveTimer;
  int _wordCount = 0;

  @override
  void initState() {
    super.initState();
    _quillController = QuillController.basic();
    _titleController = TextEditingController();
    _editorFocusNode = FocusNode();
    _titleFocusNode = FocusNode();

    _quillController.addListener(_onEditorChanged);
    _titleController.addListener(_onEditorChanged);

    if (widget.noteId != null) {
      _loadNote();
    } else {
      setState(() => _isLoading = false);
      // Auto-focus title for new notes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _titleFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _quillController.removeListener(_onEditorChanged);
    _quillController.dispose();
    _titleController.dispose();
    _editorFocusNode.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadNote() async {
    final note = await ref
        .read(notesRepositoryProvider)
        .getById(widget.noteId!);

    if (note != null && mounted) {
      _existingNote = note;
      _titleController.text = note.title;
      _isPinned = note.isPinned;
      _isFavorite = note.isFavorite;
      _selectedColor = note.color;
      _wordCount = note.wordCount;

      if (note.contentJson != null && note.contentJson!.isNotEmpty) {
        try {
          final decoded = jsonDecode(note.contentJson!) as List;
          final doc = Document.fromJson(decoded);
          _quillController.document = doc;
        } catch (_) {
          // If JSON parse fails, just set plain text
          final doc = Document();
          if (note.contentPlain != null && note.contentPlain!.isNotEmpty) {
            doc.insert(0, note.contentPlain!);
          }
          _quillController.document = doc;
        }
      } else if (note.contentPlain != null && note.contentPlain!.isNotEmpty) {
        final doc = Document();
        doc.insert(0, note.contentPlain!);
        _quillController.document = doc;
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _onEditorChanged() {
    if (!_isDirty) setState(() => _isDirty = true);

    // Count words
    final plain = _quillController.document.toPlainText();
    final count = plain.trim().isEmpty
        ? 0
        : plain.trim().split(RegExp(r'\s+')).length;
    if (count != _wordCount) setState(() => _wordCount = count);

    // Schedule auto-save
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(
      const Duration(seconds: 2),
      () => _save(showFeedback: false),
    );
  }

  Future<void> _save({bool showFeedback = true}) async {
    if (!_isDirty) return;

    final title = _titleController.text.trim();
    final doc = _quillController.document;
    final plainText = doc.toPlainText().trim();
    final contentJsonStr = jsonEncode(doc.toDelta().toJson());

    // Don't save empty notes (unless they already exist)
    if (title.isEmpty && plainText.isEmpty && widget.noteId == null) return;

    try {
      if (_existingNote != null) {
        // Update existing note
        await ref.read(notesRepositoryProvider).update(
          _existingNote!.copyWith(
            title: title.isEmpty ? 'Untitled' : title,
            contentJson: contentJsonStr,
            contentPlain: plainText,
            color: _selectedColor,
            isPinned: _isPinned,
            isFavorite: _isFavorite,
            updatedAt: DateTime.now(),
          ),
        );
      } else {
        // Create new note
        final note = await ref.read(notesRepositoryProvider).create(
          title: title.isEmpty ? 'Untitled' : title,
          contentJson: contentJsonStr,
          contentPlain: plainText,
          color: _selectedColor,
          isPinned: _isPinned,
        );
        if (mounted) {
          _existingNote = note;
        }
        
        // Link to collection if requested
        if (widget.collectionId != null) {
          await ref.read(collectionsRepositoryProvider).addItem(
            widget.collectionId!,
            note.id,
            'note',
          );
        }
      }

      if (mounted) setState(() => _isDirty = false);

      if (showFeedback && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note saved')),
        );
      }
    } catch (e) {
      if (showFeedback && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving note: $e')),
        );
      }
    }
  }

  Future<void> _delete() async {
    if (_existingNote == null) {
      context.pop();
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(notesRepositoryProvider).delete(_existingNote!.id);
      if (mounted) context.pop();
    }
  }

  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppTheme.spaceLG),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Card Color',
              style: Theme.of(ctx).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: AppConstants.noteColors.map((colorVal) {
                final isSelected = _selectedColor == colorVal;
                final color = colorVal == 0
                    ? Colors.grey.shade200
                    : Color(colorVal);
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedColor = colorVal);
                    Navigator.pop(ctx);
                    _onEditorChanged();
                  },
                  child: AnimatedContainer(
                    duration: AppConstants.animationFast,
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(ctx).colorScheme.primary,
                              width: 3,
                            )
                          : Border.all(
                              color: Colors.grey.withOpacity(0.3),
                            ),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: colorVal == 0 ? Colors.black : Colors.black87,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppTheme.spaceLG),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    Color bgColor;
    if (_selectedColor == 0) {
      bgColor = theme.colorScheme.surface;
    } else {
      final colors = isDark ? AppColors.darkNoteCardColors : AppColors.noteCardColors;
      final idx = AppColors.noteCardColors.indexWhere((c) => c.value == _selectedColor);
      bgColor = idx >= 0 ? colors[idx] : Color(_selectedColor);
    }

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: bgColor == Colors.transparent ? theme.colorScheme.surface : bgColor,
      appBar: AppBar(
        backgroundColor: bgColor == Colors.transparent ? null : bgColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () async {
            await _save(showFeedback: false);
            if (mounted) context.pop();
          },
        ),
        actions: [
          // Pin
          IconButton(
            icon: Icon(
              _isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
              color: _isPinned ? theme.colorScheme.primary : null,
            ),
            onPressed: () {
              setState(() => _isPinned = !_isPinned);
              _onEditorChanged();
            },
            tooltip: _isPinned ? 'Unpin' : 'Pin',
          ),

          // Favorite
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: _isFavorite ? Colors.amber : null,
            ),
            onPressed: () {
              setState(() => _isFavorite = !_isFavorite);
              _onEditorChanged();
            },
            tooltip: _isFavorite ? 'Unfavorite' : 'Favorite',
          ),

          // Color
          IconButton(
            icon: const Icon(Icons.color_lens_outlined),
            onPressed: _showColorPicker,
            tooltip: 'Card Color',
          ),

          // More actions
          PopupMenuButton<String>(
            shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMedium),
            onSelected: (val) {
              if (val == 'delete') _delete();
              if (val == 'save') _save();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'save',
                child: Row(
                  children: [
                    Icon(Icons.save_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Save'),
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
      body: Column(
        children: [
          // Title field
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: TextField(
              controller: _titleController,
              focusNode: _titleFocusNode,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _editorFocusNode.requestFocus(),
            ),
          ),

          // Word count & date
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Row(
              children: [
                Text(
                  _wordCount > 0 ? '$_wordCount words · ' : '',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                  ),
                ),
                Text(
                  _existingNote != null
                      ? 'Edited just now'
                      : 'New note',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                  ),
                ),
                if (_isDirty) ...[
                  const SizedBox(width: 6),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Editor
          Expanded(
            child: GestureDetector(
              onTap: () => _editorFocusNode.requestFocus(),
              child: QuillEditor.basic(
                controller: _quillController,
                focusNode: _editorFocusNode,
                config: QuillEditorConfig(
                  placeholder: 'Start writing...',
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  autoFocus: widget.noteId == null ? false : false,
                  scrollable: true,
                  expands: true,
                ),
              ),
            ),
          ),

          const Divider(height: 1),

          // Quill Toolbar (at bottom)
          QuillSimpleToolbar(
            controller: _quillController,
            config: QuillSimpleToolbarConfig(
              showBoldButton: true,
              showItalicButton: true,
              showUnderLineButton: true,
              showListBullets: true,
              showListNumbers: true,
              showListCheck: true,
              showCodeBlock: true,
              showQuote: true,
              showLink: false,
              showSearchButton: false,
              showSubscript: false,
              showSuperscript: false,
              showHeaderStyle: true,
              showDividers: true,
              showFontFamily: false,
              showFontSize: false,
              showBackgroundColorButton: false,
              showColorButton: false,
              showClearFormat: true,
              showAlignmentButtons: false,
              showLeftAlignment: false,
              showCenterAlignment: false,
              showRightAlignment: false,
              showJustifyAlignment: false,
              showDirection: false,
              showStrikeThrough: true,
              showInlineCode: true,
              toolbarIconAlignment: WrapAlignment.start,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
