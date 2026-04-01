import 'package:flutter/material.dart';

import '../../app/theme/app_theme_extension.dart';

/// Tappable circle avatar showing initials derived from [email].
class ProfileAvatarButton extends StatelessWidget {
  final String? email;
  final VoidCallback onTap;
  final double size;

  const ProfileAvatarButton({
    super.key,
    required this.email,
    required this.onTap,
    this.size = 36,
  });

  static String initialsFromEmail(String? email) {
    if (email == null || email.trim().isEmpty) return '?';
    final local = email.trim().split('@').first;
    if (local.isEmpty) return '?';
    final segments = local
        .split(RegExp(r'[.\s_-]+'))
        .where((s) => s.isNotEmpty)
        .toList();
    if (segments.length >= 2) {
      final a = segments[0][0];
      final b = segments[1][0];
      return (a + b).toUpperCase();
    }
    if (local.length >= 2) {
      return local.substring(0, 2).toUpperCase();
    }
    return local[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final initials = initialsFromEmail(email);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Tooltip(
          message: 'Profile',
          child: SizedBox(
            width: size + 8,
            height: kToolbarHeight,
            child: Center(
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.theme.colors.primary.withValues(alpha: 0.18),
                  border: Border.all(
                    color: context.theme.colors.border,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: context.text.body().copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.theme.colors.primary,
                        fontSize: size * 0.36,
                      ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
