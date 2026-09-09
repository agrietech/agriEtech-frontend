import 'package:flutter_test/flutter_test.dart';
import 'package:EthioFarm/core/models/user_model.dart';
import 'package:EthioFarm/features/auth/providers/auth_provider.dart';

void main() {
  group('AuthState & UserRole Permission Tests', () {
    test('Default AuthState is not authenticated and not loading', () {
      final state = AuthState();
      expect(state.isAuthenticated, isFalse);
      expect(state.isLoading, isFalse);
      expect(state.isInitializing, isFalse);
      expect(state.user, isNull);
      expect(state.error, isNull);
    });

    test('AuthState copyWith preserves values and updates correctly', () {
      final state = AuthState(isLoading: true);
      final updated = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
      );

      expect(updated.isLoading, isFalse);
      expect(updated.isAuthenticated, isTrue);
    });

    test('Farmer role permissions are correctly evaluated', () {
      final farmerUser = UserModel(
        id: 'u-1',
        fullName: 'Abebe Bikila',
        phone: '+251911223344',
        email: 'abebe@example.com',
        role: UserRole.farmer,
        preferredLang: 'am',
        isActive: true,
        createdAt: DateTime(2025, 1, 1),
      );

      final state = AuthState(user: farmerUser, isAuthenticated: true);
      expect(state.isFarmer, isTrue);
      expect(state.isAdmin, isFalse);
      expect(state.isDevelopmentAgent, isFalse);
      expect(state.canCreateAlerts, isFalse);
      expect(state.canAccessAllData, isFalse);
      expect(state.canManageSensors, isTrue);
    });

    test('Woreda Officer and Admin can create alerts and access data', () {
      final officerUser = UserModel(
        id: 'u-2',
        fullName: 'Officer Kebede',
        phone: '+251922334455',
        email: 'officer@example.com',
        role: UserRole.woredaOfficer,
        preferredLang: 'en',
        isActive: true,
        createdAt: DateTime(2025, 1, 1),
      );

      final officerState = AuthState(user: officerUser, isAuthenticated: true);
      expect(officerState.canCreateAlerts, isTrue);

      final adminUser = UserModel(
        id: 'u-3',
        fullName: 'System Admin',
        phone: '+251933445566',
        email: 'admin@agrietech.com',
        role: UserRole.admin,
        preferredLang: 'en',
        isActive: true,
        createdAt: DateTime(2025, 1, 1),
      );

      final adminState = AuthState(user: adminUser, isAuthenticated: true);
      expect(adminState.isAdmin, isTrue);
      expect(adminState.canCreateAlerts, isTrue);
      expect(adminState.canAccessAllData, isTrue);
    });

    test('LoginResponse correctly parses requiresPhoneVerification flag', () {
      final unverifiedJson = {
        'accessToken': 'jwt-token-123',
        'refreshToken': 'jwt-refresh-123',
        'requiresPhoneVerification': true,
        'user': {
          'id': 'u-10',
          'fullName': 'Derartu Tulu',
          'phone': '+251911998877',
          'role': 'FARMER',
          'isPhoneVerified': false,
        },
      };

      final response = LoginResponse.fromJson(unverifiedJson);
      expect(response.requiresPhoneVerification, isTrue);
      expect(response.user.isPhoneVerified, isFalse);

      final verifiedJson = {
        'accessToken': 'jwt-token-456',
        'refreshToken': 'jwt-refresh-456',
        'requiresPhoneVerification': false,
        'user': {
          'id': 'u-11',
          'fullName': 'Haile Gebrselassie',
          'phone': '+251911445566',
          'role': 'FARMER',
          'isPhoneVerified': true,
        },
      };

      final verifiedResponse = LoginResponse.fromJson(verifiedJson);
      expect(verifiedResponse.requiresPhoneVerification, isFalse);
      expect(verifiedResponse.user.isPhoneVerified, isTrue);
    });

    test('RegisterResult encapsulates registration requirement correctly', () {
      const user = UserModel(
        id: 'u-12',
        fullName: 'Kenenisa Bekele',
        phone: '+251912345678',
        role: UserRole.farmer,
        isPhoneVerified: false,
      );

      const result = RegisterResult(
        requiresPhoneVerification: true,
        phone: '+251912345678',
        user: user,
      );

      expect(result.requiresPhoneVerification, isTrue);
      expect(result.phone, '+251912345678');
      expect(result.user.isPhoneVerified, isFalse);
    });
  });
}
