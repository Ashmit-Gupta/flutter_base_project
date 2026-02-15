import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../layout/breakpoints.dart';
import 'app_text_tokens.dart';
import 'typography_scale.dart';

/// Central adaptive typography system for the application.
///
/// This class provides **semantic text styles** instead of raw font sizes,
/// ensuring:
/// - Consistent typography across the app
/// - Automatic adaptation to screen size (mobile / tablet / desktop)
/// - Accessibility support via [textScaleFactor]
/// - A hard cap on font sizes to prevent layout breakage
///
/// ### Semantic Roles
/// Prefer these roles over arbitrary font sizes:
/// - `display`   → Large hero text, onboarding titles
/// - `headline`  → Section headers
/// - `title`     → Card titles, dialogs
/// - `body`      → Main content text
/// - `label`     → Buttons, form labels
/// - `caption`   → Helper text, metadata
///
/// ### Architectural Rules
/// ❌ Do NOT compute screen width or use `MediaQuery` in UI widgets
/// ✅ Obtain this via `context.text` or app-layer composition
///
/// ### Accessibility
/// - Respects system font scaling via [textScaleFactor]
/// - Font sizes are capped using [maxFontSize] to avoid overflow
class AppTypography {
  /// Creates an adaptive typography configuration.
  ///
  /// All sizing decisions are finalized here so that UI widgets remain
  /// purely declarative.
  AppTypography({
    required this.color,
    required this.fontFamily,
    required this.scale,
    required this.maxFontSize,
    this.textScaleFactor = 1.0,
  });

  /// Base text color applied to all text styles.
  final Color color;

  /// Font family used throughout the app.
  final String fontFamily;

  /// Scaling factor derived from [ScreenType] (mobile/tablet/desktop).
  ///
  /// Example:
  /// - Mobile → `1.0`
  /// - Tablet → `1.1`
  /// - Desktop → `1.2`
  final double scale;

  /// Absolute upper limit for font sizes.
  ///
  /// This prevents accessibility scaling or large screens from
  /// producing unreadable or layout-breaking text.
  final double maxFontSize;

  /// Accessibility text scale factor.
  ///
  /// Usually comes from system settings and must always be respected.
  final double textScaleFactor;

  /// Computes the final font size after applying:
  /// - Base token size
  /// - Screen scale factor
  /// - Accessibility scaling
  /// - Maximum font size clamp
  double _size(double base) {
    final scaled = base * scale * textScaleFactor;
    return math.min(scaled, maxFontSize);
  }

  /// Large, high-emphasis text.
  ///
  /// Use for landing screens, hero banners, or onboarding.
  TextStyle display() => TextStyle(
    fontSize: _size(AppTextTokens.display),
    fontWeight: FontWeight.bold,
    color: color,
    fontFamily: fontFamily,
  );

  /// Primary section headers.
  ///
  /// Slightly smaller than [display] but still high hierarchy.
  TextStyle headline() => TextStyle(
    fontSize: _size(AppTextTokens.headline),
    fontWeight: FontWeight.w600,
    color: color,
    fontFamily: fontFamily,
  );

  /// Titles for cards, dialogs, and list sections.
  TextStyle title() => TextStyle(
    fontSize: _size(AppTextTokens.title),
    fontWeight: FontWeight.w500,
    color: color,
    fontFamily: fontFamily,
  );

  /// Default body text.
  ///
  /// Use for paragraphs, descriptions, and long-form content.
  TextStyle body() => TextStyle(
    fontSize: _size(AppTextTokens.body),
    color: color,
    fontFamily: fontFamily,
  );

  /// Labels for buttons, form fields, and compact UI elements.
  TextStyle label() => TextStyle(
    fontSize: _size(AppTextTokens.label),
    fontWeight: FontWeight.w500,
    color: color,
    fontFamily: fontFamily,
  );

  /// Low-emphasis supporting text.
  ///
  /// Used for hints, timestamps, and metadata.
  TextStyle caption() => TextStyle(
    fontSize: _size(AppTextTokens.caption),
    color: color.withValues(alpha: 0.7),
    fontFamily: fontFamily,
  );
}

/// Factory method to create [AppTypography] for a given [ScreenType].
///
/// ### Responsibility
/// This function belongs to the **app layer**, not UI.
/// It converts layout context into a typography configuration.
///
/// ### Rules
/// ❌ UI widgets must NOT call this directly
/// ❌ Do NOT derive [ScreenType] from `MediaQuery` inside widgets
/// ✅ Use `ScreenTypeScope` to obtain screen type
///
/// ### Flow
/// `ScreenType` → `TypographyScale` → `AppTypography`
AppTypography typographyForScreen(
    ScreenType screenType,
    Color color,
    String fontFamily, {
      double textScaleFactor = 1.0,
    }) {
  final ts = TypographyScale.fromScreen(screenType);

  return AppTypography(
    color: color,
    fontFamily: fontFamily,
    scale: ts.factor,
    maxFontSize: ts.maxFontSize,
    textScaleFactor: textScaleFactor,
  );
}
