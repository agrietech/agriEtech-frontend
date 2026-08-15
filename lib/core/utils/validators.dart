///
/// @file validators.dart
/// @description Input form validators (Ethiopian phone numbers, numeric coordinates, hectares).
/// @author Frontend Core
///
library validators;

class FormValidators {
  static String? validateEthiopianPhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number required';
    if (!RegExp(r'^(09|07|+2519|+2517)d{8}$').hasMatch(value)) {
      return 'Invalid Ethiopian phone number';
    }
    return null;
  }
}
