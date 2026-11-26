import 'package:flutter_test/flutter_test.dart';
import 'package:regression_lock_eval/behaviours/behaviours.dart';

void main() {
  group('protected baseline (expect PASS)', () {
    test('B01 normalizeEmail', () {
      expect(normalizeEmail('  Ada@Example.COM '), 'ada@example.com');
    });

    test('B02 parseAmount', () {
      expect(parseAmount('1,234.50'), 1234.50);
      expect(parseAmount('x'), isNull);
    });

    test('B03 clampPercent', () {
      expect(clampPercent(-5), 0);
      expect(clampPercent(150), 100);
      expect(clampPercent(42), 42);
    });

    test('B04 slugify', () {
      expect(slugify(' Hello World! '), 'hello-world');
    });

    test('B05 formatPersonLabel', () {
      expect(formatPersonLabel('ada', 'lovelace'), 'Ada Lovelace');
    });
  });

  group('known failing at baseline (expect FAIL until repaired)', () {
    test('B06 validateUsername rejects empty', () {
      expect(validateUsername(''), isFalse);
      expect(validateUsername('   '), isFalse);
      expect(validateUsername('ada'), isTrue);
    });

    test('B07 computeDiscount applies percent', () {
      // Baseline bug subtracts percent as dollars; 200 @ 10% must be 180, not 190.
      expect(computeDiscount(200, 10), closeTo(180, 0.001));
    });

    test('B08 mergeTags unique sorted', () {
      expect(mergeTags(['b', 'a'], ['a', 'c']), ['a', 'b', 'c']);
    });

    test('B09 nextInvoiceId zero-pads', () {
      expect(nextInvoiceId(7), 'INV-0007');
    });

    test('B10 formatMoneyCode zero-pads', () {
      expect(formatMoneyCode(42), 'C000042');
    });
  });
}
