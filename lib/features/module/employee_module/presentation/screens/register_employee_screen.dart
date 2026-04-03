import 'package:basic_project_setup/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../../app/theme/app_theme_extension.dart';
import '../../../../../core/design/app_spacing.dart';
import '../../../../../core/feedback/app_snackbar.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/file_picker_widget.dart';
import '../../data/model/get_all_employee_model.dart';
import '../view_models/register_employee_view_model.dart';

class RegisterEmployeeScreen extends HookConsumerWidget {
  const RegisterEmployeeScreen({super.key, this.initialEmployee});

  final GetAllEmployeeUserModel? initialEmployee;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final employeeController = useTextEditingController();
    final viewState = ref.watch(registerEmployeeViewModelProvider);
    final vm = ref.read(registerEmployeeViewModelProvider.notifier);
    useEffect(() {
      final employee = initialEmployee;
      if (employee != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          vm.selectEmployee(employee);
        });
      }
      return null;
    }, [initialEmployee?.employeeId]);

    useEffect(() {
      if (viewState.selectedEmployeeName != null) {
        employeeController.text = viewState.selectedEmployeeName!;
      }
      return null;
    }, [viewState.selectedEmployeeName]);

    final colors = context.theme.colors;

    ref.listen<RegisterEmployeeState>(registerEmployeeViewModelProvider, (
      previous,
      next,
    ) {
      final error = next.errorMessage;
      if (error != null &&
          error.isNotEmpty &&
          error != previous?.errorMessage) {
        AppSnackbar.error(context, error);
      }
    });

    Future<void> submit() async {
      final result = await vm.submit(
        isFormValid: formKey.currentState?.validate() == true,
      );
      if (!context.mounted) return;
      if (result.isError) {
        AppSnackbar.error(context, result.message);
      } else {
        AppSnackbar.success(context, result.message);
        context.pop();
      }
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
                  enabled: false,
                  readOnly: true,
                  fillColor: colors.background,
                  label: 'Select Employee',
                  hint: 'Enter Employee Name',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Select Employee is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                const FilePickerWidget(
                  title: 'Left Profile',
                  maxFiles: 1,
                  profileKey: 'left_profile',
                  fileTypesHint: 'Select photo from gallery or camera',
                ),
                const SizedBox(height: AppSpacing.md),
                const FilePickerWidget(
                  title: 'Front Profile',
                  maxFiles: 1,
                  profileKey: 'front_profile',
                  fileTypesHint: 'Select photo from gallery or camera',
                ),
                const SizedBox(height: AppSpacing.md),
                const FilePickerWidget(
                  title: 'Right Profile',
                  maxFiles: 1,
                  profileKey: 'right_profile',
                  fileTypesHint: 'Select photo from gallery or camera',
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
              child: AppButton(
                label: 'Submit',
                loading: viewState.isSubmitting,
                onPressed: viewState.isSubmitting ? null : () => submit(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
