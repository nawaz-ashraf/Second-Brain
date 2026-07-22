# Development Rules

## Code Style

1. **No TODO comments** in production code
2. **No placeholder implementations** - every function must work
3. **Single responsibility** - one purpose per class/function
4. **Meaningful names** - `fetchRecentNotes()` not `getData()`
5. **Max file length** - 300 lines per file (split if larger)
6. **Max function length** - 40 lines (extract helpers)

## Dart Rules

- Use `const` constructors wherever possible
- Prefer `final` variables
- Use named parameters for functions with 2+ params
- Never use `dynamic` - always type everything
- Use `sealed` classes for exhaustive state modeling
- Use `extension` for utilities on existing types

## Flutter Rules

- Never call `setState` inside a `build` method
- Use `const` widgets aggressively
- Extract widgets into separate classes (not functions)
- Always provide `key` to stateful widgets in lists
- Use `RepaintBoundary` around complex animations
- Dispose controllers in `dispose()`

## Riverpod Rules

- Never expose mutable state directly
- Use `ref.listen` for side effects, not `ref.watch`
- Invalidate providers after mutations
- Use `AsyncValue.guard` for error handling

## Database Rules

- All queries go through DAOs
- All DAOs go through Repositories
- Never access the database from widgets directly
- Use streams for reactive UI updates
- Index columns used in WHERE clauses

## Testing Rules

- Every repository must have unit tests
- Every provider must have unit tests
- Use `ProviderContainer` for isolated provider tests
- Use `InMemoryDatabase` for DAO tests

## Git Rules

- Commit frequently (every logical unit of work)
- Branch naming: `feature/`, `fix/`, `refactor/`
- PR titles: `feat:`, `fix:`, `refactor:`, `docs:`

## Performance Rules

- Use `ListView.builder` not `ListView` for large lists
- Cache expensive computations
- Use `RepaintBoundary` for complex static widgets
- Keep build methods simple - move logic to providers
- Use `Selector` or `.select()` to narrow rebuilds
