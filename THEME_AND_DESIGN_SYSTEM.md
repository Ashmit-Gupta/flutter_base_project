# Theme & Design System — Architecture Documentation

This document describes how the theme and design system work in this Flutter project. It is analysis-only: no refactors, no suggested fixes, no code changes.

---

## 1. High-Level Architecture Overview

### Text-based diagram (ASCII)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           MaterialApp                                        │
│  theme: buildLightTheme() / darkTheme: buildDarkTheme()                      │
│  themeMode: from themeProvider → materialThemeModeProvider                   │
└─────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  ThemeData (Flutter)                                                         │
│  • brightness, useMaterial3, fontFamily                                      │
│  • scaffoldBackgroundColor ← colors.background                               │
│  • inputDecorationTheme ← colors (surface, border, primary, error)           │
│  • textTheme ← NOT SET (Flutter default Material 3 text theme + fontFamily)  │
│  • extensions: [ AppTheme, AppButtonTheme, AppSnackbarTheme ]                 │
└─────────────────────────────────────────────────────────────────────────────┘
         │                    │                           │
         ▼                    ▼                           ▼
┌─────────────────┐  ┌─────────────────────┐  ┌─────────────────────────────┐
│  AppTheme       │  │  AppButtonTheme      │  │  AppSnackbarTheme            │
│  • colors       │  │  • primaryStyle     │  │  • success/warning/error/    │
│  • fontFamily   │  │  • secondaryStyle   │  │    info background colors    │
│                 │  │  • dangerStyle      │  │  • contentColor               │
│  (AppColors     │  │  (from AppColors +  │  │  • contentStyle(TextTheme)   │
│   interface)    │  │   TextTheme.        │  │  (from ThemeData.textTheme)   │
│                 │  │   labelLarge)       │  │                               │
└────────┬────────┘  └──────────┬──────────┘  └──────────────┬───────────────┘
         │                      │                             │
         │                      │                             │
         ▼                      ▼                             ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  Context extensions & consumption                                            │
│  • context.theme → Theme.of(context).extension<AppTheme>()!                 │
│  • context.text → typographyForScreen(ScreenTypeScope, theme.colors,        │
│                   theme.fontFamily, textScaleFactor) → AppTypography          │
│  • AppButton → Theme.of(context).extension<AppButtonTheme>()!                │
│  • AppSnackbar.show() → Theme.of(context).extension<AppSnackbarTheme>()!     │
│                + theme.textTheme for contentStyle()                          │
└─────────────────────────────────────────────────────────────────────────────┘
         │
         │  context.text builds typography from:
         ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  Typography path (separate from ThemeData.textTheme)                         │
│  ScreenTypeScope.screenTypeOf(context) → TypographyScale.fromScreen()        │
│  AppTheme.colors.textPrimary, AppTheme.fontFamily                            │
│  ScreenTypeScope.textScaleFactorOf(context)                                  │
│  → AppTypography(color, fontFamily, scale, maxFontSize, textScaleFactor)     │
│  → .display() / .headline() / .title() / .body() / .label() / .caption()     │
│     (use AppTextTokens for base font sizes)                                  │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│  Layout / screen type                                                        │
│  AdaptiveLayoutBuilder (LayoutBuilder + Breakpoints.resolve(width))           │
│  → ScreenTypeScope(screenType, MediaQuery.textScaleFactorOf(context))        │
│  Only screens that use AdaptiveLayoutBuilder have ScreenTypeScope;           │
│  others (e.g. ForgotPasswordScreen) default to mobile + 1.0.                │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Layer responsibilities

| Layer | Responsibility |
|-------|----------------|
| **App (main, App widget)** | Runs app; provides `MaterialApp` with `theme` / `darkTheme` from builders, `themeMode` from Riverpod. Does not provide `ScreenTypeScope`. |
| **Theme builders (light_theme_builder, dark_theme_builder)** | Instantiate `LightAppColors` / `DarkAppColors`, build `ThemeData` with `InputDecorationTheme` and `extensions`: `AppTheme`, `AppButtonTheme`, `AppSnackbarTheme`. Do not set `ThemeData.textTheme`. |
| **AppTheme extension** | Holds `AppColors` and `fontFamily`. Single place for app colors and font family in theme. |
| **AppButtonTheme extension** | Holds three `ButtonStyle`s (primary, secondary, danger) built from `AppColors` and `TextTheme.labelLarge`. |
| **AppSnackbarTheme extension** | Holds background colors per type and content color; `contentStyle(TextTheme)` uses `TextTheme.bodyMedium`. |
| **AppThemeX (context.theme / context.text)** | `theme` exposes `AppTheme`. `text` builds a fresh `AppTypography` via `typographyForScreen(ScreenTypeScope, colors.textPrimary, fontFamily, textScaleFactor)`. |
| **AppTypography + AppTextTokens + TypographyScale** | Token sizes (AppTextTokens), scale from screen type (TypographyScale), and semantic styles (AppTypography). Used only when widgets call `context.text.*()`. |
| **ScreenTypeScope** | Provided by `AdaptiveLayoutBuilder` (or equivalent). Supplies `ScreenType` and `textScaleFactor` so UI does not read `MediaQuery` directly. |
| **Widgets** | Buttons use `AppButtonTheme`; snackbars use `AppSnackbarTheme` + `theme.textTheme`; text fields use `theme.textTheme`; screens that use design tokens use `context.theme.colors` and `context.text.*()`. |

---

## 2. Theme & Design System Flow

### App startup → ThemeData → Widget render

1. **Bootstrap**  
   `main()` → `_bootstrap()` (env, DI) → `runApp(ProviderScope(child: App()))`.

2. **App widget**  
   `App` (ConsumerStatefulWidget) watches `themeProvider` and `materialThemeModeProvider`. It builds:
   - `theme: buildLightTheme(fontFamily: themeState.fontFamily)`
   - `darkTheme: buildDarkTheme(fontFamily: themeState.fontFamily)`
   - `themeMode: themeMode` (from Riverpod).

   `ThemeState` is created by `ThemeNotifier` with default `fontFamily: 'Roboto'` and `mode: AppThemeMode.system`.

3. **Theme builders**  
   Each builder:
   - Instantiates one of `LightAppColors()` or `DarkAppColors()` (no factory; new instance per build).
   - Builds `ThemeData` with `brightness`, `useMaterial3: true`, `fontFamily`, `scaffoldBackgroundColor: colors.background`, and `inputDecorationTheme` (fill, borders from `AppColors`).
   - Does **not** set `ThemeData.textTheme`; Flutter’s default Material 3 `TextTheme` (plus `fontFamily`) is used.
   - Adds extensions: `AppTheme(colors, fontFamily)`, `buildAppButtonTheme(colors, textTheme: baseTheme.textTheme)`, `buildAppSnackbarTheme(colors)`.

4. **Router**  
   GoRouter renders routes (e.g. `DesignSystemScreen`, `LoginScreen`, `ForgotPasswordScreen`). No `ScreenTypeScope` at the router level; it exists only where a screen wraps content in `AdaptiveLayoutBuilder`.

5. **Widget render**  
   - **Colors:** Widgets that use app colors get them via `context.theme.colors` (i.e. `AppTheme.colors`), which is either `LightAppColors` or `DarkAppColors` depending on the active `ThemeData`.
   - **Typography (design system):** Widgets that use the design-system typography call `context.text.headline()`, `context.text.body()`, etc. That builds `AppTypography` from `ScreenTypeScope`, `AppTheme.colors.textPrimary`, `AppTheme.fontFamily`, and `ScreenTypeScope.textScaleFactorOf(context)`.
   - **Button text:** `AppButton` uses `AppButtonTheme` only; the label is a plain `Text(label)`. The button’s text style comes from the `ButtonStyle`’s `textStyle`, which was set in `buildAppButtonTheme` to `textTheme.labelLarge` (from `baseTheme.textTheme`).
   - **Snackbar text:** `AppSnackbar.show()` uses `AppSnackbarTheme.contentStyle(theme.textTheme)` → `textTheme.bodyMedium` with `contentColor`.
   - **Text fields:** `AppTextField` and `AppLabeledTextField` use `theme.textTheme.bodyLarge` and `theme.textTheme.labelLarge` directly; they do not use `context.text` or `AppTypography`.

---

## 3. Typography System Analysis

### AppTextTokens

- **Location:** `lib/core/design/app_text_tokens.dart`
- **Role:** Static const font sizes (display 48, headline 32, title 20, body 16, label 14, caption 12). No color or font family.
- **Used by:** `AppTypography._size()` only. No widget reads tokens directly.
- **Single source of truth for:** Base font sizes used by `AppTypography` semantic styles.

### AppTypography

- **Location:** `lib/core/design/app_typography.dart`
- **Role:** Produces `TextStyle` for display, headline, title, body, label, caption. Uses `AppTextTokens` for size, applies `color`, `fontFamily`, `scale` (from `TypographyScale`), `textScaleFactor`, and `maxFontSize` clamping.
- **Constructed by:** `typographyForScreen(ScreenType, color, fontFamily, textScaleFactor)` in the same file. Called from `AppThemeX.text` in `app_theme_extension.dart`.
- **Used by:** Any widget that calls `context.text.display()`, `.headline()`, `.title()`, `.body()`, `.label()`, `.caption()` (e.g. `DesignSystemScreen`, `LoginScreen`, `ForgotPasswordScreen`).

### TextTheme (Material)

- **Source at runtime:** `ThemeData.textTheme` is **never** set in this project. It is Flutter’s default Material 3 `TextTheme` for the given `brightness` and `fontFamily`.
- **Used by:**
  - `buildAppButtonTheme(..., textTheme: baseTheme.textTheme)` → `textTheme.labelLarge` for all three button styles.
  - `AppSnackbarTheme.contentStyle(TextTheme textTheme)` → `textTheme.bodyMedium`.
  - `AppTextField`: `style: textTheme.bodyLarge`.
  - `AppLabeledTextField`: heading `style: theme.textTheme.labelLarge`.
- So: **Material `TextTheme`** drives button labels, snackbar content, and text field styles. It is **not** derived from `AppTextTokens` or `AppTypography`.

### context.text extension

- **Location:** `lib/app/theme/app_theme_extension.dart`
- **Implementation:** `context.text` calls `typographyForScreen(ScreenTypeScope.screenTypeOf(this), t.colors.textPrimary, t.fontFamily, textScaleFactor: ScreenTypeScope.textScaleFactorOf(this))` and returns the resulting `AppTypography`.
- **Behavior:** Builds a new `AppTypography` on every read. Typography is adaptive to `ScreenType` and system text scale when `ScreenTypeScope` is present; otherwise it falls back to `ScreenType.mobile` and `textScaleFactor` 1.0.

### Component text styles (buttons, inputs)

- **Buttons:** Text style comes from `AppButtonTheme.primaryStyle` / `secondaryStyle` / `dangerStyle`, which were built with `textTheme.labelLarge` (Material `TextTheme`). So button label typography is **Material TextTheme**, not `AppTypography` / `AppTextTokens`.
- **Inputs:** `AppTextField` uses `textTheme.bodyLarge`; `AppLabeledTextField` uses `textTheme.labelLarge` for the heading. Again Material `TextTheme`, not `context.text`.

### What is used vs what is ignored

| System | Used by | Ignored by |
|--------|--------|------------|
| **AppTextTokens** | `AppTypography._size()` only | All widgets (widgets never reference tokens directly). |
| **AppTypography / context.text** | Design system screen, login screen, forgot password screen, and any widget that explicitly calls `context.text.*()`. | `AppButton`, `AppSnackbar`, `AppTextField`, `AppLabeledTextField` do not use it. |
| **ThemeData.textTheme** | `buildAppButtonTheme`, `AppSnackbarTheme.contentStyle`, `AppTextField`, `AppLabeledTextField`. | Widgets that only use `context.text` never read `ThemeData.textTheme` for their own text. |
| **TypographyScale / ScreenType** | Only the `context.text` path (via `typographyForScreen`). | Button and input text styles are not scaled by `ScreenType`. |

**Direct answers:**

- **Where does typography ACTUALLY come from at runtime?**  
  - For headings/body/labels in design-system screens: from `context.text` → `typographyForScreen` → `AppTypography` (sizes from `AppTextTokens`, scale from `TypographyScale`, color/font from `AppTheme`).  
  - For button labels, snackbar content, and text field text: from `ThemeData.textTheme` (Flutter default Material 3 + `fontFamily`).

- **Where do button text styles come from?**  
  From `ThemeData.textTheme.labelLarge`, passed into `buildAppButtonTheme` and stored in each `ButtonStyle`’s `textStyle`. So from **Material TextTheme**, not from `AppTypography` or `AppTextTokens`.

- **Which typography system do widgets use today?**  
  Two systems in parallel: (1) **context.text / AppTypography** for screens that use design tokens (Design System, Login, Forgot Password); (2) **ThemeData.textTheme** for `AppButton`, `AppSnackbar`, `AppTextField`, `AppLabeledTextField`.

- **Which typography system was clearly intended to be used?**  
  Comments and structure suggest the intended single system is **AppTextTokens → AppTypography → context.text**: “Widgets must ONLY use semantic text styles built from these tokens” and “Obtain this via `context.text`”. But component themes (button, snackbar, text field) were wired to Material `TextTheme` instead, so intent and implementation diverge.

---

## 4. Color System Analysis

### AppColors contract

- **Location:** `lib/app/theme/app_colors.dart`
- **Role:** Abstract interface: primary, primaryDark, primaryLight, onPrimary, secondary; background, surface, border; textPrimary, textSecondary, textMuted; success, warning, error; credit, debit, neutral. All return `Color`.
- **Documentation:** Widgets are told to depend only on `AppColors`, not raw `Color`.

### LightAppColors / DarkAppColors

- **Locations:** `lib/app/theme/light_colors.dart`, `lib/app/theme/dark_colors.dart`
- **Role:** Implement `AppColors` with fixed hex colors for light and dark.
- **Instantiation:** New instance in each theme build: `final colors = LightAppColors()` / `DarkAppColors()` in the theme builders. No singleton or caching.

### Theme extensions

- **AppTheme** holds `AppColors colors` and `String fontFamily`. Colors are consumed via `context.theme.colors`.
- **AppButtonTheme** and **AppSnackbarTheme** receive `AppColors` (or derived colors) at build time and store concrete `Color` values and `ButtonStyle`s; they do not hold the `AppColors` instance.

### Runtime color resolution

- **AppTheme:** `Theme.of(context).extension<AppTheme>()!` → `theme.colors` → same `AppColors` instance that was passed into `AppTheme` when the current `ThemeData` was built. So at runtime, colors resolve from whichever theme is active (light or dark) and the corresponding `LightAppColors` / `DarkAppColors` instance.
- **AppButtonTheme / AppSnackbarTheme:** Resolved from `Theme.of(context).extension<...>()!`; their values were computed once in the theme builders from that theme’s `AppColors`. So runtime resolution is “whatever was stored in the extension when this ThemeData was built,” which ultimately comes from `LightAppColors` or `DarkAppColors`.

---

## 5. Theme Extensions & Composition

### AppTheme

- **Type:** `ThemeExtension<AppTheme>`
- **Fields:** `AppColors colors`, `String fontFamily`
- **Set in:** `light_theme_builder` and `dark_theme_builder` in `baseTheme.copyWith(extensions: [ AppTheme(...), ... ])`.
- **Consumed by:** `AppThemeX.theme` → `Theme.of(this).extension<AppTheme>()!`. Used for `context.theme.colors` and `context.theme.fontFamily` (the latter indirectly via `context.text`).

### AppButtonTheme

- **Type:** `ThemeExtension<AppButtonTheme>`
- **Fields:** `ButtonStyle primaryStyle`, `secondaryStyle`, `dangerStyle`
- **Built by:** `buildAppButtonTheme(colors: AppColors, textTheme: TextTheme)` using `textTheme.labelLarge` and `AppColors` for colors/sizes/shape.
- **Consumed by:** `AppButton._styleForVariant(context)` → `Theme.of(context).extension<AppButtonTheme>()!`, then picks the style by variant.

### AppSnackbarTheme

- **Type:** `ThemeExtension<AppSnackbarTheme>`
- **Fields:** Success/warning/error/info background colors, `contentColor`, and method `contentStyle(TextTheme)`.
- **Built by:** `buildAppSnackbarTheme(colors: AppColors)`.
- **Consumed by:** `AppSnackbar.show()` → `theme.extension<AppSnackbarTheme>()!`, then `backgroundColorFor(type)` and `contentStyle(theme.textTheme)`.

### How ThemeData.extensions are consumed

- All three extensions are stored in `ThemeData.extensions` and retrieved with `Theme.of(context).extension<AppTheme>()!` (and same for `AppButtonTheme`, `AppSnackbarTheme`). The `!` assumes the extension is always present; if a route or test ever used a `ThemeData` without these extensions, it would throw.

---

## 6. What Is Working Correctly

- **AppColors** is the single contract for color; light/dark implementations are clear and used consistently by theme builders and `AppTheme`.
- **ThemeData** is built in one place per mode (light/dark) with `AppTheme`, `AppButtonTheme`, and `AppSnackbarTheme` wired in.
- **context.theme** gives reliable access to `AppTheme` (colors + fontFamily) wherever the app’s theme is in scope.
- **context.text** correctly builds adaptive typography from `ScreenType`, `AppTheme`, and text scale when used inside `AdaptiveLayoutBuilder`; fallback to mobile and 1.0 when `ScreenTypeScope` is missing is documented and consistent.
- **AppTypography** correctly uses **AppTextTokens** for base sizes and **TypographyScale** for screen-based scaling and max size.
- **ScreenTypeScope** is provided by **AdaptiveLayoutBuilder** using **Breakpoints** and **MediaQuery.textScaleFactorOf**; UI that uses `context.text` does not read `MediaQuery` or layout width directly.
- **AppButton** is fully theme-driven (no hard-coded colors or text styles in the widget); it uses only `AppButtonTheme`.
- **AppSnackbar** is fully theme-driven via `AppSnackbarTheme` and `theme.textTheme`.
- **InputDecorationTheme** is centralized in theme builders with `AppColors` and `AppRadius`.
- **Theme mode** (light/dark/system) and **font family** are managed in one place (Riverpod `ThemeNotifier` / `ThemeState`) and flow into theme builders.

---

## 7. What Is Architecturally Wrong or Risky

- **Two typography systems:** One is `AppTextTokens` → `AppTypography` → `context.text` (intended as the single typography system). The other is Material `ThemeData.textTheme` (default M3), used for buttons, snackbars, and text fields. They are not connected: changing token sizes or font does not change button or input text. This violates the idea of a single typography source and can cause visual inconsistency (e.g. body text from `context.text.body()` vs text field text from `textTheme.bodyLarge`).

- **Button text style source:** Button labels use `textTheme.labelLarge`, not `AppTypography.label()`. So button text does not use `AppTextTokens.label` (14px) or screen scaling; it uses Material’s default labelLarge. Intent (design tokens) vs behavior (Material theme) are mismatched.

- **Snackbar and text field text:** Same as above: they use `textTheme.bodyMedium` / `bodyLarge` / `labelLarge`, not `context.text`. So snackbar and input typography are disconnected from the design-system typography.

- **ThemeData.textTheme never set:** Because `textTheme` is never assigned in theme builders, it is always Flutter’s default. So the only way to get token-based typography into the theme would be to compute a `TextTheme` from `AppTypography` and set it on `ThemeData`; currently that is not done, and component themes that take `TextTheme` therefore never see token-based styles.

- **AppLabeledTextField imports test file:** `lib/core/widgets/app_labeled_text_field.dart` imports `../../test/design_pg.dart`. That is a test/playground file. It is used for `AppSpacing` (and possibly other symbols). Production code should not depend on test code; the real `AppSpacing` lives in `lib/core/design/app_spacing.dart`. This is a dependency bug and a maintenance risk.

- **Duplicate definitions in design_pg.dart:** `lib/test/design_pg.dart` defines its own `ScreenType`, `Breakpoints`, `ScreenTypeScope`, `AdaptiveLayoutBuilder`, `AppTypography`, `AppSpacing`. So there are two parallel “design systems”: the real one in `lib/core` and `lib/app`, and a copy in the playground. Over time they can drift; the wrong one is already used by `AppLabeledTextField` via the bad import.

- **context.text builds on every access:** `context.text` invokes `typographyForScreen(...)` each time, creating a new `AppTypography`. It is not cached per build or per theme. For correct behavior this is fine, but it’s slightly more work than a cached instance and could matter if many widgets read `context.text` in one frame.

- **ScreenTypeScope optional:** Screens that do not wrap content in `AdaptiveLayoutBuilder` (e.g. `ForgotPasswordScreen`) have no `ScreenTypeScope`. They still get typography via `context.text` because of the fallback to `ScreenType.mobile` and 1.0, but they never get tablet/desktop scaling. Whether that’s acceptable is a product decision; architecturally it’s a “sometimes adaptive, sometimes not” split.

- **Extensions assumed present:** All consumers use `Theme.of(context).extension<AppTheme>()!` (and same for the other two). If any `ThemeData` is ever used without these extensions (e.g. in a test or a minimal route), the app will throw. There is no defensive handling.

---

## 8. Missing or Half-Wired Pieces

- **TextTheme from design tokens:** There is no code that builds a `TextTheme` (e.g. `ThemeData.textTheme`) from `AppTypography` or `AppTextTokens`. The design system comments imply a single typography source, but the only consumer of tokens is `context.text`. Component themes that need a `TextStyle` take `ThemeData.textTheme`, which is never populated from tokens. So the “intended” path (tokens → one place → everywhere) is half-wired: it exists for manual `context.text` use only.

- **AppTypography in ThemeData:** `AppTheme` holds `colors` and `fontFamily` but not `AppTypography`. Typography is recreated in `AppThemeX.text` from layout and theme. So there is no single “app typography instance” stored in the theme; it’s derived on demand. That’s consistent with adaptive layout but means “typography” is not a first-class theme extension, only colors and font family are.

- **ForgotPasswordScreen and ScreenTypeScope:** `ForgotPasswordScreen` does not use `AdaptiveLayoutBuilder`. So it never provides `ScreenTypeScope`; typography there always uses the default (mobile, scale 1.0). The pattern is inconsistent with Design System and Login screens, which wrap in `AdaptiveLayoutBuilder`.

- **design_pg.dart as second implementation:** The playground reimplements ScreenType, Breakpoints, ScreenTypeScope, AdaptiveLayoutBuilder, AppTypography, AppSpacing. These are “existing but parallel” abstractions; the only production misuse identified is `AppLabeledTextField` importing from the test file. Otherwise the playground is a standalone duplicate, not wired into the real theme.

---

## 9. Single Source of Truth Evaluation

### What SHOULD be the SSOT (from docs and comments)

- **Colors:** `AppColors` (and thus `LightAppColors` / `DarkAppColors`) — achieved; theme and widgets use `context.theme.colors` or theme-built extensions.
- **Typography:** Comments say “Widgets must ONLY use semantic text styles built from these tokens” and “Obtain this via `context.text`”. So the intended SSOT is **AppTextTokens → AppTypography → context.text** for all text, including buttons and inputs.
- **Spacing/radius:** `AppSpacing` and `AppRadius` — intended as SSOT; they are used in theme builders and in several widgets. Exception: `AppLabeledTextField` imports `AppSpacing` from the test file, so for that file the “source” is wrong.

### What IS the SSOT currently

- **Colors:** Effectively **AppColors** (via AppTheme and theme-built extensions). Single source; behavior matches intent.
- **Typography:** There is no single source. **AppTextTokens / AppTypography / context.text** are the SSOT for screens that call `context.text.*()`. **ThemeData.textTheme** (Flutter default) is the SSOT for button labels, snackbar content, and text field styles. So two parallel truths; token-based typography is not the SSOT for components.
- **Spacing:** **AppSpacing** in `lib/core/design/app_spacing.dart` is the real SSOT. **AppLabeledTextField** breaks this by depending on `lib/test/design_pg.dart` for spacing (or other symbols), so for that widget the effective “source” is the test file.

---

## 10. Summary in Plain English

**For a junior Flutter dev:**

The app has a clear **color** system: an `AppColors` interface with light and dark implementations. The active theme (light or dark) is built in one place and pushed into `ThemeData` via an extension called `AppTheme`. Widgets get colors with `context.theme.colors`. Buttons and snackbars get their colors from other extensions (`AppButtonTheme`, `AppSnackbarTheme`) that are built from the same `AppColors`. So for color, there’s one source and it’s used everywhere it should be.

**Typography is split.** The project defines its own typography system: **AppTextTokens** (font sizes like 48, 32, 20, 16, 14, 12), **TypographyScale** (bigger on tablet/desktop), and **AppTypography** (methods like `.headline()`, `.body()` that return `TextStyle`). You’re supposed to use that via **context.text** (e.g. `context.text.headline()`), and some screens (Design System, Login, Forgot Password) do. So for those screens, typography really does come from tokens and scales with screen type.

But **buttons, snackbars, and text fields don’t use that.** Their text comes from Flutter’s built-in **ThemeData.textTheme** (Material 3 default), which the app never customizes. So you get two typography “sources”: (1) `context.text` for titles and body text on those screens, and (2) `ThemeData.textTheme` for button labels, snackbar text, and input text. They’re not the same font sizes or the same system, so the “one typography system” the docs describe isn’t fully there.

**Layout and scaling:** Screens that want responsive typography wrap their content in **AdaptiveLayoutBuilder**, which uses width breakpoints to decide mobile/tablet/desktop and puts a **ScreenTypeScope** in the tree. **context.text** then uses that to scale typography. Screens that don’t use `AdaptiveLayoutBuilder` (e.g. Forgot Password) still have `context.text`, but it always behaves like “mobile” because there’s no scope.

**One concrete bug:** `AppLabeledTextField` imports from a **test** file (`design_pg.dart`) instead of from the real design modules. That test file has its own copy of things like `AppSpacing`. So one production widget is tied to the test/playground code instead of the real design system.

**In short:** Colors are centralized and consistent. Typography has a nice token-based system that part of the app uses, but the rest (buttons, inputs, snackbars) uses Flutter’s default text theme, so there are two typography systems. Fixing that would mean either feeding token-based styles into `ThemeData.textTheme` and component themes, or making those components use `context.text` (or an equivalent) instead of `ThemeData.textTheme`.
