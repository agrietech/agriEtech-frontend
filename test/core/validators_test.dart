import 'package:flutter_test/flutter_test.dart';
import 'package:agrietech/core/utils/validators.dart';

void main() {
  group('Validators - Email', () {
    test('valid emails return null', () {
      expect(Validators.email('test@example.com'), isNull);
      expect(Validators.email('farmer.ethiopia@agri.gov.et'), isNull);
      expect(Validators.email('user+filter@domain.co'), isNull);
    });

    test('invalid or empty emails return error message', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email(null), isNotNull);
      expect(Validators.email('notanemail'), isNotNull);
      expect(Validators.email('missing@domain'), isNotNull);
      expect(Validators.email('@missingusername.com'), isNotNull);
    });
  });

  group('Validators - Ethiopian Phone Numbers', () {
    test('valid Ethiopian phone numbers return null', () {
      // Ethio Telecom (09...)
      expect(Validators.phone('+251911234567'), isNull);
      expect(Validators.phone('0911234567'), isNull);
      expect(Validators.phone('091 123 4567'), isNull);
      // Safaricom Ethiopia (07...)
      expect(Validators.phone('0712345678'), isNull);
      expect(Validators.phone('+251712345678'), isNull);
      expect(Validators.phone('077 890 1234'), isNull);
    });

    test('invalid phone numbers return error message', () {
      expect(Validators.phone(''), isNotNull);
      expect(Validators.phone(null), isNotNull);
      expect(Validators.phone('12345678'), isNotNull); // too short
      expect(Validators.phone('0811234567'), contains('Ethio Telecom')); // invalid prefix (08)
      expect(Validators.phone('+1234567890'), contains('Ethio Telecom')); // non-Ethiopian
    });
  });

  group('Validators - Password Strength', () {
    test('strong password returns null', () {
      expect(Validators.password('Password123!'), isNull);
      expect(Validators.password('Agr1@Tech2026'), isNull);
    });

    test('weak passwords return descriptive error messages', () {
      expect(Validators.password(''), equals('Password is required'));
      expect(Validators.password(null), equals('Password is required'));
      expect(Validators.password('short1!'), contains('8 characters'));
      expect(Validators.password('nouppercase123!'), contains('uppercase'));
      expect(Validators.password('NoNumberSpecial!'), contains('number'));
      expect(Validators.password('NoSpecialChar123'), contains('special character'));
    });

    test('confirm password validation', () {
      expect(Validators.confirmPassword('Password123!', 'Password123!'), isNull);
      expect(Validators.confirmPassword('Password123!', 'Mismatch123!'), equals('Passwords do not match'));
      expect(Validators.confirmPassword('', 'Password123!'), isNotNull);
    });
  });

  group('Validators - Numbers & Farm Area', () {
    test('valid positive numbers and areas', () {
      expect(Validators.numeric('123.45'), isNull);
      expect(Validators.positiveNumber('5.5'), isNull);
      expect(Validators.farmArea('2.5'), isNull);
      expect(Validators.farmArea('150.0'), isNull);
    });

    test('invalid numbers and areas', () {
      expect(Validators.numeric('abc'), contains('valid number'));
      expect(Validators.positiveNumber('-5'), contains('positive number'));
      expect(Validators.positiveNumber('0'), contains('positive number'));
      expect(Validators.farmArea('20000'), contains('too large'));
    });
  });

  group('Validators - Ethiopian Coordinates', () {
    test('valid Ethiopian latitude and longitude', () {
      expect(Validators.ethiopianLatitude('9.03'), isNull); // Addis Ababa
      expect(Validators.ethiopianLongitude('38.74'), isNull);
      expect(Validators.ethiopianLatitude('11.59'), isNull); // Bahir Dar
      expect(Validators.ethiopianLongitude('37.38'), isNull);
    });

    test('coordinates outside Ethiopia return error', () {
      expect(Validators.ethiopianLatitude('51.5'), contains('within Ethiopia')); // London
      expect(Validators.ethiopianLongitude('-0.12'), contains('within Ethiopia'));
      expect(Validators.ethiopianLatitude('1.0'), contains('within Ethiopia'));
    });
  });

  group('Validators - Username', () {
    test('valid usernames return null', () {
      expect(Validators.username('abebe_bikila'), isNull);
      expect(Validators.username('farmer.2026'), isNull);
      expect(Validators.username('agri-officer'), isNull);
    });

    test('invalid or empty usernames return error message', () {
      expect(Validators.username(''), isNotNull);
      expect(Validators.username(null), isNotNull);
      expect(Validators.username('ab'), contains('3 characters'));
      expect(Validators.username('user with spaces'), contains('letters, numbers'));
      expect(Validators.username('user@special!'), contains('letters, numbers'));
    });
  });
}
