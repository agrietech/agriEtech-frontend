/// Auth domain service — validates credentials before sending to repository
library auth_service;

class AuthService {
  /// Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email.trim());
  }

  /// Validate Ethiopian phone number (+251XXXXXXXXX or 09XXXXXXXX)
  static bool isValidPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s-]'), '');
    return RegExp(r'^(\+251|0)[79]\d{8}$').hasMatch(cleaned);
  }

  /// Normalize phone to +251 format
  static String normalizePhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s-]'), '');
    if (cleaned.startsWith('0')) return '+251${cleaned.substring(1)}';
    if (cleaned.startsWith('251')) return '+$cleaned';
    return cleaned;
  }

  /// Detect if identifier is email or phone
  static bool isEmail(String identifier) => identifier.contains('@');

  /// Validate password strength (min 8 chars, 1 uppercase, 1 digit)
  static bool isStrongPassword(String pw) =>
      pw.length >= 8 && pw.contains(RegExp(r'[A-Z]')) && pw.contains(RegExp(r'[0-9]'));
}
