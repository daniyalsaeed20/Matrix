/// Shared helper used by B05 — verified working at baseline (blast-radius neighbor).
class TextNorm {
  static String titleCase(String input) {
    final parts = input.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || (parts.length == 1 && parts.first.isEmpty)) {
      return '';
    }
    return parts
        .map((p) {
          if (p.isEmpty) return p;
          return '${p[0].toUpperCase()}${p.substring(1).toLowerCase()}';
        })
        .join(' ');
  }
}
