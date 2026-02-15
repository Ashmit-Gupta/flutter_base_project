# ADR-001: Typography Source of Truth & Scaling Strategy

## Status
Accepted

## Context
The app required a single, token-based typography system that:
- Works with Material 3 components
- Supports adaptive typography for content
- Keeps UI components layout-stable
- Avoids MediaQuery usage in widgets

Initially, typography was split between:
- AppTypography via context.text
- Flutter’s default ThemeData.textTheme for components

This caused inconsistent text sizes and violated the single source of truth principle.

## Decision
All typography derives from AppTextTokens and is delivered via two paths:

1. ThemeData.textTheme
    - Built from tokens at theme build time
    - Uses a fixed mobile baseline
    - Used by buttons, snackbars, and text fields

2. context.text (AppTypography)
    - Built at runtime using ScreenTypeScope
    - Scales by screen type and accessibility
    - Used for headings and content

Component text does not scale by screen type.

## Alternatives Considered
1. Making ThemeData.textTheme adaptive by screen type  
   Rejected: theme build time has no layout context; breaks layout stability.

2. Forcing all widgets to use context.text  
   Rejected: pushes layout and typography logic into widgets and breaks Material behavior.

3. Using Flutter default TextTheme for components  
   Rejected: violates token-based single source of truth.

## Consequences
- One typography source of truth (AppTextTokens)
- Stable component layouts across screen sizes
- Adaptive typography preserved for content
- Clear separation of responsibilities

## References
- docs/design-system.md
