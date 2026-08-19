import 'package:flutter_test/flutter_test.dart';
import 'package:agrietech/core/models/user_model.dart';
import 'package:agrietech/features/auth/providers/auth_provider.dart';

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
  });
}
