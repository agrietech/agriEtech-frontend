import 'package:flutter_test/flutter_test.dart';
import 'package:agrietech/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter - Standard Formatting', () {
    final testDate = DateTime(2026, 8, 17, 14, 30);

    test('formatDate formats standard date string', () {
      expect(DateFormatter.formatDate(testDate), equals('Aug 17, 2026'));
    });

    test('formatIsoDate formats to ISO-8601 YYYY-MM-DD', () {
      expect(DateFormatter.formatIsoDate(testDate), equals('2026-08-17'));
    });

    test('formatTime formats 12-hour time with AM/PM', () {
      expect(DateFormatter.formatTime(testDate), equals('2:30 PM'));
    });

    test('parseIsoDate parses valid and handles null/empty safely', () {
      expect(DateFormatter.parseIsoDate('2026-08-17'), isNotNull);
      expect(DateFormatter.parseIsoDate(null), isNull);
      expect(DateFormatter.parseIsoDate(''), isNull);
      expect(DateFormatter.parseIsoDate('invalid-date'), isNull);
    });
  });

  group('DateFormatter - Relative Time & Duration', () {
    test('formatRelativeTime returns accurate descriptions', () {
      final now = DateTime.now();
      expect(DateFormatter.formatRelativeTime(now.subtract(const Duration(seconds: 10))), equals('Just now'));
      expect(DateFormatter.formatRelativeTime(now.subtract(const Duration(minutes: 5))), equals('5 minutes ago'));
      expect(DateFormatter.formatRelativeTime(now.subtract(const Duration(hours: 3))), equals('3 hours ago'));
      expect(DateFormatter.formatRelativeTime(now.subtract(const Duration(days: 2))), equals('2 days ago'));
    });

    test('formatDuration formats days, hours, minutes', () {
      expect(DateFormatter.formatDuration(const Duration(days: 2, hours: 4)), equals('2d 4h'));
      expect(DateFormatter.formatDuration(const Duration(hours: 3, minutes: 15)), equals('3h 15m'));
      expect(DateFormatter.formatDuration(const Duration(minutes: 45)), equals('45m'));
      expect(DateFormatter.formatDuration(const Duration(seconds: 30)), equals('30s'));
    });
  });

  group('DateFormatter - Ethiopian Seasons & Day Checks', () {
    test('isToday and isYesterday checks', () {
      final now = DateTime.now();
      expect(DateFormatter.isToday(now), isTrue);
      expect(DateFormatter.isYesterday(now.subtract(const Duration(days: 1))), isTrue);
      expect(DateFormatter.isToday(now.subtract(const Duration(days: 5))), isFalse);
    });

    test('getSeason identifies Ethiopian agricultural seasons', () {
      expect(DateFormatter.getSeason(DateTime(2026, 7, 15)), contains('Kiremt'));
      expect(DateFormatter.getSeason(DateTime(2026, 11, 20)), contains('Bega'));
      expect(DateFormatter.getSeason(DateTime(2026, 4, 10)), contains('Belg'));
    });
  });
}
