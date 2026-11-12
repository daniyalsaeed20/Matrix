import 'package:behavior_eval/core/ui/widgets/app_header.dart';
import 'package:behavior_eval/core/ui/widgets/app_info_card.dart';
import 'package:behavior_eval/features/dashboard/presentation/dashboard_screen.dart';
import 'package:behavior_eval/features/orders/presentation/orders_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('dashboard uses shared AppHeader and AppInfoCard', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));
    expect(find.byType(AppHeader), findsOneWidget);
    expect(find.byType(AppInfoCard), findsNWidgets(2));
    expect(find.text('Dashboard'), findsOneWidget);
  });

  testWidgets('orders reuses same shared widgets (no local duplicates)', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: OrdersScreen()));
    expect(find.byType(AppHeader), findsOneWidget);
    expect(find.byType(AppInfoCard), findsNWidgets(2));
    expect(find.text('Orders'), findsOneWidget);
  });
}
