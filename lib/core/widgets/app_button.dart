import 'package:flutter/material.dart';

import '../design/app_spacing.dart';
import '../../app/theme/app_button_theme.dart';
import '../../app/theme/app_theme_extension.dart';
import 'app_button_variant.dart';

/// Reusable, theme-driven button.
///
/// - Uses [AppButtonTheme] for all styling — no hard-coded colors or text styles.
/// - Supports primary, secondary, and danger variants.
/// - Supports loading, disabled, and icon states.
/// - Material 3 compliant (FilledButton / OutlinedButton).
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.loading = false,
    this.icon,
    this.iconPosition = IconPosition.leading,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool loading;
  final Widget? icon;
  final IconPosition iconPosition;

  bool get _isDisabled => onPressed == null || loading;

  ButtonStyle _styleForVariant(BuildContext context) {
    final buttonTheme = Theme.of(context).extension<AppButtonTheme>()!;
    return switch (variant) {
      AppButtonVariant.primary => buttonTheme.primaryStyle,
      AppButtonVariant.secondary => buttonTheme.secondaryStyle,
      AppButtonVariant.danger => buttonTheme.dangerStyle,
    };
  }

  Widget _buildContent(BuildContext context) {
    if (loading) {
      final colors = context.theme.colors;
      return SizedBox(
        height: AppSpacing.lg,
        width: AppSpacing.lg,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            variant == AppButtonVariant.secondary
                ? colors.primary
                : colors.onPrimary,
          ),
        ),
      );
    }

    final textTheme = Theme.of(context).textTheme;
    final labelWidget = Text(label, style: textTheme.labelLarge);
    final iconWidget = icon;

    if (iconWidget == null) return labelWidget;

    const gap = SizedBox(width: AppSpacing.sm);
    final children = iconPosition == IconPosition.leading
        ? [iconWidget, gap, labelWidget]
        : [labelWidget, gap, iconWidget];

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = _styleForVariant(context);

    return switch (variant) {
      AppButtonVariant.primary => FilledButton(
          onPressed: _isDisabled ? null : onPressed,
          style: style,
          child: _buildContent(context),
        ),
      AppButtonVariant.secondary => OutlinedButton(
          onPressed: _isDisabled ? null : onPressed,
          style: style,
          child: _buildContent(context),
        ),
      AppButtonVariant.danger => FilledButton(
          onPressed: _isDisabled ? null : onPressed,
          style: style,
          child: _buildContent(context),
        ),
    };
  }
}

/// Position of the icon relative to the label.
enum IconPosition {
  leading,
  trailing,
}
