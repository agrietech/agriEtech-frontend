import 'package:intl/intl.dart';

/// Detailed representation of an Ethiopian Agricultural Season
class EthiopianSeasonInfo {
  final String seasonCode; // TSEDAY_MEHER, BEGA, BELG_METSEW, KIREMT
  final String nameEn;
  final String nameAm;
  final String westernSeason;
  final String gregorianMonths;
  final String ethiopianMonthsEn;
  final String ethiopianMonthsAm;
  final String characteristicsEn;
  final String characteristicsAm;

  const EthiopianSeasonInfo({
    required this.seasonCode,
    required this.nameEn,
    required this.nameAm,
    required this.westernSeason,
    required this.gregorianMonths,
    required this.ethiopianMonthsEn,
    required this.ethiopianMonthsAm,
    required this.characteristicsEn,
    required this.characteristicsAm,
  });

  String get displayName => '$nameEn ($nameAm) – $westernSeason';
}

/// Date and time formatting utilities with Standard Ethiopian Four-Season Model
class DateFormatter {
  /// 1. ጸደይ / መኸር (Tseday / Meher) – Spring / Harvest (Sep to Nov | Meskerem, Tikimt, Hidar)
  static const EthiopianSeasonInfo tsedayMeher = EthiopianSeasonInfo(
    seasonCode: 'TSEDAY_MEHER',
    nameEn: 'Tseday / Meher',
    nameAm: '\u1338\u12f0\u12ed / \u1218\u1280\u122d',
    westernSeason: 'Spring / Harvest Season',
    gregorianMonths: 'September to November',
    ethiopianMonthsEn: 'Meskerem, Tikimt, Hidar',
    ethiopianMonthsAm: '\u1218\u1235\u12a8\u1228\u121d\u1363 \u1325\u1245\u121d\u1275\u1363 \u1285\u12f3\u122d',
    characteristicsEn: 'Harvest & flower-blooming season following the Ethiopian New Year as Adey Abeba daisies bloom across the highlands.',
    characteristicsAm: '\u12e8\u1218\u1230\u1265\u1230\u1262\u12eb\u1293 \u12e8\u12a0\u12f0\u12ed \u12a0\u1260\u1263 \u121b\u1348\u1260\u1262\u12eb \u12c8\u1245\u1275',
  );

  /// 2. በጋ (Bega) – Summer / Dry Season (Dec to Feb | Tahsas, Tir, Yakatit)
  static const EthiopianSeasonInfo bega = EthiopianSeasonInfo(
    seasonCode: 'BEGA',
    nameEn: 'Bega',
    nameAm: '\u1260\u130b',
    westernSeason: 'Summer / Dry Season',
    gregorianMonths: 'December to February',
    ethiopianMonthsEn: 'Tahsas, Tir, Yakatit',
    ethiopianMonthsAm: '\u1273\u1285\u1223\u1225\u1363 \u1325\u122d\u1363 \u12e8\u12a8\u1272\u1275',
    characteristicsEn: 'Primary dry, sunny, and windy season with cool mornings and optimal post-harvest logistics.',
    characteristicsAm: '\u12f0\u1228\u1245\u1363 \u1338\u1203\u12eb\u121b\u1293 \u1295\u134b\u123b\u121b \u12e8\u1260\u130b \u12c8\u1245\u1275',
  );

  /// 3. በልግ / መፀው (Belg / Metsew) – Autumn / Short Rainy Season (Mar to May | Maggabit, Miyazya, Ginbot)
  static const EthiopianSeasonInfo belgMetsew = EthiopianSeasonInfo(
    seasonCode: 'BELG_METSEW',
    nameEn: 'Belg / Metsew',
    nameAm: '\u1260\u120d\u130d / \u1218\u1338\u12c8',
    westernSeason: 'Autumn / Short Rainy Season',
    gregorianMonths: 'March to May',
    ethiopianMonthsEn: 'Maggabit, Miyazya, Ginbot',
    ethiopianMonthsAm: '\u1218\u130b\u1262\u1275\u1363 \u121a\u12eb\u12dd\u12eb\u1363 \u130d\u1295\u1266\u1275',
    characteristicsEn: 'Mild temperatures and short rains crucial for Belg crop planting and pasture regeneration.',
    characteristicsAm: '\u12a0\u1283\u12ed \u12a0\u12ed\u1290\u1275 \u12a8\u1208\u120d \u12e8\u1260\u120d\u130d \u12dd\u1293\u1265 \u12c8\u1245\u1275',
  );

  /// 4. ክረምት (Kiremt) – Winter / Long Rainy Season (Jun to Aug | Sene, Hamle, Nehasse)
  static const EthiopianSeasonInfo kiremt = EthiopianSeasonInfo(
    seasonCode: 'KIREMT',
    nameEn: 'Kiremt',
    nameAm: '\u12ad\u1228\u121d\u1275',
    westernSeason: 'Winter / Long Rainy Season',
    gregorianMonths: 'June to August',
    ethiopianMonthsEn: 'Sene, Hamle, Nehasse',
    ethiopianMonthsAm: '\u1230\u1294\u1363 \u1210\u121d\u120c\u1363 \u1290\u1210\u1234',
    characteristicsEn: 'Main long rainy season with heavy rainfall feeding up to 95% of national food crop production.',
    characteristicsAm: '\u12cb\u1293\u12cd \u12e8\u12ad\u1228\u121d\u1275 \u12e8\u12dd\u1293\u1265 \u12c8\u1245\u1275',
  );

  /// Get structured Ethiopian season info based on calendar date
  static EthiopianSeasonInfo getEthiopianSeasonInfo(DateTime date) {
    final month = date.month;
    if (month >= 9 && month <= 11) {
      return tsedayMeher;
    } else if (month == 12 || month == 1 || month == 2) {
      return bega;
    } else if (month >= 3 && month <= 5) {
      return belgMetsew;
    } else {
      return kiremt;
    }
  }

  /// Get season name string with Amharic and Gregorian alignment
  static String getSeason(DateTime date) {
    final info = getEthiopianSeasonInfo(date);
    return '${info.nameEn} (${info.nameAm} - ${info.westernSeason})';
  }

  /// All 4 Ethiopian agricultural seasons in standard chronological order
  static List<EthiopianSeasonInfo> get allSeasons => [
        tsedayMeher,
        bega,
        belgMetsew,
        kiremt,
      ];

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

  /// Safe relative format accepting DateTime, String, or null without throwing
  static String formatRelativeSafe(dynamic date) {
    if (date == null) return 'Recently';
    if (date is DateTime) return formatRelativeTime(date);
    if (date is String) {
      final parsed = DateTime.tryParse(date);
      if (parsed != null) return formatRelativeTime(parsed);
      return date;
    }
    return 'Recently';
  }

  /// Safe date format accepting DateTime, String, or null
  static String formatDateSafe(dynamic date) {
    if (date == null) return '--';
    if (date is DateTime) return formatDate(date);
    if (date is String) {
      final parsed = DateTime.tryParse(date);
      if (parsed != null) return formatDate(parsed);
      return date;
    }
    return '--';
  }

  /// Safe date time format accepting DateTime, String, or null
  static String formatDateTimeSafe(dynamic date) {
    if (date == null) return '--';
    if (date is DateTime) return formatDateTime(date);
    if (date is String) {
      final parsed = DateTime.tryParse(date);
      if (parsed != null) return formatDateTime(parsed);
      return date;
    }
    return '--';
  }

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
    final season = getEthiopianSeasonInfo(date).nameEn;
    return '${formatDate(date)} ($season)';
  }
}
