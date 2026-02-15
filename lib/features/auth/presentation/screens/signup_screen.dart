import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_theme_extension.dart';
import '../../../../core/design/app_radius.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/feedback/app_snackbar.dart';
import '../../../../core/layout/adaptive_layout_builder.dart';
import '../../../../core/layout/layout_constants.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_button_variant.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_providers.dart';
import '../view_models/signup_view_model.dart';

class SignupScreen extends HookConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final isLoading = useState(false);

    final viewModel = ref.watch(signupViewModelProvider);

    return Scaffold(
      body: SafeArea(
        child: AdaptiveLayoutBuilder(
          mobile: _SignupLayout(
            formKey: formKey,
            nameController: nameController,
            emailController: emailController,
            passwordController: passwordController,
            isLoading: isLoading.value,
            viewModel: viewModel,
            onSignup: () => _handleSignup(
              context,
              ref,
              formKey,
              nameController,
              emailController,
              passwordController,
              viewModel,
              isLoading,
            ),
            onSwitchToLogin: () => context.replace(AppRoutes.login),
          ),
          tablet: _SignupLayout(
            formKey: formKey,
            nameController: nameController,
            emailController: emailController,
            passwordController: passwordController,
            isLoading: isLoading.value,
            viewModel: viewModel,
            onSignup: () => _handleSignup(
              context,
              ref,
              formKey,
              nameController,
              emailController,
              passwordController,
              viewModel,
              isLoading,
            ),
            onSwitchToLogin: () => context.replace(AppRoutes.login),
          ),
          desktop: _SignupLayout(
            formKey: formKey,
            nameController: nameController,
            emailController: emailController,
            passwordController: passwordController,
            isLoading: isLoading.value,
            viewModel: viewModel,
            onSignup: () => _handleSignup(
              context,
              ref,
              formKey,
              nameController,
              emailController,
              passwordController,
              viewModel,
              isLoading,
            ),
            onSwitchToLogin: () => context.replace(AppRoutes.login),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignup(
    BuildContext context,
    WidgetRef ref,
    GlobalKey<FormState> formKey,
    TextEditingController nameController,
    TextEditingController emailController,
    TextEditingController passwordController,
    SignupViewModel viewModel,
    ValueNotifier<bool> isLoading,
  ) async {
    if (formKey.currentState?.validate() != true) return;

    isLoading.value = true;
    try {
      final success = await viewModel.submit(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      if (success && context.mounted) {
        AppSnackbar.success(context, 'Account created successfully');
        context.replace(AppRoutes.login);
      } else if (context.mounted) {
        AppSnackbar.error(context, 'Something went wrong');
      }
    } finally {
      if (context.mounted) {
        isLoading.value = false;
      }
    }
  }
}

class _SignupLayout extends StatelessWidget {
  const _SignupLayout({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.viewModel,
    required this.onSignup,
    required this.onSwitchToLogin,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final SignupViewModel viewModel;
  final VoidCallback onSignup;
  final VoidCallback onSwitchToLogin;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: LayoutConstants.tabletContentMaxWidth,
          ),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: context.theme.colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: context.theme.colors.border),
              boxShadow: [
                BoxShadow(
                  color: context.theme.colors.textPrimary.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create account',
                    style: context.text.headline(),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Sign up to get started',
                    style: context.text.body().copyWith(
                          color: context.theme.colors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppTextField(
                    controller: nameController,
                    label: 'Name',
                    hint: 'Enter your name',
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                    validator: viewModel.validateName,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: emailController,
                    label: 'Email',
                    hint: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    validator: viewModel.validateEmail,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: passwordController,
                    label: 'Password',
                    hint: 'Enter your password',
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.newPassword],
                    validator: viewModel.validatePassword,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: 'Sign up',
                    onPressed: onSignup,
                    variant: AppButtonVariant.primary,
                    loading: isLoading,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: context.text.body().copyWith(
                              color: context.theme.colors.textSecondary,
                            ),
                      ),
                      TextButton(
                        onPressed: onSwitchToLogin,
                        style: TextButton.styleFrom(
                          foregroundColor: context.theme.colors.secondary,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Sign in',
                          style: context.text.label().copyWith(
                                color: context.theme.colors.secondary,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
