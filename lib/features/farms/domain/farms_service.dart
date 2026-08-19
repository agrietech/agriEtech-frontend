/// Farm domain service — business rule validators for farm registration
library farms_service;

class FarmsService {
  /// Validate that a polygon has at least 3 points and is closed
  static bool isValidPolygon(List<List<double>> coords) {
    if (coords.length < 3) return false;
    if (coords.isEmpty) return false;
    // Check ring closure
    final first = coords.first;
    final last = coords.last;
    return first[0] == last[0] && first[1] == last[1];
  }

  /// Ensure polygon is closed (first == last point)
  static List<List<double>> closedPolygon(List<List<double>> coords) {
    if (coords.isEmpty) return coords;
    final first = coords.first;
    final last = coords.last;
    if (first[0] != last[0] || first[1] != last[1]) {
      return [...coords, first];
    }
    return coords;
  }

  /// Validate farm name length
  static bool isValidFarmName(String name) => name.trim().length >= 2 && name.trim().length <= 100;

  /// Valid Ethiopian crop types
  static const List<String> validCropTypes = [
    'WHEAT', 'MAIZE', 'TEFF', 'SORGHUM', 'BARLEY',
    'COFFEE', 'SESAME', 'CHICKPEA', 'LENTIL', 'OTHER'
  ];
  static bool isValidCropType(String crop) => validCropTypes.contains(crop.toUpperCase());
}
