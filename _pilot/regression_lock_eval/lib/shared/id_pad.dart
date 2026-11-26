/// Shared helper used by B09 and B10 — intentional baseline defect for coordinated-fix demos.
class IdPad {
  /// Baseline bug: pads with spaces instead of zeros (breaks invoice id + money code).
  static String leftPad(int value, int width) {
    final raw = value.toString();
    if (raw.length >= width) return raw;
    return raw.padLeft(width, ' ');
  }

  /// Correct implementation used by coordinated-fix scenario overlays.
  static String leftPadFixed(int value, int width) {
    final raw = value.toString();
    if (raw.length >= width) return raw;
    return raw.padLeft(width, '0');
  }
}
