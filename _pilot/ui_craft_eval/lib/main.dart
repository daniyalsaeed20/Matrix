import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/members/presentation/members_screen.dart';

void main() {
  runApp(const UiCraftEvalApp());
}

class UiCraftEvalApp extends StatelessWidget {
  const UiCraftEvalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: const MembersScreen(
        members: [
          (
            name: 'Alex Rivera',
            email: 'alex@example.com',
            role: 'Admin',
          ),
        ],
      ),
    );
  }
}
