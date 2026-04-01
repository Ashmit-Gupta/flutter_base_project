import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_theme_extension.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/feedback/app_snackbar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/domain/auth_state.dart';
import '../../../auth/presentation/providers/auth_session_provider.dart';

class EditEmailPasswordScreen extends ConsumerStatefulWidget {
  const EditEmailPasswordScreen({super.key});

  @override
  ConsumerState<EditEmailPasswordScreen> createState() =>
      _EditEmailPasswordScreenState();
}

class _EditEmailPasswordScreenState extends ConsumerState<EditEmailPasswordScreen> {
  late final TextEditingController _emailController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final auth = ref.read(authSessionProvider);
    final currentEmail = switch (auth) {
      AsyncData(:final value) when value is Authenticated => value.email,
      _ => '',
    };
    _emailController = TextEditingController(text: currentEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String value) {
    final email = value.trim();
    if (email.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) return 'Enter a valid email';
    return null;
  }

  Future<void> _saveEmail() async {
    final error = _validateEmail(_emailController.text);
    if (error != null) {
      AppSnackbar.error(context, error);
      return;
    }

    setState(() => _isSaving = true);
    await ref.read(authSessionProvider.notifier).updateEmail(_emailController.text);
    if (!mounted) return;
    setState(() => _isSaving = false);
    AppSnackbar.success(context, 'Email updated');
    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Edit email',
          style: context.text.title(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Email',
              style: context.text.title().copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _isSaving ? null : _saveEmail(),
              decoration: const InputDecoration(
                hintText: 'you@example.com',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'Save email',
                loading: _isSaving,
                onPressed: _isSaving ? null : _saveEmail,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
