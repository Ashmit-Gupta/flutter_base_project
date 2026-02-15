import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../test/design_pg.dart';

class AppLabeledTextField extends StatelessWidget {
  const AppLabeledTextField({
    super.key,
    required this.controller,
    required this.heading,
    this.focusNode,
    this.hint,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.autovalidateMode,
    this.onChanged,
    this.onFieldSubmitted,
    this.onEditingComplete,
    this.autofillHints,
    this.inputFormatters,
    this.maxLength,
    this.maxLines = 1,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.enableSuggestions = true,
    this.autocorrect = true,
    this.textCapitalization = TextCapitalization.none,
    this.prefixIcon,
    this.suffixIcon,
    this.spacing,
  });

  /// Controllers
  final TextEditingController controller;
  final FocusNode? focusNode;

  /// Heading
  final String heading;

  /// Optional override (defaults to AppSpacing.sm)
  final double? spacing;

  /// Field text
  final String? hint;

  /// Keyboard
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  /// Validation
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;

  /// Callbacks
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final VoidCallback? onEditingComplete;

  /// Constraints
  final int? maxLength;
  final int maxLines;

  /// State
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool enableSuggestions;
  final bool autocorrect;

  /// UI
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: theme.textTheme.labelLarge,
        ),

        SizedBox(
          height: spacing ?? AppSpacing.sm,
        ),

        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          autovalidateMode: autovalidateMode,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          onEditingComplete: onEditingComplete,
          autofillHints: autofillHints,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          maxLines: maxLines,
          obscureText: obscureText,
          enabled: enabled,
          readOnly: readOnly,
          enableSuggestions: enableSuggestions,
          autocorrect: autocorrect,
          textCapitalization: textCapitalization,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
