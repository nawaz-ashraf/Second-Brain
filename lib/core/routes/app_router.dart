import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/notes/presentation/screens/notes_list_screen.dart';
import '../../features/notes/presentation/screens/note_editor_screen.dart';
import '../../features/documents/presentation/screens/documents_screen.dart';
import '../../features/documents/presentation/screens/document_viewer_screen.dart';
import '../../features/images/presentation/screens/images_screen.dart';
import '../../features/images/presentation/screens/image_viewer_screen.dart';
import '../../features/voice/presentation/screens/voice_notes_screen.dart';
import '../../features/bookmarks/presentation/screens/bookmarks_screen.dart';
import '../../features/collections/presentation/screens/collections_screen.dart';
import '../../features/collections/presentation/screens/collection_detail_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/trash_screen.dart';
import '../../features/settings/presentation/screens/legal_document_screen.dart';
import '../../shared/widgets/main_scaffold.dart';

/// Route names
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String notes = '/notes';
  static const String noteEditor = '/notes/editor';
  static const String documents = '/documents';
  static const String documentViewer = '/documents/viewer';
  static const String images = '/images';
  static const String imageViewer = '/images/viewer';
  static const String voice = '/voice';
  static const String bookmarks = '/bookmarks';
  static const String collections = '/collections';
  static const String collectionDetail = '/collections/:id';
  static const String search = '/search';
  static const String favorites = '/favorites';
  static const String settings = '/settings';
  static const String trash = '/trash';
  static const String privacyPolicy = '/privacy-policy';
  static const String termsOfService = '/terms-of-service';
}

/// Global go_router configuration
final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  debugLogDiagnostics: false,
  routes: [
    // ─── Shell route for bottom navigation ─────────────────────────────────
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          pageBuilder: (context, state) => _fadePage(
            state,
            const HomeScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.collections,
          pageBuilder: (context, state) => _fadePage(
            state,
            const CollectionsScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.search,
          pageBuilder: (context, state) => _fadePage(
            state,
            const SearchScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.favorites,
          pageBuilder: (context, state) => _fadePage(
            state,
            const FavoritesScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.settings,
          pageBuilder: (context, state) => _fadePage(
            state,
            const SettingsScreen(),
          ),
        ),
      ],
    ),

    // ─── Top-level routes (full screen, no shell) ──────────────────────────
    GoRoute(
      path: AppRoutes.notes,
      pageBuilder: (context, state) => _slidePage(
        state,
        const NotesListScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.noteEditor,
      pageBuilder: (context, state) {
        final noteId = state.uri.queryParameters['id'];
        final collectionId = state.uri.queryParameters['collectionId'];
        return _slidePage(
          state,
          NoteEditorScreen(noteId: noteId, collectionId: collectionId),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.documents,
      pageBuilder: (context, state) => _slidePage(
        state,
        const DocumentsScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.documentViewer,
      pageBuilder: (context, state) {
        final docId = state.uri.queryParameters['id'] ?? '';
        return _slidePage(
          state,
          DocumentViewerScreen(documentId: docId),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.images,
      pageBuilder: (context, state) => _slidePage(
        state,
        const ImagesScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.imageViewer,
      pageBuilder: (context, state) {
        final imageId = state.uri.queryParameters['id'] ?? '';
        return _slidePage(
          state,
          ImageViewerScreen(imageId: imageId),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.voice,
      pageBuilder: (context, state) {
        final collectionId = state.uri.queryParameters['collectionId'];
        return _slidePage(
          state,
          VoiceNotesScreen(collectionId: collectionId),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.bookmarks,
      pageBuilder: (context, state) => _slidePage(
        state,
        const BookmarksScreen(),
      ),
    ),
    GoRoute(
      path: '/collections/:id',
      pageBuilder: (context, state) {
        final collectionId = state.pathParameters['id'] ?? '';
        return _slidePage(
          state,
          CollectionDetailScreen(collectionId: collectionId),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.trash,
      pageBuilder: (context, state) => _slidePage(
        state,
        const TrashScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.privacyPolicy,
      pageBuilder: (context, state) => _slidePage(
        state,
        const LegalDocumentScreen(
          title: 'Privacy Policy',
          content: privacyPolicyContent,
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.termsOfService,
      pageBuilder: (context, state) => _slidePage(
        state,
        const LegalDocumentScreen(
          title: 'Terms of Service',
          content: termsOfServiceContent,
        ),
      ),
    ),
  ],
);

/// Fade transition page
CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: child,
      );
    },
  );
}

/// Slide-up transition page
CustomTransitionPage<void> _slidePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation),
        child: FadeTransition(
          opacity: CurveTween(curve: Curves.easeIn).animate(animation),
          child: child,
        ),
      );
    },
  );
}
