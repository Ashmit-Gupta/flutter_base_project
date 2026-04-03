# AI Reference Guide for OneAppMobile Flutter Project

## Project Overview
This is a Flutter base project template following Clean Architecture principles with Riverpod state management, feature-first modularization, and a comprehensive design system.

## Architecture Principles

### 1. Layered Architecture
- **App Layer** (`lib/app/`): Orchestration only (routing, theme, config). NO business logic.
- **Core Layer** (`lib/core/`): Shared infrastructure and abstractions. Feature-agnostic.
- **Features Layer** (`lib/features/`): Feature-specific business logic and UI.

### 2. Dependency Rules
- Features → Core (allowed)
- Core → App/Features (FORBIDDEN)
- App → Core (allowed, but minimal)

### 3. State Management Rules
- **Riverpod**: Single source of truth for app/feature state
- **Hooks**: ONLY for local UI state (controllers, toggles, animations)
- **NEVER** use hooks for business logic, API calls, or navigation

### 4. UI Rules
- Use `context.theme` for colors
- Use `context.text.*()` for typography (adaptive)
- Use `AppSpacing`, `AppRadius` for layout
- NEVER use hardcoded colors, fonts, or spacing
- Use `AdaptiveLayoutBuilder` for responsive layouts

### 5. Error Handling
- Use `Result<T>` type from `core/results/result.dart`
- Handle errors at repository level
- Display user-friendly messages via `AppSnackbar`
- Log errors via `AppLogger`

### 6. Navigation
- Use GoRouter with routes defined in `app/routes.dart`
- Routes are constants, not strings
- Auth-based redirects handled in router

### 7. Configuration
- Environment variables loaded from `.env` files
- AppConfig built from env vars
- Providers overridden in main.dart for bootstrap

### 8. Design System
- Token-based colors, typography, spacing
- Theme extensions for `context.theme` and `context.text`
- Material 3 components with custom styling

## Forbidden Patterns

### ❌ NEVER Use
- `MediaQuery.of(context)` directly (use `ScreenTypeScope`)
- `Theme.of(context)` directly (use `context.theme`)
- Hardcoded colors like `Colors.blue` (use `context.theme.colors.primary`)
- Hardcoded spacing like `SizedBox(height: 16)` (use `AppSpacing`)
- Business logic in widgets
- API calls in UI
- Global mutable state
- Deprecated Flutter APIs

### ❌ Deprecated APIs (DO NOT USE)
- `textScaleFactorOf` → use `textScalerOf`
- `withOpacity` → use `withValues`
- `groupValue`/`onChanged` in Radio → use RadioGroup
- `surfaceVariant` → use `surfaceContainerHighest`
- `useIsMounted` → use `BuildContext.mounted`

### ❌ Anti-Patterns
- God classes
- Tight coupling between features
- Business logic in UI
- Direct dependency injection (use Riverpod providers)
- Global variables
- Synchronous API calls in UI

## Code Structure Templates

### Feature Structure
```
features/my_feature/
├── domain/
│   ├── models/
│   ├── repositories/
│   └── services/
├── data/
│   ├── models/
│   ├── repositories/
│   └── sources/
├── presentation/
│   ├── providers/
│   ├── screens/
│   └── widgets/
└── README.md
```

### Provider Pattern
```dart
// Repository interface in domain
abstract class MyRepository {
  AsyncResult<List<Item>> getItems();
}

// Implementation in data
class MyRepositoryImpl implements MyRepository {
  // Implementation
}

// Provider in presentation/providers
final myRepositoryProvider = Provider<MyRepository>((ref) {
  return MyRepositoryImpl();
});

final myItemsProvider = FutureProvider<List<Item>>((ref) async {
  final repo = ref.watch(myRepositoryProvider);
  return repo.getItems().getOrElse((failure) => throw failure);
});
```

### Widget Pattern
```dart
class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(myItemsProvider);
    
    return Scaffold(
      body: items.when(
        data: (data) => ListView.builder(
          itemBuilder: (context, index) {
            return MyItemCard(item: data[index]);
          },
        ),
        loading: () => const CircularProgressIndicator(),
        error: (error, stack) => AppSnackbar.showError(
          context: context,
          message: 'Failed to load items',
        ),
      ),
    );
  }
}
```

### Hook Usage (ALLOWED ONLY)
```dart
class MyWidget extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ OK: UI controller
    final controller = useTextEditingController();
    
    // ✅ OK: UI toggle
    final isExpanded = useState(false);
    
    // ❌ WRONG: Business logic
    // final data = useState(await apiCall());
    
    return TextField(controller: controller);
  }
}
```

## Testing Patterns

### Unit Test
```dart
void main() {
  test('MyRepositoryImpl.getItems returns items', () async {
    final repo = MyRepositoryImpl();
    final result = await repo.getItems().run();
    expect(result.isRight(), true);
  });
}
```

### Widget Test
```dart
void main() {
  testWidgets('MyScreen displays items', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          myRepositoryProvider.overrideWithValue(MockRepository()),
        ],
        child: MaterialApp(home: MyScreen()),
      ),
    );
    
    expect(find.text('Item 1'), findsOneWidget);
  });
}
```

## Common Mistakes to Avoid

1. **Importing from wrong layer**: Core should not import from features
2. **Using hooks for business logic**: Hooks are UI-only
3. **Hardcoding values**: Everything configurable via providers
4. **Direct API calls in UI**: Use providers and repositories
5. **Ignoring error handling**: Always handle Result types
6. **Not using design system**: Always use context.theme and context.text
7. **Deep widget trees**: Use AdaptiveLayoutBuilder and modular widgets
8. **State in wrong place**: Business state in providers, UI state in hooks

## Performance Guidelines

- Use `ref.watch(provider.select(...))` for selective rebuilds
- Avoid unnecessary provider nesting
- Use `const` constructors where possible
- Prefer stateless widgets with providers
- Use `AsyncValue.when()` for loading states
- Cache expensive computations in providers

## Security Guidelines

- Never log sensitive data
- Use secure storage for tokens
- Validate all inputs
- Handle network errors gracefully
- Use HTTPS only
- Implement proper auth flows

## File Naming Conventions

- `snake_case.dart` for files
- `PascalCase` for classes
- `camelCase` for variables/methods
- `providerNameProvider` for Riverpod providers
- `featureName_screen.dart` for screens
- `featureName_provider.dart` for providers

## Commit Message Format

```
feat: add user authentication
fix: resolve login crash
docs: update README
refactor: extract common widget
test: add unit tests for repository
```

## Build Commands

```bash
# Development
flutter run --flavor dev

# Production
flutter run --flavor prod

# Tests
flutter test

# Analyze
flutter analyze

# Format
flutter format .
```

## Environment Variables

Required in `.env` files:
- `ENV`: dev/prod
- `API_BASE_URL`: API endpoint
- `CONNECT_TIMEOUT`: Connection timeout in seconds
- `RECEIVE_TIMEOUT`: Receive timeout in seconds
- `SEND_TIMEOUT`: Send timeout in seconds
- `ENABLE_LOGS`: true/false
- `ENABLE_CRASHLYTICS`: true/false

## Version Management

- Use semantic versioning (1.0.0)
- Update pubspec.yaml version
- Tag releases in git
- Update CHANGELOG.md

This guide ensures consistent, maintainable, and scalable code across the project.