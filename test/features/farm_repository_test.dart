import 'package:flutter_test/flutter_test.dart';
import 'package:agrietech/core/models/farm_model.dart';
import 'package:agrietech/features/farms/providers/farms_provider.dart';

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
  });
}
