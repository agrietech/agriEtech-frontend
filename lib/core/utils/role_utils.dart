import '../models/user_model.dart';

/// Utility class for role-based access control across 1 National Admin + 6 Roles
class RoleUtils {
  /// Check if user can create early warning alerts
  static bool canCreateAlerts(UserRole? role) {
    return role == UserRole.admin ||
        role == UserRole.regionalOfficer ||
        role == UserRole.zonalOfficer ||
        role == UserRole.woredaOfficer ||
        role == UserRole.developmentAgent;
  }

  /// Check if user can manage farm plots
  static bool canManageFarms(UserRole? role) {
    return role == UserRole.farmer ||
        role == UserRole.developmentAgent ||
        role == UserRole.woredaOfficer ||
        role == UserRole.zonalOfficer ||
        role == UserRole.regionalOfficer ||
        role == UserRole.admin;
  }

  /// Check if user can view analytics and climate trends
  static bool canViewAnalytics(UserRole? role) {
    return role == UserRole.researcher ||
        role == UserRole.regionalOfficer ||
        role == UserRole.zonalOfficer ||
        role == UserRole.woredaOfficer ||
        role == UserRole.admin;
  }

  /// Check if user can register IoT sensors
  static bool canRegisterSensors(UserRole? role) {
    return role == UserRole.developmentAgent ||
        role == UserRole.woredaOfficer ||
        role == UserRole.zonalOfficer ||
        role == UserRole.regionalOfficer ||
        role == UserRole.admin;
  }

  /// Check if user can manage sensors
  static bool canManageSensors(UserRole? role) {
    return role == UserRole.developmentAgent ||
        role == UserRole.woredaOfficer ||
        role == UserRole.zonalOfficer ||
        role == UserRole.regionalOfficer ||
        role == UserRole.admin;
  }

  /// Check if user can create crop disease diagnoses
  static bool canCreateDiagnosis(UserRole? role) {
    return role == UserRole.farmer ||
        role == UserRole.developmentAgent ||
        role == UserRole.woredaOfficer ||
        role == UserRole.admin;
  }

  /// Check if user can export data and scientific reports
  static bool canExportData(UserRole? role) {
    return role == UserRole.researcher ||
        role == UserRole.regionalOfficer ||
        role == UserRole.zonalOfficer ||
        role == UserRole.woredaOfficer ||
        role == UserRole.admin;
  }

  /// Check if user can review and approve subordinate role requests
  static bool canApproveRoleRequests(UserRole? role) {
    return role == UserRole.admin ||
        role == UserRole.regionalOfficer ||
        role == UserRole.zonalOfficer ||
        role == UserRole.woredaOfficer;
  }

  /// Role check helpers
  static bool isAdmin(UserRole? role) => role == UserRole.admin;
  static bool isNationalAdmin(UserRole? role) => role == UserRole.admin;
  static bool isRegionalOfficer(UserRole? role) => role == UserRole.regionalOfficer;
  static bool isZonalOfficer(UserRole? role) => role == UserRole.zonalOfficer;
  static bool isOfficer(UserRole? role) =>
      role == UserRole.woredaOfficer ||
      role == UserRole.zonalOfficer ||
      role == UserRole.regionalOfficer ||
      role == UserRole.admin;
  static bool isWoredaOfficer(UserRole? role) => role == UserRole.woredaOfficer;
  static bool isAgent(UserRole? role) => role == UserRole.developmentAgent;
  static bool isDevelopmentAgent(UserRole? role) => role == UserRole.developmentAgent;
  static bool isResearcher(UserRole? role) => role == UserRole.researcher;
  static bool isFarmer(UserRole? role) => role == UserRole.farmer;

  /// Get role display name
  static String getRoleDisplayName(UserRole? role) {
    switch (role) {
      case UserRole.admin:
        return 'National Administrator';
      case UserRole.regionalOfficer:
        return 'Regional Officer';
      case UserRole.zonalOfficer:
        return 'Zonal Officer';
      case UserRole.woredaOfficer:
        return 'Woreda Officer';
      case UserRole.developmentAgent:
        return 'Development Agent (DA)';
      case UserRole.researcher:
        return 'Agronomy Researcher';
      case UserRole.farmer:
      default:
        return 'Smallholder Farmer';
    }
  }

  /// Get role permissions description
  static String getRolePermissions(UserRole? role) {
    switch (role) {
      case UserRole.admin:
        return 'Supreme National oversight (all 15 regions, full administrative command)';
      case UserRole.regionalOfficer:
        return 'Regional administrative oversight, zonal coordination & regional alerts';
      case UserRole.zonalOfficer:
        return 'Zonal administrative oversight & woreda hazard monitoring';
      case UserRole.woredaOfficer:
        return 'Woreda early warning, kebele oversight, DA management';
      case UserRole.developmentAgent:
        return 'Kebele FTC extension worker, farmer management, field disease scouting';
      case UserRole.researcher:
        return 'Planetary Earth Engine climate analytics, crop modeling, data export';
      case UserRole.farmer:
      default:
        return 'Manage personal farm plots, scan leaf diseases, receive local kebele alerts';
    }
  }
}

