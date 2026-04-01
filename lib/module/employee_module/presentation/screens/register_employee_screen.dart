import 'package:basic_project_setup/core/widgets/field_with_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../app/theme/app_theme_extension.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/feedback/app_snackbar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/file_picker_widget.dart';
import '../../../../core/widgets/reusable_list_bottom_sheet.dart';
import '../../data/model/get_all_employee_model.dart';
import '../view_models/register_employee_view_model.dart';

class RegisterEmployeeScreen extends HookConsumerWidget {
  const RegisterEmployeeScreen({super.key});

  static const int _minUploads = 3;
  static const int _maxUploads = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final employeeController = useTextEditingController();
    ref.watch(registerEmployeeViewModelProvider);
    final vm = ref.read(registerEmployeeViewModelProvider.notifier);
    final colors = context.theme.colors;

    ref.listen<RegisterEmployeeState>(
      registerEmployeeViewModelProvider,
      (previous, next) {
      final error = next.errorMessage;
      if (error != null && error.isNotEmpty && error != previous?.errorMessage) {
        AppSnackbar.error(context, error);
      }
      },
    );

    void submit() {
      final result = vm.submit(
        isFormValid: formKey.currentState?.validate() == true,
        minUploads: _minUploads,
        maxUploads: _maxUploads,
      );
      if (result.isError) {
        AppSnackbar.error(context, result.message);
      } else {
        AppSnackbar.success(context, result.message);
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
                FieldWithBottomSheet(
                  controller: employeeController,
                  label: 'Select Employee',
                  hint: 'Enter Employee Name',
                  title: 'Select Employee',
                  onSelected: vm.selectEmployeeByName,
                  bottomSheet: ReusableListBottomSheet<GetAllEmployeeUserModel>(
                    title: 'Select Employee',
                    showSearch: true,
                    searchHint: 'Search employee',
                    onFetchPage: (page, limit) =>
                        vm.fetchEmployeesForBottomSheet(
                      page: page,
                      limit: limit,
                    ),
                    labelBuilder: (_, employee) =>
                        '${employee.name} (${employee.empCode})',
                    onTap: (_, value) {
                      Navigator.of(context).pop(value.name);
                    },
                  ),
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
