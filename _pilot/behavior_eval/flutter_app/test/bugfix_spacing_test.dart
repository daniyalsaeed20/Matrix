import 'package:behavior_eval/core/ui/widgets/app_info_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AppInfoCard keeps title/body spacing', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppInfoCard(title: 'A', body: 'B'),
        ),
      ),
    );
    final sized = tester.widgetList<SizedBox>(find.byType(SizedBox));
    expect(sized.any((s) => s.height == 8), isTrue);
  });
}
