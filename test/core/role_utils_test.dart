import 'package:flutter_test/flutter_test.dart';
import 'package:agrietech/core/models/user_model.dart';
import 'package:agrietech/core/utils/role_utils.dart';

void main() {
  group('RoleUtils - Alert Permissions', () {
    test('only officers, agents, and admin can create alerts', () {
      expect(RoleUtils.canCreateAlerts(UserRole.woredaOfficer), isTrue);
      expect(RoleUtils.canCreateAlerts(UserRole.developmentAgent), isTrue);
      expect(RoleUtils.canCreateAlerts(UserRole.admin), isTrue);
      expect(RoleUtils.canCreateAlerts(UserRole.farmer), isFalse);
      expect(RoleUtils.canCreateAlerts(UserRole.researcher), isFalse);
      expect(RoleUtils.canCreateAlerts(null), isFalse);
    });
  });

  group('RoleUtils - Farm Management Permissions', () {
    test('farmers, agents, officers, and admin can manage farms', () {
      expect(RoleUtils.canManageFarms(UserRole.farmer), isTrue);
      expect(RoleUtils.canManageFarms(UserRole.developmentAgent), isTrue);
      expect(RoleUtils.canManageFarms(UserRole.woredaOfficer), isTrue);
      expect(RoleUtils.canManageFarms(UserRole.admin), isTrue);
      expect(RoleUtils.canManageFarms(UserRole.researcher), isFalse);
      expect(RoleUtils.canManageFarms(null), isFalse);
    });
  });

  group('RoleUtils - Analytics & Export Permissions', () {
    test('researchers, officers, and admin can view analytics and export', () {
      expect(RoleUtils.canViewAnalytics(UserRole.researcher), isTrue);
      expect(RoleUtils.canViewAnalytics(UserRole.woredaOfficer), isTrue);
      expect(RoleUtils.canViewAnalytics(UserRole.admin), isTrue);
      expect(RoleUtils.canViewAnalytics(UserRole.farmer), isFalse);
      expect(RoleUtils.canViewAnalytics(UserRole.developmentAgent), isFalse);

      expect(RoleUtils.canExportData(UserRole.researcher), isTrue);
      expect(RoleUtils.canExportData(UserRole.woredaOfficer), isTrue);
      expect(RoleUtils.canExportData(UserRole.admin), isTrue);
      expect(RoleUtils.canExportData(UserRole.farmer), isFalse);
    });
  });

  group('RoleUtils - Sensor Management Permissions', () {
    test('agents, officers, and admin can register and manage sensors', () {
      expect(RoleUtils.canRegisterSensors(UserRole.developmentAgent), isTrue);
      expect(RoleUtils.canRegisterSensors(UserRole.woredaOfficer), isTrue);
      expect(RoleUtils.canRegisterSensors(UserRole.admin), isTrue);
      expect(RoleUtils.canRegisterSensors(UserRole.farmer), isFalse);
      expect(RoleUtils.canRegisterSensors(UserRole.researcher), isFalse);
    });
  });

  group('RoleUtils - Helper Checkers & Display Names', () {
    test('role type checkers', () {
      expect(RoleUtils.isAdmin(UserRole.admin), isTrue);
      expect(RoleUtils.isAdmin(UserRole.farmer), isFalse);
      expect(RoleUtils.isFarmer(UserRole.farmer), isTrue);
      expect(RoleUtils.isOfficer(UserRole.woredaOfficer), isTrue);
      expect(RoleUtils.isAgent(UserRole.developmentAgent), isTrue);
      expect(RoleUtils.isResearcher(UserRole.researcher), isTrue);
    });

    test('role display names and descriptions', () {
      expect(RoleUtils.getRoleDisplayName(UserRole.farmer), equals('Smallholder Farmer'));
      expect(RoleUtils.getRoleDisplayName(UserRole.developmentAgent), equals('Development Agent (DA)'));
      expect(RoleUtils.getRoleDisplayName(UserRole.woredaOfficer), equals('Woreda Officer'));
      expect(RoleUtils.getRoleDisplayName(UserRole.researcher), equals('Agronomy Researcher'));
      expect(RoleUtils.getRoleDisplayName(UserRole.admin), equals('National Administrator'));
      expect(RoleUtils.getRoleDisplayName(null), equals('Smallholder Farmer'));

      expect(RoleUtils.getRolePermissions(UserRole.farmer), isNotEmpty);
      expect(RoleUtils.getRolePermissions(UserRole.admin), contains('Supreme National oversight'));
    });
  });
}
