import 'package:flutter/material.dart';

import '../../../core/ui/widgets/app_header.dart';
import '../../../core/ui/widgets/app_info_card.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Orders'),
      body: ListView(
        children: const [
          AppInfoCard(title: 'Pending', body: '2 orders need packing'),
          AppInfoCard(title: 'Shipped', body: '5 in transit'),
        ],
      ),
    );
  }
}
