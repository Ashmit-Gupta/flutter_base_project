import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_theme_extension.dart';
import '../../app/routes.dart';
import '../../app/theme/theme_mode.dart';
import '../../app/theme/theme_notifier.dart';
import '../../app/theme/theme_provider.dart';
import '../../app/theme/theme_state.dart';
import '../../core/design/app_radius.dart';
import '../../core/design/app_spacing.dart';
import '../../core/layout/adaptive_layout_builder.dart';
import '../core/layout/layout_constants.dart';
import '../../core/feedback/app_snackbar.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_button_variant.dart';
import '../core/widgets/app_labeled_text_field.dart';
import '../../core/widgets/app_text_field.dart';

/// Home screen: dumb shell. State from Riverpod; layout from [AdaptiveLayoutBuilder].
class DesignSystemScreen extends ConsumerWidget {
  const DesignSystemScreen({super.key});

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
        constraints: const BoxConstraints(
          maxWidth: LayoutConstants.tabletContentMaxWidth,
        ),
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
        constraints: const BoxConstraints(
          maxWidth: LayoutConstants.desktopContentMaxWidth,
        ),
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

/// Dumb content: no layout logic, no state.
/// Uses ONLY design tokens, context.text, and reusable widgets.
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
    final normalController = TextEditingController();
    final errorController = TextEditingController(text: '123');
    final disabledController = TextEditingController(text: 'Disabled value');

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
          'TextField Visual States',
          style: context.text.headline(),
        ),
        SizedBox(height: AppSpacing.sm),

        /// ✅ Normal state
        AppTextField(
          controller: normalController,
          label: 'Normal Field',
          hint: 'Enter value',
        ),

        SizedBox(height: AppSpacing.md),

        /// ❌ Error state (validator-driven)
        AppTextField(
          controller: errorController,
          label: 'Error Field',
          hint: 'Enter a number',
          autovalidateMode: AutovalidateMode.always,
          validator: (value) {
            if (value == null || value.length < 5) {
              return 'Minimum 5 characters required';
            }
            return null;
          },
        ),

        SizedBox(height: AppSpacing.md),

        /// 🚫 Disabled state
        AppTextField(
          controller: disabledController,
          label: 'Disabled Field',
          enabled: false,
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
          'Toggle light/dark theme to verify '
              'normal, error, and disabled states.',
          style: context.text.body(),
        ),
        SizedBox(height: AppSpacing.md),
        Text(
          'TextField Visual States',
          style: context.text.headline(),
        ),
        SizedBox(height: AppSpacing.sm),

        /// ✅ Normal
        AppLabeledTextField(
          heading: 'Normal Field',
          controller: normalController,
          hint: 'Enter value',
        ),

        SizedBox(height: AppSpacing.md),

        /// ❌ Error
        AppLabeledTextField(
          heading: 'Error Field',
          controller: errorController,
          hint: 'Enter a number',
          autovalidateMode: AutovalidateMode.always,
          validator: (value) {
            if (value == null || value.length < 5) {
              return 'Minimum 5 characters required';
            }
            return null;
          },
        ),

        SizedBox(height: AppSpacing.md),

        /// 🚫 Disabled
        AppLabeledTextField(
          heading: 'Disabled Field',
          controller: disabledController,
          enabled: false,
        ),

        SizedBox(height: AppSpacing.xl),

        Text(
          'AppButton Examples',
          style: context.text.headline(),
        ),
        SizedBox(height: AppSpacing.sm),

        AppButton(
          label: 'Primary Button',
          onPressed: () {},
          variant: AppButtonVariant.primary,
        ),

        SizedBox(height: AppSpacing.md),

        AppButton(
          label: 'Loading Button',
          onPressed: () {},
          loading: true,
          variant: AppButtonVariant.primary,
        ),

        SizedBox(height: AppSpacing.md),

        AppButton(
          label: 'Disabled Button',
          onPressed: null,
          variant: AppButtonVariant.primary,
        ),

        SizedBox(height: AppSpacing.xl),

        Text(
          'AppSnackbar Examples',
          style: context.text.headline(),
        ),
        SizedBox(height: AppSpacing.sm),

        AppButton(
          label: 'Login success',
          onPressed: () => AppSnackbar.success(
            context,
            'Signed in successfully',
          ),
          variant: AppButtonVariant.primary,
        ),

        SizedBox(height: AppSpacing.md),

        AppButton(
          label: 'Warning',
          onPressed: () => AppSnackbar.warning(
            context,
            'Low balance. Add funds to continue.',
          ),
          variant: AppButtonVariant.secondary,
        ),

        SizedBox(height: AppSpacing.md),

        AppButton(
          label: 'Error',
          onPressed: () => AppSnackbar.error(
            context,
            'Connection failed. Check your network.',
          ),
          variant: AppButtonVariant.danger,
        ),

        SizedBox(height: AppSpacing.md),

        AppButton(
          label: 'Info',
          onPressed: () => AppSnackbar.info(
            context,
            'Coupon expires in 24 hours',
          ),
          variant: AppButtonVariant.secondary,
        ),

        SizedBox(height: AppSpacing.xl),

        Text(
          'Navigation',
          style: context.text.headline(),
        ),
        SizedBox(height: AppSpacing.sm),

        AppButton(
          label: 'Go to Login',
          onPressed: () => context.push(AppRoutes.login),
          variant: AppButtonVariant.primary,
        ),

        SizedBox(height: AppSpacing.md),

        AppButton(
          label: 'Go to Signup',
          onPressed: () => context.push(AppRoutes.signup),
          variant: AppButtonVariant.secondary,
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
