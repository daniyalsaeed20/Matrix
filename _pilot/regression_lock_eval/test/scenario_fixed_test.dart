import 'package:flutter_test/flutter_test.dart';
import 'package:regression_lock_eval/behaviours/behaviours.dart';

/// Positive path: corrected helpers preserve B01–B05 and repair B06–B10.
void main() {
  group('coordinated + localized repairs (expect PASS)', () {
    test('B01–B05 still hold', () {
      expect(normalizeEmail('  X@Y.COM '), 'x@y.com');
      expect(parseAmount('10'), 10);
      expect(clampPercent(200), 100);
      expect(slugify('A B'), 'a-b');
      expect(formatPersonLabel('grace', 'hopper'), 'Grace Hopper');
    });

    test('B06 fixed', () {
      expect(validateUsernameFixed(''), isFalse);
      expect(validateUsernameFixed('ab'), isFalse);
      expect(validateUsernameFixed('ada_1'), isTrue);
    });

    test('B07 fixed', () {
      expect(computeDiscountFixed(200, 10), closeTo(180, 0.001));
    });

    test('B08 fixed', () {
      expect(mergeTagsFixed(['b', 'a'], ['a', 'c']), ['a', 'b', 'c']);
    });

    test('B09+B10 coordinated IdPad fix', () {
      expect(nextInvoiceIdFixed(7), 'INV-0007');
      expect(formatMoneyCodeFixed(42), 'C000042');
    });
  });

  group('intentional regress (expect FAIL)', () {
    test('broken normalizeEmail must not pass as repair', () {
      expect(normalizeEmailBroken('  Ada@Example.COM '), 'ada@example.com');
    });
  });
}
