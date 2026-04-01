import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pinput/pinput.dart';

import '../../../../app/theme/app_theme_extension.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/feedback/app_snackbar.dart';
import '../../../../core/widgets/app_button.dart';
import '../providers/profile_section_providers.dart';
import '../view_models/edit_admin_pin_form_state.dart';

class EditAdminPinScreen extends HookConsumerWidget {
  const EditAdminPinScreen({super.key});

  static const int _pinLength = 6;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinController = useTextEditingController();
    final confirmPinController = useTextEditingController();
    final state = ref.watch(editAdminPinViewModelProvider);
    final viewModel = ref.read(editAdminPinViewModelProvider.notifier);

    ref.listen<EditAdminPinFormState>(editAdminPinViewModelProvider, (prev, next) {
      if (next.isSuccess) {
        AppSnackbar.success(context, 'Admin PIN updated');
        context.pop();
        viewModel.onSuccessHandled();
      } else if (next.isFailure) {
        AppSnackbar.error(context, next.errorMessage ?? 'Something went wrong');
        viewModel.onFailureHandled();
      }
    });

    final pinTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: context.text.title().copyWith(fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: context.theme.colors.border),
        borderRadius: BorderRadius.circular(10),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Edit admin PIN',
          style: context.text.title(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter PIN',
              style: context.text.title().copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.sm),
            Pinput(
              length: _pinLength,
              controller: pinController,
              keyboardType: TextInputType.text,
              obscureText: true,
              obscuringCharacter: '•',
              defaultPinTheme: pinTheme,
              focusedPinTheme: pinTheme.copyWith(
                decoration: pinTheme.decoration?.copyWith(
                  border: Border.all(color: context.theme.colors.primary),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Confirm PIN',
              style: context.text.title().copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.sm),
            Pinput(
              length: _pinLength,
              controller: confirmPinController,
              keyboardType: TextInputType.text,
              obscureText: true,
              obscuringCharacter: '•',
              defaultPinTheme: pinTheme,
              focusedPinTheme: pinTheme.copyWith(
                decoration: pinTheme.decoration?.copyWith(
                  border: Border.all(color: context.theme.colors.primary),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'Submit',
                loading: state.isSubmitting,
                onPressed: state.isSubmitting
                    ? null
                    : () => viewModel.onSubmitPressed(
                          pin: pinController.text,
                          confirmPin: confirmPinController.text,
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
