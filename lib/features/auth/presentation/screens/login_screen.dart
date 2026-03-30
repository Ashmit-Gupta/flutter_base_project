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
import '../view_models/login_form_state.dart';
import '../view_models/login_view_model.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final isPasswordHidden = useState<bool>(true);
    final formKey = useMemoized(GlobalKey<FormState>.new);

    final loginState = ref.watch(loginViewModelProvider);
    final loginViewModel = ref.read(loginViewModelProvider.notifier);

    ref.listen<LoginFormState>(loginViewModelProvider, (prev, next) {
      if (next.isSuccess) {
        AppSnackbar.success(context, 'Signed in successfully');
        context.go(AppRoutes.home);
        loginViewModel.onSuccessHandled();
      } else if (next.isFailure) {
        AppSnackbar.error(
          context,
          next.errorMessage ?? 'Something went wrong',
        );
        loginViewModel.onFailureHandled();
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: AdaptiveLayoutBuilder(
                mobile: _LoginLayout(
                  formKey: formKey,
                  emailController: emailController,
                  passwordController: passwordController,
                  isPasswordHidden: isPasswordHidden.value,
                  onTogglePasswordVisibility: () =>
                      isPasswordHidden.value = !isPasswordHidden.value,
                  isSubmitting: loginState.isSubmitting,
                  viewModel: loginViewModel,
                  onLogin: () => _onLoginPressed(
                    formKey,
                    emailController,
                    passwordController,
                    loginViewModel,
                  ),
                  onForgotPassword: () => context.push(AppRoutes.forgotPassword),
                  onSwitchToSignup: () => context.replace(AppRoutes.signup),
                ),
                tablet: _LoginLayout(
                  formKey: formKey,
                  emailController: emailController,
                  passwordController: passwordController,
                  isPasswordHidden: isPasswordHidden.value,
                  onTogglePasswordVisibility: () =>
                      isPasswordHidden.value = !isPasswordHidden.value,
                  isSubmitting: loginState.isSubmitting,
                  viewModel: loginViewModel,
                  onLogin: () => _onLoginPressed(
                    formKey,
                    emailController,
                    passwordController,
                    loginViewModel,
                  ),
                  onForgotPassword: () => context.push(AppRoutes.forgotPassword),
                  onSwitchToSignup: () => context.replace(AppRoutes.signup),
                ),
                desktop: _LoginLayout(
                  formKey: formKey,
                  emailController: emailController,
                  passwordController: passwordController,
                  isPasswordHidden: isPasswordHidden.value,
                  onTogglePasswordVisibility: () =>
                      isPasswordHidden.value = !isPasswordHidden.value,
                  isSubmitting: loginState.isSubmitting,
                  viewModel: loginViewModel,
                  onLogin: () => _onLoginPressed(
                    formKey,
                    emailController,
                    passwordController,
                    loginViewModel,
                  ),
                  onForgotPassword: () => context.push(AppRoutes.forgotPassword),
                  onSwitchToSignup: () => context.replace(AppRoutes.signup),
                ),
              ),
            ),
            const _LoginBrandingFooter(),
          ],
        ),
      ),
    );
  }

  void _onLoginPressed(
    GlobalKey<FormState> formKey,
    TextEditingController emailController,
    TextEditingController passwordController,
    LoginViewModel viewModel,
  ) {
    if (formKey.currentState?.validate() != true) return;
    viewModel.onSubmitPressed(
      email: emailController.text.trim(),
      password: passwordController.text,
    );
  }
}

class _LoginLayout extends StatelessWidget {
  const _LoginLayout({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isPasswordHidden,
    required this.onTogglePasswordVisibility,
    required this.isSubmitting,
    required this.viewModel,
    required this.onLogin,
    required this.onForgotPassword,
    required this.onSwitchToSignup,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isPasswordHidden;
  final VoidCallback onTogglePasswordVisibility;
  final bool isSubmitting;
  final LoginViewModel viewModel;
  final VoidCallback onLogin;
  final VoidCallback onForgotPassword;
  final VoidCallback onSwitchToSignup;

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
                    'Welcome Back',
                    style: context.text.headline(),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Sign in to Continue',
                    style: context.text.body().copyWith(
                          color: context.theme.colors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppTextField(
                    controller: emailController,
                    label: 'Email',
                    hint: 'Enter your Email',
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    validator: viewModel.validateEmail,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: passwordController,
                    label: 'Password',
                    hint: 'Enter your password',
                    obscureText: isPasswordHidden,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    validator: viewModel.validatePassword,
                    suffixIcon: IconButton(
                      onPressed: onTogglePasswordVisibility,
                      tooltip: isPasswordHidden ? 'Show password' : 'Hide password',
                      icon: Icon(
                        isPasswordHidden
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: onForgotPassword,
                      style: TextButton.styleFrom(
                        foregroundColor: context.theme.colors.secondary,
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Forgot password?',
                        style: context.text.label().copyWith(
                              color: context.theme.colors.secondary,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: 'Sign in',
                    onPressed: onLogin,
                    variant: AppButtonVariant.primary,
                    loading: isSubmitting,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: context.text.body().copyWith(
                              color: context.theme.colors.textSecondary,
                            ),
                      ),
                      TextButton(
                        onPressed: onSwitchToSignup,
                        style: TextButton.styleFrom(
                          foregroundColor: context.theme.colors.secondary,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Sign up',
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

class _LoginBrandingFooter extends StatelessWidget {
  const _LoginBrandingFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _IsoBadge(
                imagePath: 'assets/images/iso9001.png',
                label: 'ISO 9001',
              ),
              SizedBox(width: AppSpacing.lg),
              _IsoBadge(
                imagePath: 'assets/images/iso27001.png',
                label: 'ISO 27001',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Image.asset(
            'assets/images/powered_by_logo_colored.png',
            height: 24,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

class _IsoBadge extends StatelessWidget {
  final String imagePath;
  final String label;

  const _IsoBadge({
    required this.imagePath,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          imagePath,
          height: 52,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: context.text.body().copyWith(
                color: context.theme.colors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
