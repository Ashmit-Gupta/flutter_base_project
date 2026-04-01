import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../app/theme/app_theme_extension.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/feedback/app_snackbar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/file_picker_widget.dart';
import '../../../../features/shared/file_controller.dart';

class RegisterEmployeeScreen extends HookConsumerWidget {
  const RegisterEmployeeScreen({super.key});

  static const int _minUploads = 3;
  static const int _maxUploads = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final employeeController = useTextEditingController();
    final fileController = ref.read(fileControllerProvider.notifier);
    final colors = context.theme.colors;

    void submit() {
      if (formKey.currentState?.validate() != true) return;
      final fileValidationMessage = fileController.validateFileCount(
        minFiles: _minUploads,
        maxFiles: _maxUploads,
      );
      if (fileValidationMessage != null) {
        AppSnackbar.error(context, fileValidationMessage);
        return;
      }
      AppSnackbar.success(context, 'Employee registration submitted');
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text('Register Employee', style: context.text.title()),
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  controller: employeeController,
                  label: 'Select Employee',
                  hint: 'Enter employee name',
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Employee name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                FilePickerWidget(
                  maxFiles: _maxUploads,
                  fileTypesHint: 'Select Photos from gallery, camera',
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: colors.border)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SizedBox(
              width: double.infinity,
              child: AppButton(label: 'Submit', onPressed: submit),
            ),
          ),
        ),
      ),
    );
  }
}
