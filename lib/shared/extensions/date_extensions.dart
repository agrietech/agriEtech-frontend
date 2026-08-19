/// DateTime utility extensions for AgriEtech UI
library date_extensions;

extension DateTimeExtensions on DateTime {
  /// "Aug 18, 2026"
  String get formatted {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[month-1]} $day, $year';
  }

  /// "2h ago", "3d ago", "Just now"
  String get relative {
    final diff = DateTime.now().difference(this);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    return formatted;
  }

  /// ISO date only: "2026-08-18"
  String get isoDate =>
      '${year.toString().padLeft(4,'0')}-${month.toString().padLeft(2,'0')}-${day.toString().padLeft(2,'0')}';

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}
