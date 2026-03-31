import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app/routes.dart';
import 'app/theme/app_theme_extension.dart';
import 'app/theme/theme_mode.dart';
import 'app/theme/theme_provider.dart';
import 'core/design/app_radius.dart';
import 'core/design/app_spacing.dart';
import 'core/widgets/app_custom_app_bar.dart';
import 'features/auth/domain/auth_state.dart';
import 'features/auth/presentation/providers/auth_session_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modules = <_ModuleItem>[
      const _ModuleItem(
        title: 'Employee',
        subtitle: 'View and manage employee details.',
        icon: Icons.people_alt_rounded,
        start: Color(0xFF2563EB),
        end: Color(0xFF4F46E5),
      ),
      const _ModuleItem(
        title: 'Mark Attendance',
        subtitle: 'Check in or check out in a single tap.',
        icon: Icons.fact_check_rounded,
        start: Color(0xFF059669),
        end: Color(0xFF10B981),
      ),
      const _ModuleItem(
        title: 'History',
        subtitle: 'Browse attendance and activity timeline.',
        icon: Icons.history_rounded,
        start: Color(0xFFEA580C),
        end: Color(0xFFF97316),
      ),
    ];

    final auth = ref.watch(authSessionProvider);
    final userEmail = switch (auth) {
      AsyncData(:final value) when value is Authenticated => value.email,
      _ => null,
    };

    return Scaffold(
      appBar: AppCustomAppBar(
        title: 'Home',
        profileEmail: userEmail,
        onProfileTap: () => context.push(AppRoutes.profile),
        actions: [
          IconButton(
            tooltip: 'Theme mode',
            onPressed: () => _showThemeOptions(context, ref),
            icon: const Icon(Icons.dark_mode_rounded),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: modules.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final item = modules[index];
          return _HomeModuleCard(item: item);
        },
      ),
    );
  }

  void _showThemeOptions(BuildContext context, WidgetRef ref) {
    final currentMode = ref.read(themeProvider).mode;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ThemeModeTile(
                  title: 'System',
                  icon: Icons.settings_suggest_rounded,
                  selected: currentMode == AppThemeMode.system,
                  onTap: () {
                    ref.read(themeProvider.notifier).setThemeMode(AppThemeMode.system);
                    Navigator.of(sheetContext).pop();
                  },
                ),
                _ThemeModeTile(
                  title: 'Light',
                  icon: Icons.light_mode_rounded,
                  selected: currentMode == AppThemeMode.light,
                  onTap: () {
                    ref.read(themeProvider.notifier).setThemeMode(AppThemeMode.light);
                    Navigator.of(sheetContext).pop();
                  },
                ),
                _ThemeModeTile(
                  title: 'Dark',
                  icon: Icons.dark_mode_rounded,
                  selected: currentMode == AppThemeMode.dark,
                  onTap: () {
                    ref.read(themeProvider.notifier).setThemeMode(AppThemeMode.dark);
                    Navigator.of(sheetContext).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}

class _HomeModuleCard extends StatelessWidget {
  final _ModuleItem item;

  const _HomeModuleCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.theme.colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () {
          // TODO: wire module navigation/actions.
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: context.theme.colors.border),
            boxShadow: [
              BoxShadow(
                color: context.theme.colors.textPrimary.withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  gradient: LinearGradient(
                    colors: [item.start, item.end],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  item.icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: context.text.title().copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      item.subtitle,
                      style: context.text.body().copyWith(
                            color: context.theme.colors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: context.theme.colors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color start;
  final Color end;

  const _ModuleItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.start,
    required this.end,
  });
}

class _ThemeModeTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeModeTile({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      leading: Icon(icon),
      title: Text(title),
      trailing: selected
          ? Icon(
              Icons.check_circle_rounded,
              color: context.theme.colors.primary,
            )
          : null,
      onTap: onTap,
    );
  }
}
