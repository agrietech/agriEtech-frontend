/// Input validation utilities
class Validators {
  /// Validate email format
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

<<<<<<< HEAD
class FormValidators {
  static String? validateEthiopianPhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number required';
    if (!RegExp(r'^(\+2519|\+2517|09|07)\d{8}$').hasMatch(value)) {
      return 'Invalid Ethiopian phone number';
=======
  /// Validate phone number (Ethiopian format)
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    
    final clean = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final ethRegex = RegExp(r'^(\+?251|0)?[79]\d{8}$');
    
    if (!ethRegex.hasMatch(clean)) {
      return 'Enter a valid Ethio Telecom (09...) or Safaricom (07...) number';
    }
    
    return null;
  }

  /// Validate password strength
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    
    return null;
  }

  /// Validate confirm password
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  /// Validate required field
  static String? required(String? value, [String fieldName = 'Field']) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
>>>>>>> develop
    }
    return null;
  }

  /// Alias for [required] — validates that a field is not empty
  static String? validateRequired(String? value, [String fieldName = 'Field']) {
    return required(value, fieldName);
  }

  /// Validate minimum length
  static String? minLength(String? value, int min, [String fieldName = 'Field']) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    if (value.length < min) {
      return '$fieldName must be at least $min characters';
    }
    
    return null;
  }

  /// Validate maximum length
  static String? maxLength(String? value, int max, [String fieldName = 'Field']) {
    if (value != null && value.length > max) {
      return '$fieldName must be at most $max characters';
    }
    return null;
  }

  /// Validate numeric input
  static String? numeric(String? value, [String fieldName = 'Field']) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    if (double.tryParse(value) == null) {
      return '$fieldName must be a valid number';
    }
    
    return null;
  }

  /// Validate positive number
  static String? positiveNumber(String? value, [String fieldName = 'Field']) {
    final numericError = numeric(value, fieldName);
    if (numericError != null) return numericError;
    
    if (double.parse(value!) <= 0) {
      return '$fieldName must be a positive number';
    }
    
    return null;
  }

  /// Validate GPS coordinates
  static String? latitude(String? value) {
    final numericError = numeric(value, 'Latitude');
    if (numericError != null) return numericError;
    
    final lat = double.parse(value!);
    if (lat < -90 || lat > 90) {
      return 'Latitude must be between -90 and 90';
    }
    
    return null;
  }

  static String? longitude(String? value) {
    final numericError = numeric(value, 'Longitude');
    if (numericError != null) return numericError;
    
    final lng = double.parse(value!);
    if (lng < -180 || lng > 180) {
      return 'Longitude must be between -180 and 180';
    }
    
    return null;
  }

  /// Validate Ethiopian coordinates
  static String? ethiopianLatitude(String? value) {
    final latError = latitude(value);
    if (latError != null) return latError;
    
    final lat = double.parse(value!);
    if (lat < 3.0 || lat > 15.0) {
      return 'Latitude must be within Ethiopia (3.0 to 15.0)';
    }
    
    return null;
  }

  static String? ethiopianLongitude(String? value) {
    final lngError = longitude(value);
    if (lngError != null) return lngError;
    
    final lng = double.parse(value!);
    if (lng < 33.0 || lng > 48.0) {
      return 'Longitude must be within Ethiopia (33.0 to 48.0)';
    }
    
    return null;
  }

  /// Validate URL format
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }

  /// Validate area (in hectares)
  static String? farmArea(String? value) {
    final numericError = positiveNumber(value, 'Farm area');
    if (numericError != null) return numericError;
    
    final area = double.parse(value!);
    if (area > 10000) {
      return 'Farm area seems too large. Please verify.';
    }
    return null;
  }

  /// Validate username format
  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    final clean = value.trim();
    if (clean.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(clean)) {
      return 'Username can only contain letters, numbers, dots, and underscores';
    }
    return null;
  }
}