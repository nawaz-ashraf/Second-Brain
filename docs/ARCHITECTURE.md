# Architecture

## Pattern: Feature-First Clean Architecture

```
lib/
├── core/                    # Infrastructure layer
│   ├── constants/           # App-wide constants
│   ├── database/            # Drift DB setup
│   │   ├── tables/          # Table definitions
│   │   └── daos/            # Data Access Objects
│   ├── models/              # Domain models (Freezed)
│   ├── repositories/        # Data layer abstractions
│   ├── services/            # Business logic services
│   ├── theme/               # Material 3 theming
│   └── routes/              # go_router configuration
├── features/                # Feature modules
│   ├── home/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   └── widgets/
│   │   └── providers/
│   ├── notes/
│   ├── documents/
│   ├── images/
│   ├── voice/
│   ├── bookmarks/
│   ├── collections/
│   ├── search/
│   ├── favorites/
│   └── settings/
└── shared/
    ├── widgets/             # Reusable UI components
    └── extensions/          # Dart extensions
```

## Layers

### Presentation Layer (features/*/presentation)
- Flutter widgets, screens, animations
- Consumes Riverpod providers
- No direct database access

### Provider Layer (features/*/providers)
- Riverpod providers and notifiers
- Orchestrates repositories
- Handles UI state

### Repository Layer (core/repositories)
- Abstract interfaces + Drift implementations
- Data transformation (table rows → domain models)

### Database Layer (core/database)
- Drift DAOs (queries)
- Drift Tables (schema)

## Dependency Flow

```
Widget → Provider → Repository → DAO → Drift → SQLite
```

## State Management

Riverpod 2.x with:
- `@riverpod` code generation
- `AsyncNotifierProvider` for async operations
- `StreamProvider` for reactive database streams
- `Provider` for simple computed values

## Future-Ready Design

The repository interfaces allow swapping implementations:
- Local Drift → Firebase (cloud sync)
- Add auth layer above providers
- Add AI service layer without changing UI
