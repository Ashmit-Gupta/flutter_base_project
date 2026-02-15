# Adaptive Design System

This document describes the project’s **Adaptive Design System**: architecture, concepts, typography, layout, and usage rules. It is part of the architecture. Follow it so the system stays consistent and scalable.

---

## 1. High-Level Philosophy

### Why the system exists

The app targets **mobile, tablet, desktop, and web**. We need:

- One source of truth for layout and typography.
- Predictable behavior across screen sizes.
- Accessibility (e.g. system text scale) without each screen reimplementing it.
- A single place to change breakpoints or typography so the whole app updates.

### What problems it solves

| Problem | Solution |
|--------|----------|
| Every screen using its own `MediaQuery` and magic numbers | Layout layer decides **screen type** once; UI consumes it via **ScreenTypeScope**. |
| Inconsistent typography (hardcoded 14, 18, 22) | One **typography system** with semantic roles and a mobile font cap. |
| Mixed “layout width” vs “content width” | **Breakpoints** for layout; **content max width** constants for readable content. |
| Accessibility ignored or duplicated | **textScaleFactor** read once in the layout layer and passed into typography. |

### Why Flutter defaults were insufficient

- **MediaQuery** is global and used everywhere; it’s easy to scatter `MediaQuery.of(context).size.width` and `fontSize: 18` in UI code. That leads to inconsistent breakpoints and typography and makes refactors costly.
- **ThemeData.textTheme** is not adaptive by screen size and doesn’t enforce a mobile font cap or semantic roles.
- There is no built-in split between “which layout to show” (breakpoints) and “how wide the content column is” (content width).

So we introduced a **single breakpoint system**, a **single typography system**, and a **ScreenTypeScope** so that only the layout layer touches MediaQuery and the rest of the UI stays dumb and token-based.

### Key principles

1. **Single source of truth** — Breakpoints live in `core/layout/breakpoints.dart`. Typography lives in `core/design/`. No duplicate definitions in features.
2. **Separation of concerns** — **Layout layer** (e.g. `AdaptiveLayoutBuilder`) reads `MediaQuery` and sets `ScreenTypeScope`. **UI** only uses `context.text`, design tokens, and the widget tree; it does not read `MediaQuery` or decide screen type.
3. **Composition over duplication** — Reuse `AdaptiveLayoutBuilder`, `context.text`, `AppSpacing`, and `AppRadius` instead of reimplementing layout or styles per screen.
4. **Design tokens, not magic numbers** — Spacing, radius, and typography come from `AppSpacing`, `AppRadius`, and `AppTypography` (via `context.text`). No raw `16`, `12`, or `fontSize: 18` in feature UI.

---

## 2. Breakpoints vs Content Width (CRITICAL)

These are two different concepts. Confusing them is a common mistake.

### What breakpoints are

**Breakpoints** decide **which layout to use** (mobile, tablet, or desktop). They answer: “Given the current width, do we show the mobile, tablet, or desktop variant?”

- Defined in **`core/layout/breakpoints.dart`**.
- Current values:
  - `Breakpoints.mobileMax = 600` — Width **&lt; 600** → **mobile**.
  - `Breakpoints.tabletMax = 1024` — Width **&lt; 1024** → **tablet**; **≥ 1024** → **desktop**.
- Used only for **layout choice**: e.g. inside `LayoutBuilder`, `Breakpoints.resolve(constraints.maxWidth)` returns `ScreenType.mobile | tablet | desktop`.

```
Width:    0 -------- 600 -------- 1024 --------> ∞
          [  mobile  ] [  tablet  ] [  desktop  ]
```

Use breakpoints when:

- Choosing which widget to show in `AdaptiveLayoutBuilder` (mobile / tablet / desktop).
- Resolving `ScreenType` for typography scale (e.g. in `ScreenTypeScope`).

### What content max width is

**Content max width** limits **how wide the content column is** inside a chosen layout. It does **not** define when we switch from mobile to tablet or tablet to desktop. It only constrains content for readability (e.g. long text lines).

- Defined in **`core/layout/layout_constants.dart`** (or equivalent).
- Example values:
  - `LayoutConstants.tabletContentMaxWidth = 720` — When we’re already in **tablet layout**, cap the content width at 720.
  - `LayoutConstants.desktopContentMaxWidth = 1200` — When we’re already in **desktop layout**, cap the content width at 1200.

Use content max width when:

- Wrapping the main content in a `ConstrainedBox` or `Container` so it doesn’t stretch to full width on large screens.

### Why mobileMax = 600 and tabletContentMaxWidth = 720 are NOT contradictory

- **600** is a **layout breakpoint**: “Viewport width &lt; 600 → use mobile layout.”
- **720** is a **content constraint**: “When we’re in tablet (or desktop) layout, don’t let the content get wider than 720.”

So:

- On a 700px-wide viewport we’re in **tablet layout** (700 ≥ 600).
- We then show a **centered** column with **max width 720**. So content is 700px wide (or less if you use 720 as max).
- On a 500px-wide viewport we’re in **mobile layout**; we typically use full width (no content max width, or a different constant if needed).

One number chooses layout; the other constrains content width inside that layout.

### When to use each

| Need | Use |
|------|-----|
| Decide mobile vs tablet vs desktop layout | `Breakpoints.resolve(width)` (inside layout layer, e.g. `LayoutBuilder`). |
| Limit content column width for readability | `ConstrainedBox(constraints: BoxConstraints(maxWidth: LayoutConstants.tabletContentMaxWidth))` (or desktop equivalent). |

### Example: layout decision vs content constraint

```dart
// ✅ Layout decision (inside AdaptiveLayoutBuilder / LayoutBuilder)
final screenType = Breakpoints.resolve(constraints.maxWidth);
return screenType == ScreenType.tablet ? tabletWidget : mobileWidget;

// ✅ Content constraint (inside the chosen layout widget)
Center(
  child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: LayoutConstants.tabletContentMaxWidth),
    child: content,
  ),
)
```

### Common mistakes

- **Using breakpoint values as content max width** — e.g. using `600` to constrain content. That mixes “when to switch layout” with “how wide the content is.”
- **Using content width to decide layout** — e.g. switching to “tablet” when width &gt; 720. Layout must be decided only by `Breakpoints.resolve(...)`.
- **Defining new breakpoint or content-width constants in features** — All such constants live in `core/layout/`.

---

## 3. Adaptive Layout System

### AdaptiveLayoutBuilder

The main widget for adaptive layout. It:

- Uses **LayoutBuilder** to get `constraints.maxWidth`.
- Resolves **ScreenType** with **Breakpoints.resolve(constraints.maxWidth)**.
- Picks **mobile**, **tablet**, or **desktop** child (with fallbacks).
- Wraps the chosen child in **ScreenTypeScope** so typography and any UI below can read screen type and text scale without using MediaQuery.

### How it works internally

```
LayoutBuilder
  → constraints.maxWidth
  → Breakpoints.resolve(maxWidth) → ScreenType
  → pick child: mobile | tablet ?? mobile | desktop ?? tablet ?? mobile
  → MediaQuery.textScaleFactorOf(context)  ← only MediaQuery use in this flow
  → ScreenTypeScope(screenType, textScaleFactor, child)
  → child
```

So:

1. **LayoutBuilder** gives us width without the widget tree depending on `MediaQuery.sizeOf(context)` in feature code.
2. **Breakpoints** are the single place that map width → ScreenType.
3. **Fallbacks**: if you don’t pass `tablet`, tablet uses `mobile`; if you don’t pass `desktop`, desktop uses `tablet` then `mobile`.
4. **ScreenTypeScope** is the only way UI and typography get screen type and text scale; they never read MediaQuery.

### Why LayoutBuilder is used

- Layout depends on **constraints** (what the parent gives us), not on the full screen. So we use `constraints.maxWidth` from LayoutBuilder instead of `MediaQuery.of(context).size.width`. This keeps layout predictable and testable and avoids unnecessary rebuilds from other MediaQuery fields.
- The only MediaQuery usage in this path is **textScaleFactorOf(context)** in the layout layer, so accessibility is respected in one place.

### Fallback rules

- **Desktop** → if no `desktop` widget, use `tablet`; if no `tablet`, use `mobile`.
- **Tablet** → if no `tablet` widget, use `mobile`.
- **Mobile** → always provided (required).

### Why UI must NOT use MediaQuery

- If every screen used `MediaQuery.of(context).size.width` or similar, we’d have multiple interpretations of “mobile” vs “tablet,” magic numbers, and no single place to change behavior.
- Typography and layout would be tied to raw size instead of the shared **ScreenType** and **design tokens**. So the rule is: **only the layout layer** (e.g. AdaptiveLayoutBuilder) uses MediaQuery; feature UI does not.

### Example usage

```dart
AdaptiveLayoutBuilder(
  mobile: _MobileLayout(...),
  tablet: _TabletLayout(...),
  desktop: _DesktopLayout(...),
);
```

Optional variant when you need the same widget tree with different layout logic:

```dart
AdaptiveLayoutBuilderX(
  builder: (context, screenType) {
    return screenType == ScreenType.desktop
        ? _WideLayout(...)
        : _NarrowLayout(...);
  },
);
```

---

## 4. ScreenTypeScope (VERY IMPORTANT)

### Why ScreenTypeScope exists

- The layout layer (e.g. AdaptiveLayoutBuilder) knows **ScreenType** and **textScaleFactor**.
- The rest of the app (typography, UI) must use that information **without** calling MediaQuery.
- So we need a way to “inject” screen type and text scale into the subtree. That’s **ScreenTypeScope**.

### Why it uses InheritedWidget

- **InheritedWidget** is the standard Flutter mechanism for passing data down the tree and triggering rebuilds when that data changes.
- When `ScreenTypeScope` is updated (e.g. after resize), any widget that used `ScreenTypeScope.screenTypeOf(context)` or `textScaleFactorOf(context)` will rebuild and get the new value.
- So we get reactive, layout-driven screen type and accessibility without MediaQuery in UI.

### How it replaces MediaQuery in UI

- **Before (wrong):** `final width = MediaQuery.of(context).size.width;` and then `if (width < 600) ...` or custom font sizes.
- **After (correct):** `final screenType = ScreenTypeScope.screenTypeOf(context);` and `context.text.headline()` (which internally uses that screen type). No width, no MediaQuery in the widget.

Typography (e.g. `context.text`) uses:

- `ScreenTypeScope.screenTypeOf(context)` → to pick TypographyScale (mobile / tablet / desktop).
- `ScreenTypeScope.textScaleFactorOf(context)` → to respect system accessibility.

So **ScreenTypeScope** is the only bridge from layout to typography and UI.

### Why a default fallback exists

- Some widgets (e.g. AppBar title) may be built **above** the body that’s wrapped in AdaptiveLayoutBuilder, so they’re **outside** any ScreenTypeScope.
- If we threw when scope is missing, the app would crash. So when scope is **not found**, we **default** to:
  - **ScreenType.mobile**
  - **textScaleFactor 1.0**
- That keeps the app running and gives a safe, predictable fallback.

### Why the debug warning is intentional

When scope is null, we still default to mobile and 1.0, but we **assert and debugPrint**:

```dart
assert(() {
  if (scope == null) {
    debugPrint(
      '⚠️ ScreenTypeScope not found. '
      'Defaulting to ScreenType.mobile.',
    );
  }
  return true;
}());
```

So in debug builds you see that part of the tree is **not** under an AdaptiveLayoutBuilder (or any provider of ScreenTypeScope). That helps you fix structure (e.g. wrap the route’s body in AdaptiveLayoutBuilder) so typography and layout are correct everywhere. In release, the assert is removed; behavior stays “default to mobile.”

### Data flow (summary)

```
MediaQuery (layout layer only)
    ↓
AdaptiveLayoutBuilder (LayoutBuilder + Breakpoints.resolve)
    ↓
ScreenTypeScope(screenType, textScaleFactor)
    ↓
UI & Typography (context.text, ScreenTypeScope.screenTypeOf(context))
```

---

## 5. Typography System (CORE)

### Why only ONE typography system exists

- Multiple systems (e.g. theme text styles + a separate “responsive” set) lead to inconsistent fonts and sizes and make it unclear which to use.
- So the app has **one** system: **AppTypography** (and its scale), exposed as **context.text** in the app layer. All text in UI should use `context.text.*()`.

### Why semantic roles are used

- We don’t want widgets to pick “font size 18” or “font size 14.” We want them to say “this is a **headline**” or “this is **body** text.”
- Semantic roles (**display**, **headline**, **title**, **body**, **label**, **caption**) map to one place that defines size and weight. Changing “headline” in one place updates the whole app.

### Why sizes are NOT hardcoded in UI

- Hardcoded `TextStyle(fontSize: 18)` in widgets breaks the single source of truth and ignores screen type and accessibility.
- Sizes are defined in **AppTextTokens** (base) and **TypographyScale** (per screen type and cap). UI only calls `context.text.headline()`, `context.text.body()`, etc.

### Why mobile font cap ≈ 20

- On small screens, very large type (e.g. 48px display) hurts readability and layout.
- So we **cap** font size on mobile at **20**. Larger semantic roles (display, headline) are scaled then clamped to 20 on mobile; on tablet and desktop the caps are higher (28 and 36).

### How accessibility scaling is respected

- The layout layer reads **MediaQuery.textScaleFactorOf(context)** once and passes it into **ScreenTypeScope** as **textScaleFactor**.
- **AppTypography** multiplies by this factor when computing font size (before applying the max cap). So system “large text” or “huge text” is respected without any MediaQuery usage in feature UI.

### Why methods (body()) are used instead of getters

- We use **methods** like `context.text.body()` and `context.text.headline()` so that each call gets a **fresh** AppTypography configured for the **current** ScreenTypeScope (and thus current screen type and text scale). If we used a getter like `context.text.body`, we’d have to ensure it was always evaluated in a context where the scope is already correct; methods make the “current context” semantics clear and avoid storing stale styles.

### AppTextTokens

- **File:** `core/design/app_text_tokens.dart`
- **Role:** Base font sizes (mobile-first reference). Not used directly in UI.
- **Values:** display 48, headline 32, title 20, body 16, label 14, caption 12.

### TypographyScale

- **File:** `core/design/typography_scale.dart`
- **Role:** For each **ScreenType**, defines a scale factor and a **max font size** (cap).

| ScreenType | factor | maxFontSize |
|------------|--------|-------------|
| mobile     | 1.0    | 20          |
| tablet     | 1.1    | 28          |
| desktop    | 1.2    | 36          |

Used by **typographyForScreen(ScreenType, ...)** to build **AppTypography**.

### AppTypography

- **File:** `core/design/app_typography.dart`
- **Role:** Holds color, fontFamily, scale, maxFontSize, textScaleFactor and exposes semantic **TextStyle** methods.
- **Methods:** `display()`, `headline()`, `title()`, `body()`, `label()`, `caption()`.
- **Internal:** `_size(base)` = min(base × scale × textScaleFactor, maxFontSize). So base sizes from AppTextTokens are scaled and then capped.

### typographyForScreen

- **Signature:** `typographyForScreen(ScreenType screenType, Color color, String fontFamily, {double textScaleFactor = 1.0})`.
- **Role:** Builds an **AppTypography** for the given screen type and options. Used by the **app layer** (e.g. `context.text` in app_theme_extension.dart), which gets ScreenType and textScaleFactor from **ScreenTypeScope** and color/fontFamily from **Theme**. UI must **not** call this with a width or MediaQuery; only with ScreenType from the scope.

### Example

```dart
Text(
  'Hello',
  style: context.text.headline(),
);
```

For body text:

```dart
Text(
  'Description here.',
  style: context.text.body(),
);
```

---

## 6. Context Usage (IMPORTANT CLARIFICATION)

### Why BuildContext is still used

- Flutter’s widget tree is context-based. We use **BuildContext** to:
  - Read **theme** (e.g. `context.theme.colors`).
  - Read **typography** (e.g. `context.text.headline()`), which internally uses ScreenTypeScope.
  - Get **inherited** data (ScreenTypeScope, Theme) in a standard way.

So context is the right abstraction for “where am I in the tree and what theme/scope do I have?”

### What context is allowed to do

- **Theme:** `Theme.of(context)`, `context.theme` (app theme extension).
- **Typography:** `context.text.headline()`, `context.text.body()`, etc.
- **Layout scope:** `ScreenTypeScope.screenTypeOf(context)`, `ScreenTypeScope.textScaleFactorOf(context)` (if you need screen type for non-typography logic, e.g. showing a different widget).
- **Routing:** e.g. `GoRouter.of(context)` for navigation (app-level concern).

So context is for **reading environment** (theme, scope, router), not for **making layout or style decisions** using raw MediaQuery or hardcoded numbers.

### What context must NEVER do

- **MediaQuery in feature UI:** Do not use `MediaQuery.of(context).size`, `MediaQuery.sizeOf(context)`, or similar in feature code. Layout and typography already get what they need from ScreenTypeScope and constraints.
- **Deciding layout from width:** Do not do `if (MediaQuery.of(context).size.width > 600)` in widgets. Use **AdaptiveLayoutBuilder** and pass mobile/tablet/desktop; the layout layer decides.
- **Hardcoded styles:** Do not use `TextStyle(fontSize: 18, ...)` or raw padding/radius numbers. Use `context.text.*()` and design tokens.

### Why GetX was intentionally NOT used

- The design system relies on **BuildContext** for theme and **ScreenTypeScope** (InheritedWidget). That fits Flutter’s tree and doesn’t require a global state or service for “current screen type.”
- Replacing context with GetX (or similar) would introduce another paradigm and make it harder to keep the rule “only layout layer uses MediaQuery; UI reads from scope and theme.” So we stick with context for reading environment and keep layout/typography in core.

### Difference between reading environment vs making decisions

- **Reading environment:** “What theme do I have? What screen type am I in? What’s the text scale?” → Use context (theme, ScreenTypeScope). Fine.
- **Making decisions:** “Is this mobile or tablet? How wide is the screen? What font size should this be?” → Those decisions are already encoded in **AdaptiveLayoutBuilder** (which layout to show) and **context.text** (which scale/cap to use). So UI should not re-derive them from MediaQuery or raw numbers.

### DO / DON’T table

| DO | DON’T |
|----|--------|
| Use `context.theme.colors`, `context.theme.fontFamily` | Use `MediaQuery.of(context).size` in features |
| Use `context.text.headline()`, `context.text.body()`, etc. | Use `TextStyle(fontSize: 18, ...)` in UI |
| Use `ScreenTypeScope.screenTypeOf(context)` if you need screen type in UI | Use width or breakpoint constants to decide layout in widgets |
| Use `AdaptiveLayoutBuilder` and pass mobile/tablet/desktop | Implement your own “if width &gt; 600” layout logic in screens |
| Use design tokens (`AppSpacing`, `AppRadius`) | Use raw numbers for padding, margin, radius |

---

## 7. Design Tokens (Spacing & Radius)

### AppSpacing

- **File:** `core/design/app_spacing.dart`
- **Role:** Single scale for spacing (padding, gaps). Mobile-first base scale.

| Token | Value |
|-------|--------|
| xs    | 4   |
| sm    | 8   |
| md    | 16  |
| lg    | 24  |
| xl    | 32  |
| xxl   | 48  |

**Example:**

```dart
Padding(
  padding: const EdgeInsets.all(AppSpacing.lg),
  child: content,
)
```

```dart
SizedBox(height: AppSpacing.sm),
```

### AppRadius

- **File:** `core/design/app_radius.dart`
- **Role:** Border radius tokens for consistency.

| Token | Value |
|-------|--------|
| sm   | 6   |
| md   | 12  |
| lg   | 20  |
| pill | 999 |

**Example:**

```dart
BorderRadius.circular(AppRadius.md)
```

### Why semantic spacing is used

- Names like **lg**, **xl** express **intent** (e.g. “section spacing” vs “tight gap”) instead of “24” or “32.” Changing the scale in one place (AppSpacing) updates the whole app.

### Why scaling intent is better than scaling pixels

- We could scale spacing by screen type (e.g. tablet = 1.2×), but the current system keeps spacing in **logical pixels** and uses the same tokens everywhere. If we later add per–screen-type spacing, we’d do it in **AppSpacing** (or a similar token layer), not by multiplying raw numbers in each widget.

---

## 8. Example Screens (Practical Usage)

### Home screen

- **Location:** `lib/features/home_page.dart`
- **Structure:**
  - **HomeScreen** (ConsumerWidget): watches `themeProvider`, reads `ThemeNotifier`, builds a **Scaffold** whose **body** is **AdaptiveLayoutBuilder** with three layout variants.
  - **Mobile:** `_MobileLayout` — `SingleChildScrollView` with `padding: EdgeInsets.all(AppSpacing.lg)`, full width.
  - **Tablet:** `_TabletLayout` — `Center` → `ConstrainedBox(maxWidth: LayoutConstants.tabletContentMaxWidth)` → scroll view with horizontal/vertical padding (AppSpacing.xl / lg).
  - **Desktop:** `_DesktopLayout` — Same idea with `LayoutConstants.desktopContentMaxWidth` and larger padding (AppSpacing.xxl / xl).
  - **HomeContent:** Dumb widget; no state, no layout choice. Uses only `context.text.headline()`, `context.text.body()`, `AppSpacing`, `AppRadius`, `context.theme.colors`. Theme toggle is done via passed-in `ThemeNotifier.setThemeMode`.

- **How layouts differ per screen type:** Layout **choice** is made by AdaptiveLayoutBuilder (mobile vs tablet vs desktop). Each layout widget then applies its own padding and content width (e.g. tablet 720, desktop 1200) so the same **HomeContent** is shown in a different container.
- **How typography adapts:** HomeContent uses `context.text.headline()` and `context.text.body()`. Those read **ScreenTypeScope** (set by AdaptiveLayoutBuilder), so on mobile fonts are capped at 20; on tablet/desktop they use the higher scale and cap. No MediaQuery in HomeContent.
- **How themes integrate:** Colors come from `context.theme.colors`; font family from theme is used inside `context.text`. Theme mode is controlled by Riverpod (`themeProvider` / `ThemeNotifier`); the widget only calls `themeNotifier.setThemeMode(...)`.

### Design system playground

- **Location:** `lib/test/design_pg.dart` (test/playground entry point)
- **Role:** Demonstrates the same patterns: **AdaptiveLayoutBuilder** with mobile/tablet/desktop, **ScreenTypeScope**, typography via `context.text`, **AppSpacing** and **AppRadius**. Tablet/desktop use a **ConstrainedBox** with a content max width (e.g. 720, 1200). Use it as a reference for “how to build a screen” without changing the design system.

---

## 9. Rules & Anti-Patterns (MANDATORY)

### ❌ DO NOT

- **Use MediaQuery in features** — No `MediaQuery.of(context).size`, `MediaQuery.sizeOf(context)`, or similar in feature or app UI. Only the layout layer (e.g. AdaptiveLayoutBuilder) may use MediaQuery (e.g. textScaleFactor).
- **Use `TextStyle(fontSize: …)` in UI** — Use `context.text.headline()`, `context.text.body()`, etc. Do not create one-off text styles with hardcoded font sizes.
- **Create new typography systems** — Do not add a second set of text styles or a “responsive” typography that bypasses AppTypography / context.text.
- **Decide layout in widgets** — Do not do `if (width > 600)` or switch on `MediaQuery` in feature widgets. Use **AdaptiveLayoutBuilder** and pass mobile/tablet/desktop.
- **Use breakpoints for content width** — Do not use `Breakpoints.mobileMax` or `Breakpoints.tabletMax` as the max width of a content column. Use **LayoutConstants** (e.g. tabletContentMaxWidth, desktopContentMaxWidth) for that.

### ✅ DO

- **Use AdaptiveLayoutBuilder** for adaptive screens — Pass `mobile`, and optionally `tablet` and `desktop`; let the layout layer resolve ScreenType from breakpoints.
- **Use `context.text.*()`** for all text styles — headline(), title(), body(), label(), caption(), display().
- **Use design tokens** — AppSpacing for padding/gaps, AppRadius for border radius. No raw 8, 16, 12, etc. in UI.
- **Let the layout layer decide screen type** — ScreenType comes from Breakpoints inside LayoutBuilder and is exposed via ScreenTypeScope; UI only consumes it.
- **Constrain content width when appropriate** — Use ConstrainedBox with LayoutConstants (tabletContentMaxWidth, desktopContentMaxWidth) inside tablet/desktop layouts, not breakpoint values.

---

## 10. FAQ / Common Confusions

### “Why not just use MediaQuery?”

- Using MediaQuery everywhere spreads layout and typography decisions across the app. Breakpoints and font sizes would drift (e.g. 600 here, 580 there). The design system centralizes those decisions: **Breakpoints** and **TypographyScale** in core, and **ScreenTypeScope** so UI gets one consistent “screen type” and text scale without touching MediaQuery. The only place that touches MediaQuery is the layout layer (and only for width → ScreenType and textScaleFactor).

### “Why not use GetX to remove context?”

- The system is built on Flutter’s tree: **Theme** and **ScreenTypeScope** are provided via the widget tree and read with **BuildContext**. That keeps “current theme” and “current screen type” aligned with the place in the tree (e.g. under which AdaptiveLayoutBuilder). GetX (or similar) would introduce a global way to get “current” values that can get out of sync with the tree (e.g. dialogs, overlays). So we keep context for reading environment and avoid adding another paradigm.

### “Why not scale fonts by width?”

- Scaling font size linearly with width (e.g. `fontSize: width * 0.05`) leads to huge type on desktop and tiny on mobile unless we add min/max and extra logic. The system uses **semantic roles** and a **fixed scale per screen type** (mobile / tablet / desktop) with a **cap**. That gives predictable, readable type at each breakpoint without magic formulas. Width is used only to **choose** screen type (breakpoints), not to multiply into font size in UI.

### “Why cap mobile font size?”

- On small screens, very large type (e.g. 48px display) wastes space and can hurt readability. Capping at **20** on mobile keeps hierarchy (display/headline still scale relative to body) while keeping the maximum size reasonable. Tablet and desktop use higher caps (28, 36) so type can be larger on bigger screens.

---

## Summary diagram

```
                    ┌─────────────────────────────────────┐
                    │         Layout layer only            │
                    │  LayoutBuilder → Breakpoints.resolve │
                    │  MediaQuery.textScaleFactorOf        │
                    └─────────────────┬───────────────────┘
                                      │
                                      ▼
                    ┌─────────────────────────────────────┐
                    │         ScreenTypeScope              │
                    │  screenType, textScaleFactor         │
                    └─────────────────┬───────────────────┘
                                      │
          ┌───────────────────────────┼───────────────────────────┐
          ▼                           ▼                           ▼
   ┌──────────────┐           ┌──────────────┐           ┌──────────────┐
   │ context.text │           │ UI widgets   │           │ Content width │
   │ (typography) │           │ (no MediaQuery)│           │ ConstrainedBox│
   └──────────────┘           └──────────────┘           └──────────────┘
   AppTypography               AppSpacing                  LayoutConstants
   TypographyScale              AppRadius                  (not breakpoints)
   AppTextTokens
```

After reading this document, a developer should be able to build new screens that use **AdaptiveLayoutBuilder**, **context.text**, and design tokens only, without re-introducing MediaQuery or hardcoded sizes, and keep the design system consistent and scalable.
