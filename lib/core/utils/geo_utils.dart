/// GPS location retrieval and polygon calculation utilities
library geo_utils;

class LatLng {
  final double lat;
  final double lng;
  const LatLng(this.lat, this.lng);

  Map<String, double> toMap() => {'lat': lat, 'lng': lng};

  @override
  String toString() => 'LatLng($lat, $lng)';
}

class AppGeoUtils {
  /// Calculate centroid of a polygon given as list of [lat, lng] pairs
  static LatLng centroid(List<List<double>> coords) {
    double lat = 0, lng = 0;
    for (final c in coords) { lat += c[0]; lng += c[1]; }
    return LatLng(lat / coords.length, lng / coords.length);
  }

  /// Approximate polygon area in hectares using Shoelace formula
  static double areaHectares(List<List<double>> coords) {
    double area = 0;
    final n = coords.length;
    for (int i = 0; i < n; i++) {
      final j = (i + 1) % n;
      area += coords[i][1] * coords[j][0];
      area -= coords[j][1] * coords[i][0];
    }
    // Convert square degrees to hectares (approximate at Ethiopia latitude ~9°N)
    return (area.abs() / 2) * 1.2308e10;
  }

  /// Check if point is inside Ethiopia bounding box
  static bool isInEthiopia(double lat, double lng) =>
      lat >= 3.4 && lat <= 14.9 && lng >= 33.0 && lng <= 47.9;

  /// Distance in km between two points (Haversine)
  static double distanceKm(LatLng a, LatLng b) {
    const R = 6371.0;
    final dLat = _toRad(b.lat - a.lat);
    final dLng = _toRad(b.lng - a.lng);
    final x = _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRad(a.lat)) * _cos(_toRad(b.lat)) *
            _sin(dLng / 2) * _sin(dLng / 2);
    return R * 2 * _atan2(_sqrt(x), _sqrt(1 - x));
  }

  static double _toRad(double deg) => deg * 3.14159265 / 180;
  static double _sin(double x) => x - (x * x * x / 6);
  static double _cos(double x) => 1 - (x * x / 2);
  static double _atan2(double y, double x) => x == 0 ? 1.5708 : y / x;
  static double _sqrt(double x) => x <= 0 ? 0 : x * (1 - (x - 1) / 2);
}
