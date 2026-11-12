import 'package:flutter/material.dart';

/// Dense list row that must survive long names/emails without overflow.
class MemberRow extends StatelessWidget {
  const MemberRow({
    super.key,
    required this.name,
    required this.email,
    this.trailingLabel,
  });

  final String name;
  final String email;
  final String? trailingLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              name.isEmpty ? '?' : String.fromCharCode(name.runes.first),
              style: theme.textTheme.labelLarge,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  email,
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (trailingLabel != null) ...[
            const SizedBox(width: 8),
            Text(trailingLabel!, style: theme.textTheme.labelMedium),
          ],
        ],
      ),
    );
  }
}
