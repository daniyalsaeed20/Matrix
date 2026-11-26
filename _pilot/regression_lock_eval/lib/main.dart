import 'package:flutter/material.dart';

import 'behaviours/behaviours.dart';

void main() {
  runApp(const RegressionLockApp());
}

class RegressionLockApp extends StatelessWidget {
  const RegressionLockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Regression Lock Eval',
      home: Scaffold(
        appBar: AppBar(title: const Text('Regression Lock Eval')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('B01 email: ${normalizeEmail('  Ada@Example.COM ')}'),
            Text('B05 label: ${formatPersonLabel('ada', 'lovelace')}'),
            Text('B09 invoice: ${nextInvoiceId(7)}'),
            Text('B10 money: ${formatMoneyCode(42)}'),
          ],
        ),
      ),
    );
  }
}
