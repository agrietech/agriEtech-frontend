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

    test('getSeason identifies all 4 Ethiopian agricultural seasons', () {
      // 1. Tseday / Meher (Sep - Nov | Meskerem, Tikimt, Hidar)
      final tseday = DateFormatter.getEthiopianSeasonInfo(DateTime(2026, 10, 15));
      expect(tseday.nameEn, equals('Tseday / Meher'));
      expect(tseday.gregorianMonths, equals('September to November'));
      expect(tseday.ethiopianMonthsEn, equals('Meskerem, Tikimt, Hidar'));

      // 2. Bega (Dec - Feb | Tahsas, Tir, Yakatit)
      final bega = DateFormatter.getEthiopianSeasonInfo(DateTime(2026, 1, 10));
      expect(bega.nameEn, equals('Bega'));
      expect(bega.gregorianMonths, equals('December to February'));
      expect(bega.ethiopianMonthsEn, equals('Tahsas, Tir, Yakatit'));

      // 3. Belg / Metsew (Mar - May | Maggabit, Miyazya, Ginbot)
      final belg = DateFormatter.getEthiopianSeasonInfo(DateTime(2026, 4, 20));
      expect(belg.nameEn, equals('Belg / Metsew'));
      expect(belg.gregorianMonths, equals('March to May'));
      expect(belg.ethiopianMonthsEn, equals('Maggabit, Miyazya, Ginbot'));

      // 4. Kiremt (Jun - Aug | Sene, Hamle, Nehasse)
      final kiremt = DateFormatter.getEthiopianSeasonInfo(DateTime(2026, 7, 15));
      expect(kiremt.nameEn, equals('Kiremt'));
      expect(kiremt.gregorianMonths, equals('June to August'));
      expect(kiremt.ethiopianMonthsEn, equals('Sene, Hamle, Nehasse'));
      
      // All 4 seasons list check
      expect(DateFormatter.allSeasons.length, equals(4));
    });
  });
}
