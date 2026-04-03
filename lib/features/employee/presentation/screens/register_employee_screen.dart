import 'package:basic_project_setup/core/ui/models/picked_file.dart';
import 'package:basic_project_setup/core/ui/widgets/file_picker_widget.dart';
import 'package:basic_project_setup/core/widgets/app_text_field.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_theme_extension.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/feedback/app_snackbar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../shared/file_controller.dart';
import '../../../shared/picked_file_mapping.dart';
import '../../domain/entities/employee_summary.dart';
import '../constants/employee_file_scopes.dart';
import '../view_models/register_employee_view_model.dart';

class RegisterEmployeeScreen extends HookConsumerWidget {
  const RegisterEmployeeScreen({super.key, this.initialEmployee});

  final EmployeeSummary? initialEmployee;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final employeeController = useTextEditingController();
    final viewState = ref.watch(registerEmployeeViewModelProvider);
    final vm = ref.read(registerEmployeeViewModelProvider.notifier);
    final scope = EmployeeFileScopes.registration;
    final fileState = ref.watch(fileControllerProvider(scope));
    final fileNotifier = ref.read(fileControllerProvider(scope).notifier);

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

    List<PickedFile> filesFor(String profileKey) {
      return fileState
          .where((f) => f.name.startsWith('${profileKey}_'))
          .map((e) => e.asPickedFile)
          .toList(growable: false);
    }

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
                FilePickerWidget(
                  title: 'Left Profile',
                  maxFiles: 1,
                  fileTypesHint: 'Select photo from gallery or camera',
                  files: filesFor('left_profile'),
                  onGallery: () =>
                      fileNotifier.pickFromGalleryForProfile(profileKey: 'left_profile'),
                  onCamera: () =>
                      fileNotifier.pickFromCameraForProfile(profileKey: 'left_profile'),
                  onRemoveAt: (_) =>
                      fileNotifier.removeProfilePhoto('left_profile'),
                  onPreviewTap: (p) => context.push(
                    AppRoutes.employeeImagePreview,
                    extra: PlatformFile(name: p.name, path: p.path, size: p.size),
                  ),
                  onUserMessage: (m) => AppSnackbar.info(context, m),
                ),
                const SizedBox(height: AppSpacing.md),
                FilePickerWidget(
                  title: 'Front Profile',
                  maxFiles: 1,
                  fileTypesHint: 'Select photo from gallery or camera',
                  files: filesFor('front_profile'),
                  onGallery: () =>
                      fileNotifier.pickFromGalleryForProfile(profileKey: 'front_profile'),
                  onCamera: () =>
                      fileNotifier.pickFromCameraForProfile(profileKey: 'front_profile'),
                  onRemoveAt: (_) =>
                      fileNotifier.removeProfilePhoto('front_profile'),
                  onPreviewTap: (p) => context.push(
                    AppRoutes.employeeImagePreview,
                    extra: PlatformFile(name: p.name, path: p.path, size: p.size),
                  ),
                  onUserMessage: (m) => AppSnackbar.info(context, m),
                ),
                const SizedBox(height: AppSpacing.md),
                FilePickerWidget(
                  title: 'Right Profile',
                  maxFiles: 1,
                  fileTypesHint: 'Select photo from gallery or camera',
                  files: filesFor('right_profile'),
                  onGallery: () =>
                      fileNotifier.pickFromGalleryForProfile(profileKey: 'right_profile'),
                  onCamera: () =>
                      fileNotifier.pickFromCameraForProfile(profileKey: 'right_profile'),
                  onRemoveAt: (_) =>
                      fileNotifier.removeProfilePhoto('right_profile'),
                  onPreviewTap: (p) => context.push(
                    AppRoutes.employeeImagePreview,
                    extra: PlatformFile(name: p.name, path: p.path, size: p.size),
                  ),
                  onUserMessage: (m) => AppSnackbar.info(context, m),
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
