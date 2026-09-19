import 'dart:math' as math;
import 'package:latlong2/latlong.dart';

/// Pure geodesy algorithms for agricultural plots and administrative kebele boundaries.
/// Implements spherical excess over the WGS-84 mean Earth radius.
class GisGeometryUtils {
  GisGeometryUtils._();

  /// Earth's authalic mean radius in meters (WGS-84 / IUGG)
  static const double earthRadiusMeters = 6378137.0;

  /// Calculate spherical polygon surface area in square kilometers (km²).
  /// Uses spherical excess on LatLng coordinates.
  static double calculateSphericalPolygonAreaKm2(List<LatLng> points) {
    if (points.length < 3) return 0.0;
    double area = 0.0;
    final int n = points.length;

    for (int i = 0; i < n; i++) {
      final p1 = points[i];
      final p2 = points[(i + 1) % n];
      final lat1 = p1.latitudeInRad;
      final lat2 = p2.latitudeInRad;
      final lon1 = p1.longitudeInRad;
      final lon2 = p2.longitudeInRad;
      area += (lon2 - lon1) * (2.0 + math.sin(lat1) + math.sin(lat2));
    }
    area = (area * earthRadiusMeters * earthRadiusMeters / 2.0).abs();
    // 1 km² = 1,000,000 m²
    final km2 = area / 1000000.0;
    return double.parse(km2.toStringAsFixed(4));
  }

  /// Convert square kilometers to hectares (1 km² = 100 hectares).
  static double km2ToHectares(double km2) {
    return double.parse((km2 * 100.0).toStringAsFixed(2));
  }

  /// Calculate geometric centroid of a polygon vertex list.
  static LatLng calculateCentroid(List<LatLng> points, {LatLng? fallback}) {
    if (points.isEmpty) {
      return fallback ?? const LatLng(9.145, 40.489673); // Ethiopia center
    }
    double sumLat = 0;
    double sumLng = 0;
    for (final p in points) {
      sumLat += p.latitude;
      sumLng += p.longitude;
    }
    return LatLng(sumLat / points.length, sumLng / points.length);
  }

  /// Ray-casting algorithm to test whether a GPS coordinate point lies inside a polygon boundary.
  static bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
    if (polygon.length < 3) return false;
    bool inside = false;
    int j = polygon.length - 1;

    for (int i = 0; i < polygon.length; i++) {
      final xi = polygon[i].longitude;
      final yi = polygon[i].latitude;
      final xj = polygon[j].longitude;
      final yj = polygon[j].latitude;

      final intersect = ((yi > point.latitude) != (yj > point.latitude)) &&
          (point.longitude < (xj - xi) * (point.latitude - yi) / (yj - yi) + xi);
      if (intersect) inside = !inside;
      j = i;
    }

    return inside;
  }

  /// Compute minimum and maximum coordinate bounds for auto-fitting maps.
  static ({LatLng southWest, LatLng northEast}) calculateBoundingBox(List<LatLng> points) {
    if (points.isEmpty) {
      const defaultCoord = LatLng(9.145, 40.489673);
      return (southWest: defaultCoord, northEast: defaultCoord);
    }
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    return (
      southWest: LatLng(minLat, minLng),
      northEast: LatLng(maxLat, maxLng),
    );
  }
}
