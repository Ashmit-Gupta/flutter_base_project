import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_theme_extension.dart';
import '../../../../core/design/app_radius.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/feedback/app_snackbar.dart';
import '../../../../core/widgets/app_confirm_dialog.dart';
import '../../../../core/widgets/app_custom_app_bar.dart';
import '../../../../core/widgets/profile_avatar_button.dart';
import '../../../auth/domain/auth_state.dart';
import '../../../auth/presentation/providers/auth_session_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Future<void> _openEmailEditor(BuildContext context) async {
    final updated = await context.push<bool>(AppRoutes.editEmailPassword);
    if (updated == true && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authSessionProvider);
    final email = switch (auth) {
      AsyncData(:final value) when value is Authenticated => value.email,
      _ => null,
    };

    return Scaffold(
      appBar: AppCustomAppBar(
        title: 'Profile',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.theme.colors.primary.withValues(alpha: 0.15),
                    border: Border.all(color: context.theme.colors.border),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    ProfileAvatarButton.initialsFromEmail(email),
                    style: context.text.title().copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 28,
                          color: context.theme.colors.primary,
                        ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  email ?? 'No email found',
                  style: context.text.title().copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Email ID',
                  style: context.text.body().copyWith(
                        color: context.theme.colors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _ProfileActionTile(
            icon: Icons.email_outlined,
            title: 'Edit email',
            subtitle: email ?? 'Add your email address',
            onTap: () => _openEmailEditor(context),
          ),
          const SizedBox(height: AppSpacing.md),
          _ProfileActionTile(
            icon: Icons.lock_outline_rounded,
            title: 'Edit password',
            subtitle: 'Update your account password',
            onTap: () => context.push(AppRoutes.editPassword),
          ),
          const SizedBox(height: AppSpacing.md),
          _ProfileActionTile(
            icon: Icons.pin_outlined,
            title: 'Edit admin PIN',
            subtitle: 'Change your admin PIN',
            onTap: () => context.push(AppRoutes.editAdminPin),
          ),
          const SizedBox(height: AppSpacing.md),
          _ProfileActionTile(
            icon: Icons.logout_rounded,
            title: 'Logout',
            subtitle: 'Sign out of this device',
            isDestructive: true,
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await AppConfirmDialog.show(
      context,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
      cancelText: 'Cancel',
    );

    if (!shouldLogout) return;

    await ref.read(authSessionProvider.notifier).logout();
    if (!context.mounted) return;
    context.go(AppRoutes.login);
    AppSnackbar.info(context, 'Logged out successfully');
  }
}

class _ProfileActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ProfileActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? Theme.of(context).colorScheme.error
        : context.theme.colors.textPrimary;

    return Material(
      color: context.theme.colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: context.theme.colors.border),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.text.title().copyWith(
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      style: context.text.body().copyWith(
                            color: context.theme.colors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: context.theme.colors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
