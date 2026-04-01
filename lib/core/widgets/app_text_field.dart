import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    this.focusNode,
    this.label,
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
    this.onTapOutside,
    this.onTap,
    this.showCursor,
    this.enableInteractiveSelection = true,
    this.fillColor,
  });

  /// Controllers (owned by Hooks / UI layer)
  final TextEditingController controller;
  final FocusNode? focusNode;

  /// Text
  final String? label;
  final String? hint;

  /// Keyboard & input
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;

  /// Validation
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;

  /// Callbacks
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final VoidCallback? onEditingComplete;
  final TapRegionCallback? onTapOutside;
  final VoidCallback? onTap;

  /// Constraints
  final int? maxLength;
  final int maxLines;

  /// State
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool enableSuggestions;
  final bool autocorrect;
  final bool? showCursor;
  final bool enableInteractiveSelection;

  /// UI
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return TextFormField(
      style: textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        fillColor: fillColor,
        filled: fillColor != null,
      ),
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      autovalidateMode: autovalidateMode,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      onEditingComplete: onEditingComplete,
      onTapOutside: onTapOutside,
      onTap: onTap,
      autofillHints: autofillHints,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      maxLines: maxLines,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      enableSuggestions: enableSuggestions,
      autocorrect: autocorrect,
      showCursor: showCursor,
      enableInteractiveSelection: enableInteractiveSelection,
      textCapitalization: textCapitalization,
    );
  }
}
