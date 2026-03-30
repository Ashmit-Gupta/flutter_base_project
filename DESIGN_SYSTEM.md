# Design System & Theme Architecture

**give this to the ai for reference and context about the design system **

**Single source of truth** for how the app’s design system works and how future components must be built. This document describes what exists, how it is wired, and how data flows at runtime. The current codebase is treated as correct and final.

---

## 1. Introduction & Design Goals

The app uses a **token-based design system** with a clear separation between:

- **Design tokens** — Colors, typography sizes, spacing, and radius defined in one place.
- **Theme layer** — ThemeData and ThemeExtensions that inject tokens so widgets stay dumb.
- **Layout layer** — Screen type and text scale provided via an InheritedWidget so UI does not read `MediaQuery` directly.
- **Component layer** — Reusable widgets (buttons, snackbars, text fields) that consume only theme and extensions; no hard-coded colors or font sizes.

**Design goals:**

- **Single source of truth:** All typography derives from `AppTextTokens`; all colors from `AppColors`. No parallel systems.
- **Theme-driven UI:** Widgets obtain colors and text styles from `Theme.of(context)` and extensions, not from literals or layout logic.
- **Adaptive typography where appropriate:** Free-form content (headings, body) can scale by screen type and accessibility via `context.text`; component text (buttons, inputs, snackbars) uses a fixed token baseline from `ThemeData.textTheme`.
- **Material 3 compliance:** Use of `ThemeData`, `ThemeExtension`, and Material components (FilledButton, OutlinedButton, SnackBar, TextFormField) with correct state handling (focus, hover, disabled).
- **Testability and consistency:** Central breakpoints, spacing, and radius so layout and styling stay consistent and easy to change globally.

---

## 2. High-Level Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           MaterialApp                                        │
│  theme: buildLightTheme(fontFamily)                                          │
│  darkTheme: buildDarkTheme(fontFamily)                                       │
│  themeMode: from themeProvider → materialThemeModeProvider                   │
└─────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  ThemeData                                                                   │
│  • brightness, useMaterial3, fontFamily                                       │
│  • scaffoldBackgroundColor ← AppColors.background                             │
│  • textTheme ← buildAppTextTheme(colors.textPrimary, fontFamily) [TOKENS]    │
│  • inputDecorationTheme ← AppColors + AppRadius                              │
│  • extensions: [ AppTheme, AppButtonTheme, AppSnackbarTheme ]                │
└─────────────────────────────────────────────────────────────────────────────┘
         │                    │                           │
         ▼                    ▼                           ▼
┌─────────────────┐  ┌─────────────────────┐  ┌─────────────────────────────┐
│  AppTheme       │  │  AppButtonTheme     │  │  AppSnackbarTheme            │
│  • colors       │  │  • primaryStyle     │  │  • *BackgroundColor (×4)      │
│  • fontFamily   │  │  • secondaryStyle   │  │  • contentColor               │
│                 │  │  • dangerStyle      │  │  • contentStyle(TextTheme)    │
└────────┬────────┘  └──────────┬──────────┘  └──────────────┬───────────────┘
         │                      │                             │
         │  context.theme        │  AppButton                  │  AppSnackbar
         │  context.text        │  uses extension             │  uses extension
         ▼                      ▼                             ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  Consumption                                                                  │
│  • context.theme → AppTheme (colors, fontFamily)                              │
│  • context.text → typographyForScreen(ScreenTypeScope, theme) → AppTypography│
│  • AppButton → Theme.of(context).extension<AppButtonTheme>()                  │
│  • AppSnackbar → extension<AppSnackbarTheme>() + theme.textTheme              │
│  • AppTextField / AppLabeledTextField → theme.textTheme (bodyLarge, labelLarge)│
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│  Typography sources (both from AppTextTokens)                                 │
│  1. ThemeData.textTheme — buildAppTextTheme() at theme build; mobile baseline │
│     → Buttons, snackbars, text fields                                        │
│  2. context.text — typographyForScreen() at runtime; uses ScreenTypeScope     │
│     → Headings, body, labels in screens (adaptive)                             │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│  Layout / screen type                                                        │
│  AdaptiveLayoutBuilder (LayoutBuilder + Breakpoints.resolve(width))           │
│  → ScreenTypeScope(screenType, MediaQuery.textScaleFactorOf(context))         │
│  Only layout layer reads MediaQuery; widgets use ScreenTypeScope or default.  │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Layer responsibilities:**

| Layer | Responsibility |
|-------|----------------|
| **Design tokens** | `AppColors`, `AppTextTokens`, `AppSpacing`, `AppRadius`, `TypographyScale`. Define raw values and semantic roles. |
| **Theme builders** | Build `ThemeData` and extensions from tokens; set `textTheme` via `buildAppTextTheme`; never use Flutter default text theme for app UI. |
| **AppTheme** | Holds `AppColors` and `fontFamily`; consumed as `context.theme`. |
| **AppButtonTheme / AppSnackbarTheme** | Hold component-specific styles built from `AppColors` and (for buttons) `TextTheme`; consumed via `Theme.of(context).extension<…>()`. |
| **AppThemeX** | `context.theme` → AppTheme; `context.text` → `typographyForScreen(ScreenTypeScope, …)` → AppTypography. |
| **ScreenTypeScope** | Provided by `AdaptiveLayoutBuilder`; supplies `ScreenType` and `textScaleFactor` so widgets do not read `MediaQuery`. |
| **Widgets** | Obtain colors from `context.theme.colors` or component theme; obtain typography from `context.text` (content) or `theme.textTheme` (components); use `AppSpacing` / `AppRadius` for layout and shape. |

---

## 3. Design Tokens

### Colors

**Contract:** `AppColors` (`lib/app/theme/app_colors.dart`) is an abstract interface. Widgets must depend only on `AppColors` (via theme), never on raw `Color` or hex literals.

**Semantic groups:**

- **Brand:** `primary`, `primaryDark`, `primaryLight`, `onPrimary`, `secondary`
- **Backgrounds:** `background`, `surface`, `border`
- **Text:** `textPrimary`, `textSecondary`, `textMuted`
- **Status:** `success`, `warning`, `error`
- **Transactions:** `credit`, `debit`, `neutral`

**Implementations:**

- `LightAppColors` (`light_colors.dart`) — Light theme hex values; green for primary/success, blue for secondary.
- `DarkAppColors` (`dark_colors.dart`) — Dark theme hex values; same semantics, lower saturation and adjusted contrast.

**Flow:** Theme builders instantiate `LightAppColors()` or `DarkAppColors()` and pass the instance into `AppTheme` and into `buildAppButtonTheme` / `buildAppSnackbarTheme` / `buildAppTextTheme`. At runtime, the active `ThemeData` carries one of these implementations; widgets resolve colors via `context.theme.colors` or via component themes that were built from that same instance.

### Typography

**Tokens:** `AppTextTokens` (`lib/core/design/app_text_tokens.dart`) — static const font sizes only (no color, no font family):

- `display` = 48
- `headline` = 32
- `title` = 20
- `body` = 16
- `label` = 14
- `caption` = 12

Widgets must not hardcode font sizes; they use semantic styles built from these tokens (via `ThemeData.textTheme` or `context.text`).

**How tokens are used:** See **Section 4. Typography System**.

### Spacing & Radius

**AppSpacing** (`lib/core/design/app_spacing.dart`) — 8pt-inspired scale:

- `xs` = 4, `sm` = 8, `md` = 16, `lg` = 24, `xl` = 32, `xxl` = 48

Used for padding, gaps, and vertical rhythm. Widgets and theme builders use these constants instead of raw numbers.

**AppRadius** (`lib/core/design/app_radius.dart`):

- `sm` = 6, `md` = 12, `lg` = 20, `pill` = 999

Used for borders and shapes (buttons, inputs, cards, snackbars). Theme builders and widgets reference these constants.

---

## 4. Typography System (Deep Dive)

The app has **one typography source of truth** — `AppTextTokens` — and **two delivery paths** that both derive from it.

### AppTextTokens

- **Location:** `lib/core/design/app_text_tokens.dart`
- **Role:** Defines the six base font sizes (display, headline, title, body, label, caption). No color or font family.
- **Consumer:** Only `AppTypography._size()` reads these values. No widget reads tokens directly.

### AppTypography

- **Location:** `lib/core/design/app_typography.dart`
- **Role:** Produces `TextStyle` for each semantic role. Each style uses:
  - Base size from `AppTextTokens`
  - `scale` (from `TypographyScale`, driven by screen type)
  - `textScaleFactor` (accessibility)
  - `maxFontSize` (clamp to avoid layout breakage)
  - `color`, `fontFamily` (from theme)
- **Created by:** Either `typographyForScreen(...)` (runtime, adaptive) or inside `buildAppTextTheme(...)` (theme build time, fixed baseline).

### TypographyScale

- **Location:** `lib/core/design/typography_scale.dart`
- **Role:** Maps `ScreenType` to a scale factor and max font size:
  - **Mobile:** factor 1.0, maxFontSize 20
  - **Tablet:** factor 1.1, maxFontSize 28
  - **Desktop:** factor 1.2, maxFontSize 36

Used by `typographyForScreen` for adaptive typography. Used by `buildAppTextTheme` only for the scale factor (1.0); `buildAppTextTheme` overrides `maxFontSize` to 48 so token sizes are not clamped at theme build time.

### buildAppTextTheme

- **Location:** `lib/core/design/app_text_theme.dart`
- **Role:** Builds a Flutter `TextTheme` from design tokens. It:
  1. Gets `TypographyScale.fromScreen(ScreenType.mobile)` (scale 1.0).
  2. Constructs `AppTypography` with that scale, `maxFontSize: 48`, `textScaleFactor: 1.0`, and the given `color` and `fontFamily`.
  3. Calls `display()`, `headline()`, `title()`, `body()`, `label()`, `caption()` and maps them to `TextTheme` slots (e.g. `labelLarge` ← label(), `bodyMedium` ← body()).

**Why theme build time:** `ThemeData` is built once per theme mode when the app or theme state changes. At that moment there is no `BuildContext` with a `ScreenTypeScope`, so screen type is unknown. Using a **mobile baseline** gives components a consistent, token-based typography. This is an intentional trade-off: component text (buttons, snackbars, inputs) does not scale by screen type; it uses the same token sizes everywhere.

**Why maxFontSize 48:** `TypographyScale.fromScreen(ScreenType.mobile)` returns `maxFontSize: 20`, which would clamp display (48) and headline (32) down to 20. For the theme-built `TextTheme`, the intent is to preserve token sizes for all roles, so `buildAppTextTheme` uses a permissive cap (48) instead. Adaptive typography (via `context.text`) still uses the real `TypographyScale` maxFontSize for its context.

### ThemeData.textTheme

- **Set in:** `light_theme_builder.dart` and `dark_theme_builder.dart` via `textTheme: buildAppTextTheme(color: colors.textPrimary, fontFamily: fontFamily)`.
- **Consumed by:**
  - `buildAppButtonTheme(..., textTheme: textTheme)` → `textTheme.labelLarge` for all three button styles.
  - `AppSnackbarTheme.contentStyle(theme.textTheme)` → `textTheme.bodyMedium` with content color.
  - `AppTextField` → `style: textTheme.bodyLarge`.
  - `AppLabeledTextField` → heading `style: theme.textTheme.labelLarge`.

So **ThemeData.textTheme is built from tokens** and is the **only** typography source for these components. Flutter’s default Material text theme is not used for app UI.

### context.text

- **Location:** `lib/app/theme/app_theme_extension.dart` — extension on `BuildContext`.
- **Implementation:** `context.text` returns `typographyForScreen(ScreenTypeScope.screenTypeOf(this), theme.colors.textPrimary, theme.fontFamily, textScaleFactor: ScreenTypeScope.textScaleFactorOf(this))`.
- **Result:** An `AppTypography` instance that adapts to:
  - **Screen type** (mobile/tablet/desktop) via `ScreenTypeScope`
  - **Accessibility** via `ScreenTypeScope.textScaleFactorOf(this)` (from `MediaQuery.textScaleFactorOf`, but read only in the layout layer and passed down).

**Why content text scales:** Screens that show headings, body, or labels in the content area (e.g. Design System screen, Login, Forgot Password) use `context.text.headline()`, `context.text.body()`, etc. Those widgets sit under `AdaptiveLayoutBuilder` → `ScreenTypeScope`, so they get the correct screen type and text scale. Typography is then consistent with layout (e.g. tablet gets slightly larger type). Screens that do not wrap content in `AdaptiveLayoutBuilder` still get valid typography: `ScreenTypeScope.screenTypeOf(context)` returns `ScreenType.mobile` and `textScaleFactorOf` returns 1.0 when the scope is missing.

### Why component text does NOT scale by screen type

- Component themes (buttons, snackbars, inputs) are built at **theme build time**. No `ScreenTypeScope` exists there, so screen type is unknown.
- Components are expected to look **consistent** across screen sizes (same button label size everywhere); adaptation is reserved for **content** (headings, paragraphs) where layout already differs by breakpoint.
- So: **ThemeData.textTheme** = token-based, fixed (mobile) baseline for components. **context.text** = token-based, adaptive for free-form content.

### Why widgets must not pick font sizes

- Font sizes are a **design decision** and must live in one place (tokens → theme or `context.text`). If widgets chose sizes (e.g. from `MediaQuery` or literals), the system would fragment and global changes (e.g. accessibility or brand refresh) would be impossible to apply consistently.
- Widgets **must** use either `theme.textTheme` (for component-style text) or `context.text` (for content), both of which ultimately use `AppTextTokens`.

---

## 5. Color System (Deep Dive)

### AppColors contract

- **Location:** `lib/app/theme/app_colors.dart`
- **Role:** Abstract interface; every color used by the app is a getter on this interface. Enables light/dark swap, brand refresh, and remote theming without widget changes.

### Light / Dark implementations

- **LightAppColors** (`light_colors.dart`): Implements `AppColors` with light-appropriate hex values.
- **DarkAppColors** (`dark_colors.dart`): Implements `AppColors` with dark-appropriate hex values.

New instances are created in theme builders each time `buildLightTheme` or `buildDarkTheme` runs (e.g. when `fontFamily` or theme mode changes). There is no singleton; the active theme holds the current implementation.

### AppTheme extension

- **Location:** `lib/app/theme/app_theme.dart`
- **Fields:** `AppColors colors`, `String fontFamily`
- **Set in:** Theme builders: `AppTheme(colors: colors, fontFamily: fontFamily)` in the extensions list.
- **Consumed by:** `context.theme` → `Theme.of(context).extension<AppTheme>()!`. Widgets then use `context.theme.colors.primary`, `context.theme.colors.textPrimary`, etc.

### Flow into components

- **ThemeData:** `scaffoldBackgroundColor`, `inputDecorationTheme` (fill, borders) use `colors.background`, `colors.surface`, `colors.border`, `colors.primary`, `colors.error`.
- **AppButtonTheme:** Built with `AppColors` (primary, onPrimary, border, textMuted, error) for background, foreground, disabled, and shape. Colors are baked into `ButtonStyle`; the widget does not read `AppColors` directly for paint.
- **AppSnackbarTheme:** Built with `AppColors` (success, warning, error, secondary, onPrimary) for background and content color. The snackbar helper reads the extension and uses `backgroundColorFor(type)` and `contentColor`.
- **InputDecorationTheme:** Uses `colors.surface`, `colors.border`, `colors.primary`, `colors.error` for fill and border states.

### Runtime resolution

- The active `ThemeData` (light or dark) is chosen by Flutter based on `themeMode` and system/brightness. That `ThemeData` contains the corresponding `AppTheme` with either `LightAppColors` or `DarkAppColors`. So at runtime, `context.theme.colors` resolves to the correct implementation for the current theme. Component themes were built from the same `AppColors` instance when that theme was constructed, so their colors match.

---

## 6. ThemeData & Theme Extensions

### ThemeData (built by theme builders)

- **brightness:** Light or dark.
- **useMaterial3:** true.
- **fontFamily:** From `ThemeState` (Riverpod).
- **scaffoldBackgroundColor:** `colors.background`.
- **textTheme:** `buildAppTextTheme(colors.textPrimary, fontFamily)` — token-based; never Flutter default.
- **inputDecorationTheme:** Filled, with fill/border colors and radii from `AppColors` and `AppRadius`.
- **extensions:** Exactly three — `AppTheme`, `AppButtonTheme`, `AppSnackbarTheme`.

Widgets that use theme extensions assume they are present (`extension<…>()!`). If a route or test ever used a `ThemeData` without these extensions, it would throw.

### AppTheme (ThemeExtension<AppTheme>)

- Holds `colors` and `fontFamily`. Used for `context.theme` and as input to `context.text` (color and fontFamily for `typographyForScreen`). `lerp` returns `this` (no animation).

### AppButtonTheme (ThemeExtension<AppButtonTheme>)

- Holds `primaryStyle`, `secondaryStyle`, `dangerStyle` (`ButtonStyle`). Built by `buildAppButtonTheme(colors, textTheme)` using `AppColors`, `AppSpacing`, `AppRadius`, and `textTheme.labelLarge`. Supports `lerp` for theme transitions.

### AppSnackbarTheme (ThemeExtension<AppSnackbarTheme>)

- Holds success/warning/error/info background colors and `contentColor`; method `contentStyle(TextTheme)` returns a style based on `textTheme.bodyMedium` and `contentColor`. Built by `buildAppSnackbarTheme(colors)`. No `TextTheme` stored; the snackbar passes `theme.textTheme` when calling `contentStyle`.

---

## 7. Component Theming

### Buttons (AppButtonTheme)

- **Widget:** `AppButton` uses `Theme.of(context).extension<AppButtonTheme>()!` and selects `primaryStyle`, `secondaryStyle`, or `dangerStyle` by variant. It does not set colors or text style on its own; the label is a plain `Text(label)`. Material’s `FilledButton`/`OutlinedButton` apply the style (including `textStyle`) via `DefaultTextStyle`, so foreground color and font come from the theme. Loading state uses `context.theme.colors` only for the progress indicator color (primary vs onPrimary by variant).
- **Why dumb:** All visual decisions (colors, typography, size, shape) live in `AppButtonTheme` and theme builders. The widget only chooses which style to use and whether to show loading/content.
- **Material 3:** Focus, hover, pressed, and disabled are handled by Material; the theme supplies the base styles.

### Snackbars (AppSnackbarTheme)

- **Helper:** `AppSnackbar.show()` gets `theme.extension<AppSnackbarTheme>()!` and `theme.textTheme`. It uses `backgroundColorFor(type)`, `contentStyle(theme.textTheme)`, and `durationForType(type)`. Margin and shape use `AppSpacing` and `AppRadius`.
- **Why dumb:** No hard-coded colors or text styles; everything comes from the extension and `ThemeData.textTheme`.

### Inputs (TextField / InputDecorationTheme)

- **InputDecorationTheme:** Set on `ThemeData` in theme builders. Defines filled, fillColor, border, enabledBorder, focusedBorder, errorBorder using `AppColors` and `AppRadius`. All `TextFormField`s in the app inherit this unless overridden.
- **AppTextField:** Uses `theme.textTheme.bodyLarge` for `TextFormField.style`. Decoration (label, hint, icons) is not overridden, so it uses `Theme.of(context).inputDecorationTheme`.
- **AppLabeledTextField:** Uses `theme.textTheme.labelLarge` for the heading and a bare `InputDecoration` (hint, icons) so the global `inputDecorationTheme` applies to the field. Spacing between heading and field uses `AppSpacing.sm` (or optional override).
- **Why dumb:** No font sizes or colors in the widget; typography from theme, decoration from theme.

### Why component themes depend on ThemeData

- So that one place (theme builders) owns all visual decisions. Components only read `Theme.of(context)` and extensions. This preserves Material 3 behavior (states, inheritance) and keeps the design system single-source-of-truth.

---

## 8. Adaptive Layout & ScreenTypeScope

### Breakpoints

- **Location:** `lib/core/layout/breakpoints.dart`
- **ScreenType:** enum `mobile`, `tablet`, `desktop`.
- **Breakpoints.resolve(width):** width < 600 → mobile; width < 1024 → tablet; else desktop.

### AdaptiveLayoutBuilder

- **Location:** `lib/core/layout/adaptive_layout_builder.dart`
- **Behavior:** Uses `LayoutBuilder` to get `constraints.maxWidth`, then `Breakpoints.resolve(constraints.maxWidth)` and `MediaQuery.textScaleFactorOf(context)`. Wraps the chosen child (mobile / tablet / desktop) in `ScreenTypeScope(screenType, textScaleFactor, child)`.
- **Fallbacks:** If tablet or desktop layout is null, falls back to mobile (or tablet then mobile). So UI never reads `MediaQuery` or width in feature code; only this layout layer does.

### ScreenTypeScope

- **Location:** `lib/core/layout/screen_type_scope.dart`
- **Role:** InheritedWidget that provides `screenType` and `textScaleFactor` to the subtree.
- **API:** `ScreenTypeScope.screenTypeOf(context)` and `ScreenTypeScope.textScaleFactorOf(context)`. If the scope is missing (e.g. a screen that does not use `AdaptiveLayoutBuilder`), they return `ScreenType.mobile` and 1.0 and (in debug) print a warning.
- **Consumer:** `AppThemeX.text` uses these to call `typographyForScreen`. No other widget should read `MediaQuery` for layout or text scale; they use `ScreenTypeScope` or accept the default.

### LayoutConstants

- **Location:** `lib/core/layout/layout_constants.dart`
- **Content widths:** `tabletContentMaxWidth` = 720, `desktopContentMaxWidth` = 1200. Used by screens to constrain content width on larger breakpoints; not used by the design system core.

---

## 9. Runtime Flow (End-to-End)

1. **App startup:** `main()` → bootstrap (env, DI) → `runApp(ProviderScope(child: App()))`.

2. **App widget:** `App` watches `themeProvider` and `materialThemeModeProvider`. It builds `MaterialApp.router` with:
   - `theme: buildLightTheme(fontFamily: themeState.fontFamily)`
   - `darkTheme: buildDarkTheme(fontFamily: themeState.fontFamily)`
   - `themeMode: themeMode` (from Riverpod: light / dark / system).

3. **Theme creation (e.g. buildLightTheme):**
   - `colors = LightAppColors()`
   - `textTheme = buildAppTextTheme(color: colors.textPrimary, fontFamily: fontFamily)` — token-based TextTheme, mobile baseline.
   - `baseTheme = ThemeData(..., textTheme: textTheme, inputDecorationTheme: ..., scaffoldBackgroundColor: colors.background)`
   - `extensions: [ AppTheme(colors, fontFamily), buildAppButtonTheme(colors, textTheme), buildAppSnackbarTheme(colors) ]`
   - Return `baseTheme.copyWith(extensions: [...])`.

4. **Theme injection:** Flutter applies the returned `ThemeData` to the subtree. When theme mode or font family changes, `App` rebuilds and passes new `buildLightTheme`/`buildDarkTheme` results; MaterialApp switches theme accordingly.

5. **Widget rendering (example: screen with AdaptiveLayoutBuilder):**
   - Router builds the screen.
   - Screen wraps body in `AdaptiveLayoutBuilder(mobile: ..., tablet: ..., desktop: ...)`.
   - `AdaptiveLayoutBuilder` runs `LayoutBuilder`, resolves `ScreenType` and `textScaleFactor`, wraps child in `ScreenTypeScope(screenType, textScaleFactor, child)`.
   - Descendants that need typography call `context.text.headline()` etc.; `context.text` calls `typographyForScreen(ScreenTypeScope.screenTypeOf(this), theme.colors.textPrimary, theme.fontFamily, textScaleFactor: ...)` and returns an `AppTypography` that uses the correct scale and clamp for that screen type and accessibility.

6. **Typography resolution:**
   - **Content (headings, body):** `context.text.*()` → `typographyForScreen` → `AppTypography` with `TypographyScale.fromScreen(screenType)` → sizes from `AppTextTokens` × scale × textScaleFactor, clamped by maxFontSize.
   - **Buttons:** `AppButton` uses `extension<AppButtonTheme>()`; the style’s `textStyle` was set from `textTheme.labelLarge` in the theme builder, which came from `buildAppTextTheme` (token label at 14px, etc.).
   - **Snackbars:** `contentStyle(theme.textTheme)` uses `textTheme.bodyMedium` (token body) and overlay `contentColor`.
   - **Text fields:** `theme.textTheme.bodyLarge` / `labelLarge` (token body / label).

7. **Color resolution:** `context.theme.colors` → `Theme.of(context).extension<AppTheme>()!.colors` → the `AppColors` instance (Light or Dark) stored when that theme was built. Component themes already hold the resolved colors in their styles.

---

## 10. Design System Rules (Non-Negotiable)

### Widgets MUST

- Use **AppColors** only via theme: `context.theme.colors` or component themes built from it. Never use raw `Color` or hex literals for UI.
- Use **typography** only from theme or context: `theme.textTheme` for component-style text (e.g. inside buttons, snackbars, text fields) or `context.text` for content (headings, body, labels in the page). Never hardcode font sizes or create ad-hoc `TextStyle`s with literal sizes.
- Use **spacing and radius** from `AppSpacing` and `AppRadius`. No magic numbers for padding, gaps, or border radius.
- Rely on **theme and extensions** for all visual attributes of design-system components. Components must not override colors or text styles from theme unless the design system explicitly allows it (e.g. one-off emphasis with `context.text.body().copyWith(color: ...)` where the color still comes from theme).

### Widgets MUST NOT

- Use `Color` or numeric color values directly. Use `AppColors` via theme.
- Hardcode font sizes or create `TextStyle` with a literal `fontSize` that does not come from tokens.
- Read `MediaQuery` for layout width or text scale in feature/widget code. Use `ScreenTypeScope` (or accept default mobile/1.0) and use `AdaptiveLayoutBuilder` at the layout layer.
- Call `typographyForScreen` or `Breakpoints.resolve` in widgets. Use `context.text` or theme.
- Depend on test or playground code (e.g. `lib/test/`) for production widgets.

### Where decisions live

- **Typography (sizes, roles):** `AppTextTokens` and `TypographyScale`; delivery via `buildAppTextTheme` (ThemeData.textTheme) and `context.text` (typographyForScreen). **Widgets do not decide font sizes.**
- **Colors:** `AppColors` and its implementations; delivered via `AppTheme` and component themes. **Widgets do not choose colors; they read theme.**
- **Layout (screen type, text scale):** `Breakpoints`, `AdaptiveLayoutBuilder`, `ScreenTypeScope`. **Only the layout layer reads MediaQuery; widgets read ScreenTypeScope or default.**

---

## 11. Common Pitfalls & Misconceptions

- **“I need different text size on tablet.”** Use `context.text` for that content and ensure it is under `AdaptiveLayoutBuilder` so `ScreenTypeScope` is set. Do not try to change `ThemeData.textTheme` per screen — it is global and built once per theme.
- **“Button label looks wrong.”** Button text comes from `ThemeData.textTheme.labelLarge`, which is built by `buildAppTextTheme` (token label). If it looks wrong, fix tokens or theme build, not the widget.
- **“I’ll use Theme.of(context).textTheme and then override fontSize.”** Do not. That breaks the single source of truth. Use `context.text.label()` (or the appropriate role) and override only what the design allows (e.g. color from theme).
- **“ScreenTypeScope not found.”** The widget is not under an `AdaptiveLayoutBuilder` (or equivalent). Either wrap the route content in `AdaptiveLayoutBuilder` or accept the default (mobile, scale 1.0).
- **“I need a new color.”** Add it to the `AppColors` interface and to both `LightAppColors` and `DarkAppColors`; then use it via `context.theme.colors` or in a component theme. Do not add a one-off color in a widget.
- **“Input decoration is wrong.”** Input decoration is global via `ThemeData.inputDecorationTheme`. Override per field only if the design system allows (e.g. one-off error state is already handled by validator + errorBorder). Otherwise change the theme builder.

---

## 12. How to Add New Components Correctly

1. **Define semantics, not pixels.** Decide which colors (from `AppColors`) and which text roles (from tokens) the component uses. Do not invent new colors or sizes.
2. **Create a ThemeExtension** (e.g. `AppMyWidgetTheme`) that holds the resolved styles (colors, `TextStyle`, shape) built from `AppColors` and, if it has text, from a `TextTheme` that is the token-based theme (so pass `ThemeData.textTheme` from the builder, which is already `buildAppTextTheme(...)`).
3. **In theme builders,** build the extension from `AppColors` and the same `textTheme` used for the rest of the app, and add it to `ThemeData.extensions`.
4. **Implement the widget** so it only reads `Theme.of(context).extension<AppMyWidgetTheme>()!` (and `Theme.of(context).textTheme` only if the extension delegates to it, like snackbar). Use `AppSpacing` and `AppRadius` for layout and shape if the extension does not already encode them.
5. **Do not** read `MediaQuery` for layout or text scale; do not call `typographyForScreen` or `Breakpoints.resolve` in the widget. If the component’s content needs adaptive typography, it should use `context.text` for that part and still get colors/shell from the extension.
6. **Document** the new extension and widget in this doc (or a linked doc) so future work stays consistent.

---

## 13. Summary (Plain English)

- **Colors** come from the `AppColors` interface (light and dark implementations). They are stored in `AppTheme` and in component themes. Widgets get them via `context.theme.colors` or from theme extensions; they never use raw colors.

- **Typography** has one source — `AppTextTokens` — and two delivery mechanisms: (1) **ThemeData.textTheme** is built from those tokens at theme build time (mobile baseline) and feeds buttons, snackbars, and text fields; (2) **context.text** builds typography at runtime using the same tokens but with screen type and accessibility scale from `ScreenTypeScope`, and is used for headings and body in the content. So component text does not scale by screen type; content text does when under `AdaptiveLayoutBuilder`.

- **Spacing and radius** are centralized in `AppSpacing` and `AppRadius`. Everyone uses these constants.

- **Theme** is built in one place (light/dark theme builders) from tokens and injected into `MaterialApp`. No Flutter default text theme is used for app UI. Extensions (`AppTheme`, `AppButtonTheme`, `AppSnackbarTheme`) hold app and component-specific data; widgets are dumb and only read theme.

- **Layout** is adaptive only where the screen wraps content in `AdaptiveLayoutBuilder`, which sets `ScreenTypeScope`. Only that layer reads `MediaQuery`; widgets use `ScreenTypeScope` or get a safe default. This keeps layout and typography adaptation in one place and avoids scattered MediaQuery usage.

- **Rules:** No raw colors or font sizes in widgets. No MediaQuery in feature code. All visuals from theme and tokens. New components get a ThemeExtension and are wired in theme builders from the same tokens and colors. Following this keeps the design system one source of truth and makes new components and refactors predictable.
