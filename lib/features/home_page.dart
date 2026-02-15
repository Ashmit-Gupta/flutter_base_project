import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_theme_extension.dart';
import '../../app/theme/theme_mode.dart';
import '../../app/theme/theme_notifier.dart';
import '../../app/theme/theme_provider.dart';
import '../../app/theme/theme_state.dart';
import '../../core/design/app_radius.dart';
import '../../core/design/app_spacing.dart';
import '../../core/layout/adaptive_layout_builder.dart';
import '../core/layout/layout_constants.dart';

/// Home screen: dumb shell. State from Riverpod; layout from [AdaptiveLayoutBuilder].
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          style: context.text.title(),
        ),
      ),
      body: AdaptiveLayoutBuilder(
        mobile: _MobileLayout(
          themeState: themeState,
          themeNotifier: themeNotifier,
        ),
        tablet: _TabletLayout(
          themeState: themeState,
          themeNotifier: themeNotifier,
        ),
        desktop: _DesktopLayout(
          themeState: themeState,
          themeNotifier: themeNotifier,
        ),
      ),
    );
  }
}

/// Mobile: stacked single column, full width.
class _MobileLayout extends StatelessWidget {
  const _MobileLayout({
    required this.themeState,
    required this.themeNotifier,
  });

  final ThemeState themeState;
  final ThemeNotifier themeNotifier;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: HomeContent(
        themeState: themeState,
        themeNotifier: themeNotifier,
      ),
    );
  }
}

/// Tablet: centered, constrained width.
class _TabletLayout extends StatelessWidget {
  const _TabletLayout({
    required this.themeState,
    required this.themeNotifier,
  });

  final ThemeState themeState;
  final ThemeNotifier themeNotifier;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: LayoutConstants.tabletContentMaxWidth),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          child: HomeContent(
            themeState: themeState,
            themeNotifier: themeNotifier,
          ),
        ),
      ),
    );
  }
}

/// Desktop: wide, centered with max width.
class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({
    required this.themeState,
    required this.themeNotifier,
  });

  final ThemeState themeState;
  final ThemeNotifier themeNotifier;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: LayoutConstants.desktopContentMaxWidth),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.xl,
          ),
          child: HomeContent(
            themeState: themeState,
            themeNotifier: themeNotifier,
          ),
        ),
      ),
    );
  }
}

/// Dumb content: no layout logic, no state. Uses only design tokens and context.text.
class HomeContent extends StatelessWidget {
  const HomeContent({
    super.key,
    required this.themeState,
    required this.themeNotifier,
  });

  final ThemeState themeState;
  final ThemeNotifier themeNotifier;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Current Theme Mode',
          style: context.text.headline(),
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          themeState.mode.name.toUpperCase(),
          style: context.text.body(),
        ),
        SizedBox(height: AppSpacing.xl),
        Text(
          'Select Theme',
          style: context.text.headline(),
        ),
        SizedBox(height: AppSpacing.sm),
        _ThemeRadio(
          label: 'System',
          value: AppThemeMode.system,
          groupValue: themeState.mode,
          onChanged: themeNotifier.setThemeMode,
        ),
        _ThemeRadio(
          label: 'Light',
          value: AppThemeMode.light,
          groupValue: themeState.mode,
          onChanged: themeNotifier.setThemeMode,
        ),
        _ThemeRadio(
          label: 'Dark',
          value: AppThemeMode.dark,
          groupValue: themeState.mode,
          onChanged: themeNotifier.setThemeMode,
        ),
        SizedBox(height: AppSpacing.xl),
        Text(
          'Visual Test',
          style: context.text.headline(),
        ),
        SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: context.theme.colors.primary,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Text(
            'Primary Color Container',
            style: context.text.body().copyWith(color: Colors.white),
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Text(
          'This text uses the unified typography system. '
          'Resize the window or toggle theme.',
          style: context.text.body(),
        ),
      ],
    );
  }
}

class _ThemeRadio extends StatelessWidget {
  const _ThemeRadio({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String label;
  final AppThemeMode value;
  final AppThemeMode groupValue;
  final ValueChanged<AppThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<AppThemeMode>(
      title: Text(label, style: context.text.body()),
      value: value,
      groupValue: groupValue,
      onChanged: (mode) {
        if (mode != null) onChanged(mode);
      },
    );
  }
}
