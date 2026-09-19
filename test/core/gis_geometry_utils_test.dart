import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:EthioFarm/core/utils/gis_geometry_utils.dart';

void main() {
  group('GisGeometryUtils Tests', () {
    test('calculateSphericalPolygonAreaKm2 returns 0 for less than 3 vertices', () {
      expect(GisGeometryUtils.calculateSphericalPolygonAreaKm2([]), 0.0);
      expect(GisGeometryUtils.calculateSphericalPolygonAreaKm2([const LatLng(8.5, 39.2)]), 0.0);
      expect(GisGeometryUtils.calculateSphericalPolygonAreaKm2([
        const LatLng(8.5, 39.2),
        const LatLng(8.51, 39.2),
      ]), 0.0);
    });

    test('calculateSphericalPolygonAreaKm2 computes positive non-zero area for a polygon', () {
      final squarePlot = [
        const LatLng(8.500, 39.200),
        const LatLng(8.500, 39.210),
        const LatLng(8.510, 39.210),
        const LatLng(8.510, 39.200),
      ];
      final area = GisGeometryUtils.calculateSphericalPolygonAreaKm2(squarePlot);
      expect(area, greaterThan(0.5));
      expect(area, lessThan(2.0));
    });

    test('km2ToHectares accurately converts 1 km² to 100 hectares', () {
      expect(GisGeometryUtils.km2ToHectares(1.0), 100.0);
      expect(GisGeometryUtils.km2ToHectares(0.25), 25.0);
      expect(GisGeometryUtils.km2ToHectares(2.3456), 234.56);
    });

    test('calculateCentroid computes center coordinates accurately', () {
      final points = [
        const LatLng(8.0, 38.0),
        const LatLng(10.0, 38.0),
        const LatLng(10.0, 40.0),
        const LatLng(8.0, 40.0),
      ];
      final centroid = GisGeometryUtils.calculateCentroid(points);
      expect(centroid.latitude, closeTo(9.0, 0.001));
      expect(centroid.longitude, closeTo(39.0, 0.001));
    });

    test('isPointInPolygon detects internal and external coordinates', () {
      final polygon = [
        const LatLng(8.0, 38.0),
        const LatLng(10.0, 38.0),
        const LatLng(10.0, 40.0),
        const LatLng(8.0, 40.0),
      ];

      const inside = LatLng(9.0, 39.0);
      const outside = LatLng(7.0, 39.0);

      expect(GisGeometryUtils.isPointInPolygon(inside, polygon), isTrue);
      expect(GisGeometryUtils.isPointInPolygon(outside, polygon), isFalse);
    });
  });
}
