# Contributing to AgriEtech Flutter App

## Getting Started

1. Clone this repository
2. Ensure Flutter SDK >= 3.0.0 is installed (`flutter --version`)
3. Run `flutter pub get` to install all dependencies
4. Copy `.env.example` to `.env` and configure your local environment
5. Run the app: `flutter run`

## Project Structure

```
lib/
├── core/            # Cross-cutting infrastructure
│   ├── config/      # Environment, theme, constants
│   ├── network/     # Dio HTTP client & interceptors
│   ├── router/      # GoRouter navigation configuration
│   ├── storage/     # Hive offline cache & secure storage
│   ├── l10n/        # Amharic & English localization (ARB files)
│   └── widgets/     # Reusable UI components
├── features/        # Feature-first vertical slices
│   └── <feature>/
│       ├── data/
│       │   ├── models/       # Data transfer objects (JSON serializable)
│       │   └── repositories/ # API calls + local cache orchestration
│       ├── domain/           # Business logic services
│       └── presentation/
│           ├── providers/    # Riverpod state notifiers
│           ├── screens/      # Full-page screen widgets
│           └── widgets/      # Feature-specific UI components
└── shared/          # Cross-feature extensions and models
```

## Development Workflow

### Branch Naming Convention
- `feature/<feature-name>` — New feature (e.g., `feature/drought-gauge`)
- `fix/<issue-id>` — Bug fixes
- `ui/<screen-name>` — UI/UX improvements

### Commit Message Format
```
<type>(<scope>): <subject>

Types: feat, fix, ui, docs, refactor, test, chore
Scope: auth, weather, drought, farms, maps, l10n, etc.
```

### Code Style
- Run `flutter analyze` before committing — must pass with zero issues
- Follow [Effective Dart](https://dart.dev/effective-dart) guidelines
- All files must include `///` doc comment headers with `@file` and `@description`
- Use `snake_case` for file names and directory names
- Use `PascalCase` for class names
- Use `camelCase` for variable and function names

### Code Generation
After modifying `@freezed` or `@JsonSerializable` annotated models:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Testing
- Write tests in `test/` mirroring the `lib/` structure
- Run tests with `flutter test`
- Widget tests required for all screen files

## Pull Request Checklist

- [ ] `flutter analyze` passes with zero issues
- [ ] Doc comment headers are complete (`@file`, `@description`)
- [ ] File and folder names use `snake_case`
- [ ] Widget tests written for new screens
- [ ] Localization strings added to both `app_en.arb` and `app_am.arb`
- [ ] No hardcoded strings in UI — all text uses localization keys
