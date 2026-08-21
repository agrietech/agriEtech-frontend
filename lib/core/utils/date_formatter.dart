import 'package:intl/intl.dart';

/// Date and time formatting utilities
class DateFormatter {
  /// Format date to readable string (e.g., "Jan 15, 2024")
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Format date with day name (e.g., "Monday, Jan 15, 2024")
  static String formatDateWithDay(DateTime date) {
    return DateFormat('EEEE, MMM dd, yyyy').format(date);
  }

  /// Format time (e.g., "3:45 PM")
  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  /// Format date and time (e.g., "Jan 15, 2024 3:45 PM")
  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy h:mm a').format(date);
  }

  /// Format date in short form (e.g., "01/15/2024")
  static String formatShortDate(DateTime date) {
    return DateFormat('MM/dd/yyyy').format(date);
  }

  /// Format date in ISO format (e.g., "2024-01-15")
  static String formatIsoDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Format relative time (e.g., "2 hours ago", "3 days ago")
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else if (difference.inDays > 0) {
      return difference.inDays == 1 ? '1 day ago' : '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1 ? '1 hour ago' : '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1 ? '1 minute ago' : '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  /// Alias for formatRelativeTime
  static String formatRelative(DateTime date) => formatRelativeTime(date);

  /// Format duration (e.g., "2h 30m")
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Get day of week
  static String getDayOfWeek(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  /// Get month name
  static String getMonthName(DateTime date) {
    return DateFormat('MMMM').format(date);
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Format date with context (Today, Yesterday, or date)
  static String formatDateWithContext(DateTime date) {
    if (isToday(date)) {
      return 'Today at ${formatTime(date)}';
    } else if (isYesterday(date)) {
      return 'Yesterday at ${formatTime(date)}';
    } else if (DateTime.now().difference(date).inDays < 7) {
      return '${getDayOfWeek(date)} at ${formatTime(date)}';
    } else {
      return formatDateTime(date);
    }
  }

  /// Parse ISO date string
  static DateTime? parseIsoDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Format Ethiopian date string with season context
  static String formatEthiopianDate(DateTime date) {
    final season = getSeason(date).split(' ').first;
    return '${formatDate(date)} ($season)';
  }

  /// Get season based on date
  static String getSeason(DateTime date) {
    final month = date.month;
    
    // Ethiopian seasons
    if (month >= 6 && month <= 9) {
      return 'Kiremt (Rainy Season)';
    } else if (month >= 10 || month <= 1) {
      return 'Bega (Dry Season)';
    } else {
      return 'Belg (Small Rainy Season)';
    }
  }
}