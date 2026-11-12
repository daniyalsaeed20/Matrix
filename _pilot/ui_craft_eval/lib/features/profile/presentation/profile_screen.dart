import 'package:flutter/material.dart';

import '../../../core/ui/widgets/app_info_card.dart';

/// Scenario 2 — reuses shared AppInfoCard instead of a one-off card.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.displayName,
    required this.bio,
    required this.workspaceCount,
  });

  final String displayName;
  final String bio;
  final int workspaceCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('Profile', style: theme.textTheme.titleLarge)),
      body: ListView(
        children: [
          AppInfoCard(title: displayName, body: bio),
          AppInfoCard(
            title: 'Workspaces',
            body: '$workspaceCount',
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}
