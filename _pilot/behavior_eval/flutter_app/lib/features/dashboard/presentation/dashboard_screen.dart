import 'package:flutter/material.dart';

import '../../../core/ui/widgets/app_header.dart';
import '../../../core/ui/widgets/app_info_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Dashboard'),
      body: ListView(
        children: const [
          AppInfoCard(title: 'Open tasks', body: '3 awaiting review'),
          AppInfoCard(title: 'Sync', body: 'Last sync 2 minutes ago'),
        ],
      ),
    );
  }
}
