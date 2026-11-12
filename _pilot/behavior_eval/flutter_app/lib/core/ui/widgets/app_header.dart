import 'package:flutter/material.dart';

/// Branded app bar used across primary screens.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key, required this.title, this.actions});

  final String title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppBar(
      title: Text(title),
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      actions: actions,
    );
  }
}
