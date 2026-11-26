import '../shared/id_pad.dart';
import '../shared/text_norm.dart';

/// B01 — verified_working at baseline
String normalizeEmail(String raw) {
  return raw.trim().toLowerCase();
}

/// B02 — verified_working at baseline
double? parseAmount(String raw) {
  final cleaned = raw.trim().replaceAll(',', '');
  return double.tryParse(cleaned);
}

/// B03 — verified_working at baseline
int clampPercent(int value) {
  if (value < 0) return 0;
  if (value > 100) return 100;
  return value;
}

/// B04 — verified_working at baseline
String slugify(String raw) {
  final lower = raw.trim().toLowerCase();
  final replaced = lower.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  return replaced.replaceAll(RegExp(r'^-+|-+$'), '');
}

/// B05 — verified_working at baseline (uses shared TextNorm)
String formatPersonLabel(String first, String last) {
  return TextNorm.titleCase('$first $last');
}

/// B06 — verified_failing at baseline (bug: accepts empty)
bool validateUsername(String raw) {
  // BUG: should reject empty / whitespace-only
  return raw.length >= 3;
}

/// B07 — verified_failing at baseline (bug: wrong formula)
double computeDiscount(double price, double percentOff) {
  // BUG: subtracts percent as absolute dollars instead of percentage
  return price - percentOff;
}

/// B08 — verified_failing at baseline (bug: does not dedupe)
List<String> mergeTags(List<String> a, List<String> b) {
  // BUG: should unique + sort; currently concatenates only
  return [...a, ...b];
}

/// B09 — verified_failing at baseline (shared IdPad bug)
String nextInvoiceId(int sequence) {
  return 'INV-${IdPad.leftPad(sequence, 4)}';
}

/// B10 — verified_failing at baseline (shared IdPad bug)
String formatMoneyCode(int cents) {
  return 'C${IdPad.leftPad(cents, 6)}';
}

/// Corrected variants used by scenario overlays (not production baseline).
bool validateUsernameFixed(String raw) {
  final t = raw.trim();
  return t.length >= 3 && RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(t);
}

double computeDiscountFixed(double price, double percentOff) {
  return price * (1 - (percentOff / 100.0));
}

List<String> mergeTagsFixed(List<String> a, List<String> b) {
  final set = <String>{...a, ...b};
  final list = set.toList()..sort();
  return list;
}

String nextInvoiceIdFixed(int sequence) {
  return 'INV-${IdPad.leftPadFixed(sequence, 4)}';
}

String formatMoneyCodeFixed(int cents) {
  return 'C${IdPad.leftPadFixed(cents, 6)}';
}

/// Intentional regress demo — breaks B01 while "repairing".
String normalizeEmailBroken(String raw) {
  return raw.toUpperCase();
}
