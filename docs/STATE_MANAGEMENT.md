# State Management

## Library: Riverpod 2.x

### Provider Types Used

| Provider | Usage |
|---|---|
| `Provider` | Simple sync values, theme, router |
| `StreamProvider` | Database reactive streams |
| `AsyncNotifierProvider` | Async operations with state |
| `NotifierProvider` | Sync state with mutations |
| `FutureProvider` | One-shot async reads |

---

## File Naming Convention

```
features/<feature>/providers/<feature>_provider.dart
```

---

## Pattern: AsyncNotifier

```dart
@riverpod
class NotesNotifier extends _$NotesNotifier {
  @override
  Future<List<Note>> build() async {
    return ref.watch(notesRepositoryProvider).watchAll().first;
  }

  Future<void> createNote(CreateNoteRequest req) async {
    await ref.read(notesRepositoryProvider).create(req);
    ref.invalidateSelf();
  }
}
```

---

## Pattern: StreamProvider (reactive)

```dart
@riverpod
Stream<List<Note>> notesStream(NotesStreamRef ref) {
  return ref.watch(notesRepositoryProvider).watchAll();
}
```

---

## ProviderScope

All providers are scoped under `ProviderScope` in `main.dart`.

---

## Dependency Injection

Repositories are provided via `riverpod`:

```dart
@riverpod
NotesRepository notesRepository(NotesRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return NotesRepositoryImpl(db.notesDao);
}
```

---

## Optimizations

- Use `select()` to avoid unnecessary rebuilds
- Use `ref.listen` for side effects (snackbars)
- Use `keepAlive()` for expensive providers
- Use `family` for parameterized providers
