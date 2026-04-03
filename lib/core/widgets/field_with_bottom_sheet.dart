import 'package:basic_project_setup/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import '../../app/theme/app_theme_extension.dart';

/// Generic Field With Bottom Sheet Picker
class FieldWithBottomSheet extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final bool showTrailingIcon;
  final Icon trailingIcon;
  final Widget? bottomSheet;
  final VoidCallback? trailingFunction;
  final bool isReadOnly;
  final FocusNode? focusNode;
  final void Function(String value)? onSelected;
  final String? label;
  final String? hint;

  const FieldWithBottomSheet({
    super.key,
    required this.title,
    required this.controller,
    this.showTrailingIcon = true,
    this.focusNode,
    this.trailingFunction,
    this.isReadOnly = false,
    this.trailingIcon = const Icon(Icons.arrow_drop_down_rounded),
    required this.bottomSheet,
    this.onSelected, // 🔹 Allow parent to handle selection
    this.label,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final readOnlyFillColor = isReadOnly ? colors.background : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   title,
        //   style: context.text.body().copyWith(fontWeight: FontWeight.w600),
        // ),
        // const SizedBox(height: 4),
        AppTextField(
          fillColor: readOnlyFillColor,
          focusNode: focusNode,
          readOnly: isReadOnly,
          maxLines: 1,
          showCursor: false,
          label: label,
          hint: hint,
          keyboardType: TextInputType.none,
          enableInteractiveSelection: false,
          controller: controller,
          suffixIcon: showTrailingIcon
              ? IconButton(
                  onPressed: trailingFunction,
                  icon: IconTheme(
                    data: IconThemeData(color: colors.textSecondary),
                    child: trailingIcon,
                  ),
                )
              : null,
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return '$title is required';
            }
            return null;
          },
          onTap: bottomSheet != null
              ? () async {
                  final result = await showModalBottomSheet<String>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => bottomSheet!,
                  );
                  if (result != null && result.isNotEmpty) {
                    controller.text = result;
                    if (onSelected != null) {
                      onSelected!(result); // Delegate logic to parent
                    }
                  }
                }
              : null,
        ),
      ],
    );
  }
}
