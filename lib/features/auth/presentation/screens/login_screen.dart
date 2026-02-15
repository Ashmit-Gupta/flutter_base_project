import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../app/theme/app_theme_extension.dart';
import '../../../../app/routes.dart';
import '../../../../core/design/app_radius.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/feedback/app_snackbar.dart';
import '../../../../core/layout/adaptive_layout_builder.dart';
import '../../../../core/layout/layout_constants.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_button_variant.dart';
import '../../../../core/widgets/app_text_field.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final passwordController = useTextEditingController();
    final formKey = useMemoized(GlobalKey<FormState>.new);

    return Scaffold(
      body: SafeArea(
        child: AdaptiveLayoutBuilder(
          mobile: _LoginLayout(
            formKey: formKey,
            nameController: nameController,
            passwordController: passwordController,
            onForgotPassword: () => context.push(AppRoutes.forgotPassword),
            onLogin: () => _handleLogin(context, formKey, nameController, passwordController),
          ),
          tablet: _LoginLayout(
            formKey: formKey,
            nameController: nameController,
            passwordController: passwordController,
            onForgotPassword: () => context.push(AppRoutes.forgotPassword),
            onLogin: () => _handleLogin(context, formKey, nameController, passwordController),
          ),
          desktop: _LoginLayout(
            formKey: formKey,
            nameController: nameController,
            passwordController: passwordController,
            onForgotPassword: () => context.push(AppRoutes.forgotPassword),
            onLogin: () => _handleLogin(context, formKey, nameController, passwordController),
          ),
        ),
      ),
    );
  }

  void _handleLogin(
    BuildContext context,
    GlobalKey<FormState> formKey,
    TextEditingController nameController,
    TextEditingController passwordController,
  ) {
    if (formKey.currentState?.validate() ?? false) {
      AppSnackbar.success(context, 'Signed in successfully');
    }
  }
}

class _LoginLayout extends StatelessWidget {
  const _LoginLayout({
    required this.formKey,
    required this.nameController,
    required this.passwordController,
    required this.onForgotPassword,
    required this.onLogin,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController passwordController;
  final VoidCallback onForgotPassword;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: LayoutConstants.tabletContentMaxWidth),
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
                    'Welcome back',
                    style: context.text.headline(),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Sign in to continue',
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
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: passwordController,
                    label: 'Password',
                    hint: 'Enter your password',
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
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
