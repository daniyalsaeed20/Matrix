import 'package:flutter/material.dart';

import '../../../core/ui/widgets/member_row.dart';

/// Scenario 1 — new screen built on the locked theme + shared row widget.
class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key, required this.members});

  final List<({String name, String email, String? role})> members;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Members', style: theme.textTheme.titleLarge),
      ),
      body: members.isEmpty
          ? Center(
              child: Text(
                'No members yet',
                style: theme.textTheme.bodyLarge,
              ),
            )
          : ListView.separated(
              itemCount: members.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final m = members[index];
                return MemberRow(
                  name: m.name,
                  email: m.email,
                  trailingLabel: m.role,
                );
              },
            ),
    );
  }
}
