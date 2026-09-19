import 'package:flutter_test/flutter_test.dart';
import 'package:EthioFarm/core/models/farm_model.dart';
import 'package:EthioFarm/features/farms/providers/farms_provider.dart';

void main() {
  group('CreateFarmRequest & FarmModel Tests', () {
    test('CreateFarmRequest correctly serializes to JSON with all fallback aliases', () {
      const request = CreateFarmRequest(
        farmName: 'Adaa Demonstration Plot',
        primaryCrop: 'Teff',
        areaHectares: 3.5,
        latitude: 8.54,
        longitude: 39.27,
        soilType: 'Vertisol (Black Cotton)',
        irrigationType: 'Rainfed',
        woredaId: 'ET040101',
      );

      final json = request.toJson();

      expect(json['farmName'], equals('Adaa Demonstration Plot'));
      expect(json['name'], equals('Adaa Demonstration Plot'));
      expect(json['primaryCrop'], equals('Teff'));
      expect(json['cropType'], equals('Teff'));
      expect(json['areaHectares'], equals(3.5));
      expect(json['size'], equals(3.5));
      expect(json['latitude'], equals(8.54));
      expect(json['longitude'], equals(39.27));
      expect(json['soilType'], equals('Vertisol (Black Cotton)'));
      expect(json['irrigationType'], equals('Rainfed'));
      expect(json['woredaId'], equals('ET040101'));
    });

    test('FarmModel deserializes accurately from API response JSON', () {
      final apiJson = {
        'id': 'farm-12345',
        'userId': 'user-999',
        'farmName': 'East Shewa Wheat Farm',
        'primaryCrop': 'Wheat',
        'areaHectares': 5.0,
        'latitude': 8.75,
        'longitude': 39.01,
        'soilType': 'Nitisol',
        'irrigationType': 'Furrow',
        'woredaId': 'ET040102',
        'woreda': {
          'id': 'ET040102',
          'name': 'Bishoftu',
        },
        'createdAt': '2026-08-20T10:00:00.000Z',
      };

      final farm = FarmModel.fromJson(apiJson);

      expect(farm.id, equals('farm-12345'));
      expect(farm.userId, equals('user-999'));
      expect(farm.farmName, equals('East Shewa Wheat Farm'));
      expect(farm.name, equals('East Shewa Wheat Farm'));
      expect(farm.primaryCrop, equals('Wheat'));
      expect(farm.areaHectares, equals(5.0));
      expect(farm.latitude, equals(8.75));
      expect(farm.longitude, equals(39.01));
      expect(farm.soilType, equals('Nitisol'));
      expect(farm.irrigationType, equals('Furrow'));
      expect(farm.woredaId, equals('ET040102'));
      expect(farm.woreda?.name, equals('Bishoftu'));
      expect(farm.createdAt, isNotNull);
    });

    test('FarmsState manages list updates and immutability correctly', () {
      final initialState = FarmsState();
      expect(initialState.hasFarms, isFalse);
      expect(initialState.farms.length, equals(0));

      const newFarm = FarmModel(
        id: 'farm-001',
        userId: 'u1',
        farmName: 'Harar Coffee Plot',
        primaryCrop: 'Coffee',
        areaHectares: 2.0,
        latitude: 9.31,
        longitude: 42.12,
      );

      final updatedState = initialState.copyWith(
        farms: [newFarm],
        isLoading: false,
        lastUpdated: DateTime.now(),
      );

      expect(updatedState.hasFarms, isTrue);
      expect(updatedState.farms.length, equals(1));
      expect(updatedState.farms.first.farmName, equals('Harar Coffee Plot'));
      expect(updatedState.farms.first.primaryCrop, equals('Coffee'));
    });

    test('UpdateFarmRequest serializes to JSON with GIS polygon boundary', () {
      const polygonGeojson = {
        'type': 'Polygon',
        'coordinates': [
          [
            [39.27, 8.54],
            [39.28, 8.54],
            [39.28, 8.55],
            [39.27, 8.55],
            [39.27, 8.54],
          ]
        ]
      };

      const request = UpdateFarmRequest(
        farmName: 'Updated Adama Parcel',
        primaryCrop: 'Wheat',
        areaHectares: 4.2,
        latitude: 8.545,
        longitude: 39.275,
        soilType: 'Vertisol (Black Cotton)',
        irrigationType: 'Furrow',
        geoJsonBoundary: polygonGeojson,
      );

      final json = request.toJson();
      expect(json['farmName'], equals('Updated Adama Parcel'));
      expect(json['primaryCrop'], equals('Wheat'));
      expect(json['areaHectares'], equals(4.2));
      expect(json['latitude'], equals(8.545));
      expect(json['longitude'], equals(39.275));
      expect(json['soilType'], equals('Vertisol (Black Cotton)'));
      expect(json['irrigationType'], equals('Furrow'));
      expect(json['geoJsonBoundary'], equals(polygonGeojson));
      expect(json['polygonGeojson'], equals(polygonGeojson));
    });

    test('FarmsState correctly reflects farm update and farm deletion', () {
      const farm1 = FarmModel(
        id: 'farm-001',
        userId: 'u1',
        farmName: 'Adaa Teff Field',
        primaryCrop: 'Teff',
        areaHectares: 2.0,
        latitude: 8.54,
        longitude: 39.27,
      );

      const farm2 = FarmModel(
        id: 'farm-002',
        userId: 'u1',
        farmName: 'Lume Chickpea Plot',
        primaryCrop: 'Chickpeas',
        areaHectares: 1.5,
        latitude: 8.60,
        longitude: 39.20,
      );

      final stateWithTwoFarms = FarmsState(farms: [farm1, farm2]);
      expect(stateWithTwoFarms.farms.length, equals(2));

      // Test Update
      const updatedFarm1 = FarmModel(
        id: 'farm-001',
        userId: 'u1',
        farmName: 'Adaa Teff Field (Expanded GIS Polygon)',
        primaryCrop: 'Teff',
        areaHectares: 3.2,
        latitude: 8.542,
        longitude: 39.271,
      );

      final updatedList = stateWithTwoFarms.farms.map((f) => f.id == 'farm-001' ? updatedFarm1 : f).toList();
      final stateAfterUpdate = stateWithTwoFarms.copyWith(farms: updatedList);

      expect(stateAfterUpdate.farms.length, equals(2));
      expect(stateAfterUpdate.farms.first.farmName, equals('Adaa Teff Field (Expanded GIS Polygon)'));
      expect(stateAfterUpdate.farms.first.areaHectares, equals(3.2));

      // Test Delete
      final listAfterDelete = stateAfterUpdate.farms.where((f) => f.id != 'farm-001').toList();
      final stateAfterDelete = stateAfterUpdate.copyWith(farms: listAfterDelete);

      expect(stateAfterDelete.farms.length, equals(1));
      expect(stateAfterDelete.farms.first.id, equals('farm-002'));
      expect(stateAfterDelete.farms.first.farmName, equals('Lume Chickpea Plot'));
    });

    test('FarmModel handles woreda and coordinate formatting safely without region getter crash', () {
      const farm = FarmModel(
        id: 'farm-003',
        userId: 'u3',
        farmName: 'Bale Highland Barley',
        primaryCrop: 'Barley',
        areaHectares: 4.2,
        latitude: 7.1234,
        longitude: 39.5678,
        woredaId: 'ET040301',
        woreda: WoredaInfo(id: 'ET040301', name: 'Goba'),
      );

      final locString = 'Location: ${farm.woreda?.name ?? farm.woredaId ?? 'Ethiopia'} • GPS: ${farm.latitude.toStringAsFixed(4)}, ${farm.longitude.toStringAsFixed(4)}';
      expect(locString, equals('Location: Goba • GPS: 7.1234, 39.5678'));

      const fallbackFarm = FarmModel(
        id: 'farm-004',
        userId: 'u4',
        farmName: 'Arsi Wheat',
        primaryCrop: 'Wheat',
        areaHectares: 2.0,
        latitude: 7.8912,
        longitude: 39.1234,
      );
      final fallbackLocString = 'Location: ${fallbackFarm.woreda?.name ?? fallbackFarm.woredaId ?? 'Ethiopia'} • GPS: ${fallbackFarm.latitude.toStringAsFixed(4)}, ${fallbackFarm.longitude.toStringAsFixed(4)}';
      expect(fallbackLocString, equals('Location: Ethiopia • GPS: 7.8912, 39.1234'));
    });
  });
}
