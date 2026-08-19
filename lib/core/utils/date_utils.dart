/// Date formatting and Ethiopian calendar helpers
library date_utils;

class AppDateUtils {
  /// Format DateTime to readable string e.g. "Aug 18, 2026"
  static String format(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  /// Format to ISO date string (YYYY-MM-DD)
  static String toIsoDate(DateTime dt) =>
      '${dt.year.toString().padLeft(4,'0')}-${dt.month.toString().padLeft(2,'0')}-${dt.day.toString().padLeft(2,'0')}';

  /// Relative time label: "2 hours ago", "Just now", etc.
  static String relative(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return format(dt);
  }

  /// Current Ethiopian dekadal period label (1-3 per month)
  static String dekadalLabel(DateTime dt) {
    final period = dt.day <= 10 ? 1 : dt.day <= 20 ? 2 : 3;
    return 'Dekad $period - ${format(dt)}';
  }

  /// Parse date safely, returning null on failure
  static DateTime? tryParse(String? s) {
    if (s == null || s.isEmpty) return null;
    try { return DateTime.parse(s); } catch (_) { return null; }
  }
}
