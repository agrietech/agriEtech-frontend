# Screen Standard

A checklist every screen in `lib/features/**/screens/` must satisfy. It exists because
the app grew six independent inconsistencies — screens that hardcode English, invent their
own breakpoints, fetch inside `build`, or reimplement a loading spinner. Reuse the
utilities named here; do not add parallel ones.

Companion docs: [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md) for tokens,
[ARCHITECTURE.md](ARCHITECTURE.md) for layering.

## 1. Localize every user-visible string

Use the `BuildContext` extension in `lib/core/l10n/l10n_extension.dart`:

```dart
Text(context.tr('register_new_farm_plot'))
```

- `context.tr()` reads the `Localizations` scope, so a widget using it rebuilds when the
  locale changes. You do **not** need `ref.watch(appLocaleProvider)` for text.
- Watch `appLocaleProvider` only when you need the language *code* itself (for example
  `language_selector.dart`).
- Keys are `snake_case`. Add them via `tool/l10n_additions.json` and
  `python tool/insert_l10n.py`. **Never hand-edit the locale maps** in
  `app_localizations.dart` — the script is idempotent and keeps all five locales at parity.
- Every key must exist in all five locales (`en`, `am`, `om`, `ti`, `so`).
  `test/core/localization_parity_test.dart` enforces this and will fail the build otherwise.

Do **not** localize: log messages, route paths, API paths, JSON keys, `Key('…')` values,
the ` *` required-field marker, or established abbreviations (ET₀, RUSLE, Sentinel-1,
C-Band, WMO, UV).

## 2. Handle all four async states

Reuse the widgets in `lib/core/widgets/` — never a bare `CircularProgressIndicator`:

| State | Widget |
|---|---|
| Loading | `loading_indicator.dart`, or `shimmer_loading.dart` for list/card skeletons |
| Error | `error_view.dart` — must offer a retry |
| Empty | `empty_state_view.dart` |
| Content | the screen body |

## 3. Be responsive

Use `lib/core/utils/responsive.dart`:

```dart
if (context.isCompact) ...                                   // phone
crossAxisCount: context.responsive(compact: 2, expanded: 4)  // per size class
```

Breakpoints are the Material 3 window size classes: `compact` <600, `medium` 600–1023,
`expanded` ≥1024. Do not read `MediaQuery.of(context).size.width` and compare against a
literal — that is the pattern this helper replaces.

No fixed pixel widths on containers that hold text. Wide content (tables, charts, code)
scrolls inside its own horizontally-scrollable box; the page body never scrolls sideways.

## 4. Use tokens, not magic numbers

From `lib/core/theme/app_tokens.dart` (re-exported by `app_theme.dart`): `AppSpacing`,
`AppRadii`, `AppTypography`, `AppIconSize`, `AppShadows`, `AppDurations`, `AppCurves`.

Colors come from `Theme.of(context).colorScheme` or the semantic helpers in
`app_theme.dart`. No raw `Color(0xFF…)` in a screen — every screen must be legible in both
light and dark themes.

## 5. Be accessible

- Every icon-only control needs a `tooltip:` (on `IconButton` this also supplies the
  semantic label) or an explicit `Semantics(label: …)`.
- Tap targets get `AppTouchTarget.minConstraints` (48dp, WCAG 2.5.5).
- Meaningful images get `semanticLabel`; decorative ones are excluded from semantics.
- Never signal state by color alone — pair it with an icon or text.

## 6. Fetch through a repository

Screens must not call the network directly. Data flows
**screen → Riverpod provider → repository → `DioClient`**.

- Address endpoints only via `ApiConstants` — never an inline path string.
- **`DioClient` does not normalize errors.** Its `get`/`post`/`put`/`patch`/`delete` helpers
  are thin pass-throughs, so a failed call throws a raw `DioException` whose `toString()` is
  a technical dump. Map it before showing it to a user:

  ```dart
  final message = e is DioException
      ? NetworkError.fromDioException(e).message   // core/error/app_error.dart
      : e.toString();
  ```

  `NetworkError.fromDioException` pulls the server's own `message` out of the response body
  and falls back to friendly text for timeouts and connection failures. Prefer doing this in
  the repository so screens receive an `AppError` and never see Dio types.
- Every constant in `api_constants.dart` must correspond to a real mounted backend route;
  `test/core/api_contract_test.dart` checks this against the backend's route files.

Known exceptions still to be migrated: `risk/screens/soil_degradation_screen.dart`,
`risk/screens/seismology_detail_screen.dart`, `risk/screens/disaster_intelligence_screen.dart`,
and `analytics/screens/ussd_alert_console_screen.dart` fetch inline. Do not copy them.

## Reviewer checklist

- [ ] No user-visible string literal; all text via `context.tr()`
- [ ] New keys added through `tool/l10n_additions.json`, present in all 5 locales
- [ ] Loading, error (with retry), and empty states all handled by the shared widgets
- [ ] No literal breakpoint comparison; grids adapt via `context.responsive()`
- [ ] Spacing, radii, type, and color from tokens/theme only
- [ ] Icon-only controls have tooltips; tap targets ≥48dp
- [ ] No networking in the widget; paths via `ApiConstants`
- [ ] `flutter analyze` clean and `flutter test` green
