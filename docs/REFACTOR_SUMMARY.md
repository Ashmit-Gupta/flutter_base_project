# Adaptive Design System Refactor — Summary

## Issues found

1. **Duplicate / mixed typography**
   - `app/theme/app_text_styles.dart` had a second typography API (`body`, `heading` getters) and fixed sizes (14, 22).
   - `core/design/typography.dart` used **MediaQuery** in the `context.text` extension, breaking the rule that UI must not contain MediaQuery.

2. **Layout not driving typography**
   - Typography was derived from `MediaQuery.of(context).size.width` in the extension, so layout and breakpoints were not the single source of truth.

3. **Hardcoded sizes in UI**
   - Home used raw `SizedBox(height: 8)`, `EdgeInsets.all(16)`, `BorderRadius.circular(12)` instead of design tokens.

4. **No single adaptive layout wrapper**
   - `AdaptiveLayoutBuilder` existed but did not provide `ScreenType` (or equivalent) to the subtree, so typography could not be driven by layout without MediaQuery.

5. **App theme mixed colors + text styles**
   - `AppTheme` held `AppTextStyles` (legacy), leading to two typography sources (core vs theme).

6. **Home not adaptive**
   - Home had no `AdaptiveLayoutBuilder`, no mobile/tablet/desktop variants, and no use of a single typography system or design tokens.

---

## Changes applied

### Files deleted
- `lib/app/theme/app_text_styles.dart` — replaced by single typography in core/design.
- `lib/core/design/typography.dart` — replaced by `app_typography.dart` (no MediaQuery in extension).

### Files renamed
- None. New canonical typography file is `core/design/app_typography.dart` (old `typography.dart` removed, not renamed).

### Files created
- `lib/core/layout/screen_type_scope.dart` — `InheritedWidget` that provides `ScreenType` and `textScaleFactor` so UI never reads MediaQuery.
- `lib/core/design/app_typography.dart` — single adaptive typography (display, headline, title, body, label, caption) using `TypographyScale` and optional `textScaleFactor`.

### Files updated
- `lib/core/layout/adaptive_layout_builder.dart` — wraps result in `ScreenTypeScope` with `MediaQuery.textScaleFactorOf(context)` (only place MediaQuery is used). Graceful fallbacks: tablet → mobile, desktop → tablet → mobile.
- `lib/core/design/typography_scale.dart` — unchanged; mobile `maxFontSize: 20` already enforced.
- `lib/app/theme/app_theme.dart` — `text` (AppTextStyles) removed; now only `colors` and `fontFamily`. Typography comes from `context.text` (core/design).
- `lib/app/theme/app_theme_extension.dart` — `context.text` now uses `ScreenTypeScope.screenTypeOf(this)` and `textScaleFactorOf(this)` + theme `fontFamily` / `colors.textPrimary`; no MediaQuery.
- `lib/app/theme/light_theme_builder.dart` — `AppTheme(colors, fontFamily)` only.
- `lib/app/theme/dark_theme_builder.dart` — same.
- `lib/features/home_page.dart` — refactored: `HomeScreen` (ConsumerWidget) with `AdaptiveLayoutBuilder`; mobile/tablet/desktop layouts; `HomeContent` dumb; only `context.text.*()`, `AppSpacing`, `AppRadius`; theme toggle via Riverpod.

---

## Implementations (summary)

### One typography system
- **core/design/app_typography.dart**: `AppTypography` with `display()`, `headline()`, `title()`, `body()`, `label()`, `caption()`.
- **core/design/typography_scale.dart**: `TypographyScale.fromScreen(ScreenType)` — mobile max 20, tablet 28, desktop 36.
- **core/design/app_text_tokens.dart**: Base sizes (display 48, headline 32, title 20, body 16, label 14, caption 12); scaling/cap applied in `AppTypography`.
- Usage: `context.text.headline()`, `context.text.body()`, etc. (single API; method style everywhere).

### One breakpoint system
- **core/layout/breakpoints.dart**: `Breakpoints.mobileMax = 600`, `Breakpoints.tabletMax = 1024`, `Breakpoints.resolve(width)` → `ScreenType`.

### No MediaQuery in UI
- Layout layer only: `AdaptiveLayoutBuilder` uses `LayoutBuilder` + `MediaQuery.textScaleFactorOf(context)` and exposes `ScreenTypeScope`.
- `context.text` uses `ScreenTypeScope.screenTypeOf(this)` and `textScaleFactorOf(this)` (no direct MediaQuery in features).

### Adaptive layout
- **core/layout/adaptive_layout_builder.dart**: `AdaptiveLayoutBuilder(mobile: ..., tablet: ..., desktop: ...)` with `LayoutBuilder` and `ScreenTypeScope`.
- **core/layout/screen_type_scope.dart**: Provides `ScreenType` and `textScaleFactor`; defaults to mobile and 1.0 when not found.

### Home screen
- **HomeScreen**: ConsumerWidget; watches `themeProvider`; Scaffold with body = `AdaptiveLayoutBuilder(mobile: _MobileLayout(...), tablet: _TabletLayout(...), desktop: _DesktopLayout(...))`.
- **Mobile**: Single column, full width, `AppSpacing.lg` padding.
- **Tablet**: Centered, `maxWidth: Breakpoints.mobileMax`, horizontal/vertical spacing.
- **Desktop**: Centered, `maxWidth: Breakpoints.tabletMax`, larger padding.
- **HomeContent**: StatelessWidget; only `context.text.*()`, `AppSpacing`, `AppRadius`, `context.theme.colors`; theme toggle via passed `ThemeNotifier.setThemeMode`.

### Architecture
- UI is dumb (no layout logic in feature beyond choosing mobile/tablet/desktop widgets).
- State: `themeProvider` / `ThemeNotifier` in Riverpod; no feature-level layout state.
- Layout decisions live in **core/layout**; design tokens in **core/design**.

---

## Final recommended folder structure

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── app_config.dart
│   ├── app_routes.dart
│   ├── routes.dart
│   ├── observers/
│   │   ├── app_lifecycle_observer.dart
│   │   ├── error_observer.dart
│   │   └── route_observer.dart
│   └── theme/
│       ├── app_colors.dart
│       ├── app_theme.dart
│       ├── app_theme_extension.dart   # context.theme + context.text
│       ├── dark_colors.dart
│       ├── dark_theme_builder.dart
│       ├── light_colors.dart
│       ├── light_theme_builder.dart
│       ├── theme_mode.dart
│       ├── theme_notifier.dart
│       ├── theme_provider.dart
│       ├── theme_state.dart
│       └── (THEME.md)
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── design/
│   │   ├── app_typography.dart        # Single typography system
│   │   ├── typography_scale.dart      # One scale per ScreenType
│   │   ├── app_text_tokens.dart      # Base sizes
│   │   ├── app_spacing.dart
│   │   └── app_radius.dart
│   ├── di/
│   │   └── di.dart
│   ├── error/
│   │   └── ...
│   ├── layout/
│   │   ├── breakpoints.dart           # One breakpoint system
│   │   ├── screen_type_scope.dart     # ScreenType + textScaleFactor
│   │   └── adaptive_layout_builder.dart
│   ├── logging/
│   └── ...
└── features/
    └── home/
        └── home_page.dart             # HomeScreen + layouts + HomeContent
```

---

## Checklist (confirmed)

| Rule | Status |
|------|--------|
| One typography system | Yes — `app_typography.dart` + `typography_scale.dart`; `context.text.*()` only. |
| One breakpoint system | Yes — `core/layout/breakpoints.dart` only. |
| No hardcoded UI sizes | Yes — Home uses `AppSpacing`, `AppRadius`; no raw numbers. |
| Adaptive layout reusable | Yes — `AdaptiveLayoutBuilder` in core/layout with fallbacks. |
| Architecture clean & scalable | Yes — Clean Architecture + MVVM; dumb UI; state in ViewModel/Provider; no feature-level layout logic. |
