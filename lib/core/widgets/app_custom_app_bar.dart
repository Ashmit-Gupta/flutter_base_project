import 'package:flutter/material.dart';

import '../../app/theme/app_theme_extension.dart';
import 'profile_avatar_button.dart';

class AppCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  /// Initials are derived from email when [onProfileTap] is set.
  final String? profileEmail;
  final VoidCallback? onProfileTap;

  const AppCustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.centerTitle = false,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.profileEmail,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final builtActions = <Widget>[
      ...?actions,
      if (onProfileTap != null)
        ProfileAvatarButton(
          email: profileEmail,
          onTap: onProfileTap!,
        ),
    ];

    return AppBar(
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: centerTitle,
      title: Text(
        title,
        style: context.text.title().copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
      actions: builtActions.isEmpty ? null : builtActions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

