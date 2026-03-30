import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(const _PlaygroundApp());
}

/* ============================================================
   APP ROOT
   ============================================================ */

class _PlaygroundApp extends StatefulWidget {
  const _PlaygroundApp();

  @override
  State<_PlaygroundApp> createState() => _PlaygroundAppState();
}

class _PlaygroundAppState extends State<_PlaygroundApp> {
  ThemeMode _mode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _mode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: DesignSystemPlayground(
        themeMode: _mode,
        onThemeChanged: (m) => setState(() => _mode = m),
      ),
    );
  }
}

/* ============================================================
   BREAKPOINTS
   ============================================================ */

enum ScreenType { mobile, tablet, desktop }

class Breakpoints {
  static const double mobileMax = 600;
  static const double tabletMax = 1024;

  static ScreenType resolve(double width) {
    if (width < mobileMax) return ScreenType.mobile;
    if (width < tabletMax) return ScreenType.tablet;
    return ScreenType.desktop;
  }
}

/* ============================================================
   SCREEN TYPE SCOPE
   ============================================================ */

class ScreenTypeScope extends InheritedWidget {
  final ScreenType screenType;
  final double textScaleFactor;

  const ScreenTypeScope({
    required this.screenType,
    required this.textScaleFactor,
    required super.child,
    super.key,
  });

  static ScreenType screenTypeOf(BuildContext context) {
    final scope =
    context.dependOnInheritedWidgetOfExactType<ScreenTypeScope>();

    assert(() {
      if (scope == null) {
        debugPrint(
          '⚠️ ScreenTypeScope not found. Defaulting to mobile.',
        );
      }
      return true;
    }());

    return scope?.screenType ?? ScreenType.mobile;
  }

  static double textScaleFactorOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ScreenTypeScope>()
        ?.textScaleFactor ??
        1.0;
  }

  @override
  bool updateShouldNotify(ScreenTypeScope oldWidget) {
    return screenType != oldWidget.screenType ||
        textScaleFactor != oldWidget.textScaleFactor;
  }
}

/* ============================================================
   ADAPTIVE LAYOUT BUILDER
   ============================================================ */

class AdaptiveLayoutBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const AdaptiveLayoutBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final type = Breakpoints.resolve(constraints.maxWidth);

        Widget child;
        switch (type) {
          case ScreenType.mobile:
            child = mobile;
            break;
          case ScreenType.tablet:
            child = tablet ?? mobile;
            break;
          case ScreenType.desktop:
            child = desktop ?? tablet ?? mobile;
            break;
        }

        return ScreenTypeScope(
          screenType: type,
          textScaleFactor: MediaQuery.textScaleFactorOf(context),
          child: child,
        );
      },
    );
  }
}

/* ============================================================
   DESIGN TOKENS
   ============================================================ */

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

class AppRadius {
  static const double sm = 6;
  static const double md = 12;
  static const double lg = 20;
}

/* ============================================================
   TYPOGRAPHY
   ============================================================ */

class TypographyScale {
  final double scale;
  final double max;

  const TypographyScale(this.scale, this.max);

  static TypographyScale fromScreen(ScreenType type) {
    switch (type) {
      case ScreenType.mobile:
        return const TypographyScale(1.0, 20);
      case ScreenType.tablet:
        return const TypographyScale(1.1, 28);
      case ScreenType.desktop:
        return const TypographyScale(1.2, 36);
    }
  }
}

class AppTypography {
  final Color color;
  final double textScale;
  final TypographyScale scale;

  const AppTypography({
    required this.color,
    required this.textScale,
    required this.scale,
  });

  double _size(double base) {
    final scaled = base * scale.scale * textScale;
    return math.min(scaled, scale.max);
  }

  TextStyle display() =>
      TextStyle(fontSize: _size(48), fontWeight: FontWeight.bold, color: color);
  TextStyle headline() =>
      TextStyle(fontSize: _size(32), fontWeight: FontWeight.w600, color: color);
  TextStyle title() =>
      TextStyle(fontSize: _size(20), fontWeight: FontWeight.w500, color: color);
  TextStyle body() =>
      TextStyle(fontSize: _size(16), color: color);
  TextStyle label() =>
      TextStyle(fontSize: _size(14), fontWeight: FontWeight.w500, color: color);
  TextStyle caption() =>
      TextStyle(fontSize: _size(12), color: color.withOpacity(0.7));
}

extension TypographyX on BuildContext {
  AppTypography get text {
    final screen = ScreenTypeScope.screenTypeOf(this);
    return AppTypography(
      color: Theme.of(this).colorScheme.onSurface,
      textScale: ScreenTypeScope.textScaleFactorOf(this),
      scale: TypographyScale.fromScreen(screen),
    );
  }
}

/* ============================================================
   PLAYGROUND SCREEN
   ============================================================ */

class DesignSystemPlayground extends StatelessWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const DesignSystemPlayground({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayoutBuilder(
      mobile: _PlaygroundScaffold(
        title: 'Design Playground (Mobile)',
        child: _PlaygroundContent(
          themeMode: themeMode,
          onThemeChanged: onThemeChanged,
        ),
      ),
      tablet: _PlaygroundCentered(
        maxWidth: 720,
        title: 'Design Playground (Tablet)',
        themeMode: themeMode,
        onThemeChanged: onThemeChanged,
      ),
      desktop: _PlaygroundCentered(
        maxWidth: 1200,
        title: 'Design Playground (Desktop)',
        themeMode: themeMode,
        onThemeChanged: onThemeChanged,
        withSidePanel: true,
      ),
    );
  }
}

/* ============================================================
   LAYOUT VARIANTS
   ============================================================ */

class _PlaygroundScaffold extends StatelessWidget {
  final String title;
  final Widget child;

  const _PlaygroundScaffold({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: child,
    );
  }
}

class _PlaygroundCentered extends StatelessWidget {
  final double maxWidth;
  final String title;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final bool withSidePanel;

  const _PlaygroundCentered({
    required this.maxWidth,
    required this.title,
    required this.themeMode,
    required this.onThemeChanged,
    this.withSidePanel = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = _PlaygroundContent(
      themeMode: themeMode,
      onThemeChanged: onThemeChanged,
    );

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: withSidePanel
              ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: content),
              const SizedBox(width: AppSpacing.xl),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceVariant,
                    borderRadius:
                    BorderRadius.circular(AppRadius.md),
                  ),
                  child: Text(
                    'Desktop Side Panel',
                    style: context.text.body(),
                  ),
                ),
              ),
            ],
          )
              : content,
        ),
      ),
    );
  }
}

/* ============================================================
   CONTENT
   ============================================================ */

class _PlaygroundContent extends StatelessWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const _PlaygroundContent({
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final screen = ScreenTypeScope.screenTypeOf(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _section(
          context,
          'System Info',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ScreenType: ${screen.name}', style: context.text.body()),
              Text('Theme: ${themeMode.name}', style: context.text.body()),
            ],
          ),
        ),
        _section(
          context,
          'Typography',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Display', style: context.text.display()),
              Text('Headline', style: context.text.headline()),
              Text('Title', style: context.text.title()),
              Text('Body', style: context.text.body()),
              Text('Label', style: context.text.label()),
              Text('Caption', style: context.text.caption()),
            ],
          ),
        ),
        _section(
          context,
          'Theme',
          Column(
            children: ThemeMode.values.map((m) {
              return RadioListTile<ThemeMode>(
                title: Text(m.name, style: context.text.body()),
                value: m,
                groupValue: themeMode,
                onChanged: (v) {
                  if (v != null) onThemeChanged(v);
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _section(BuildContext context, String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.text.headline()),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}
