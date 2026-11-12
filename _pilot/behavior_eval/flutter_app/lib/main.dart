import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/home/presentation/home_screen.dart';

void main() {
  runApp(const BehaviorEvalApp());
}

class BehaviorEvalApp extends StatelessWidget {
  const BehaviorEvalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Behavior Eval',
      theme: AppTheme.light(),
      home: const HomeScreen(),
    );
  }
}
