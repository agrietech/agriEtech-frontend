import '../models/user_model.dart';

/// Utility class for role-based access control
class RoleUtils {
  /// Check if user can create alerts
  static bool canCreateAlerts(UserRole? role) {
    return role == UserRole.woredaOfficer ||
        role == UserRole.developmentAgent ||
        role == UserRole.admin;
  }

  /// Check if user can manage farms
  static bool canManageFarms(UserRole? role) {
    return role == UserRole.farmer ||
        role == UserRole.developmentAgent ||
        role == UserRole.woredaOfficer ||
        role == UserRole.admin;
  }

  /// Check if user can view analytics
  static bool canViewAnalytics(UserRole? role) {
    return role == UserRole.researcher ||
        role == UserRole.woredaOfficer ||
        role == UserRole.admin;
  }

  /// Check if user can register sensors
  static bool canRegisterSensors(UserRole? role) {
    return role == UserRole.developmentAgent ||
        role == UserRole.woredaOfficer ||
        role == UserRole.admin;
  }

  /// Check if user can manage sensors
  static bool canManageSensors(UserRole? role) {
    return role == UserRole.developmentAgent ||
        role == UserRole.woredaOfficer ||
        role == UserRole.admin;
  }

  /// Check if user can create diagnosis
  static bool canCreateDiagnosis(UserRole? role) {
    return role == UserRole.farmer ||
        role == UserRole.developmentAgent ||
        role == UserRole.woredaOfficer ||
        role == UserRole.admin;
  }

  /// Check if user can export data
  static bool canExportData(UserRole? role) {
    return role == UserRole.researcher ||
        role == UserRole.woredaOfficer ||
        role == UserRole.admin;
  }

  /// Check if user is admin
  static bool isAdmin(UserRole? role) {
    return role == UserRole.admin;
  }

  /// Check if user is officer
  static bool isOfficer(UserRole? role) {
    return role == UserRole.woredaOfficer;
  }

  /// Check if user is agent
  static bool isAgent(UserRole? role) {
    return role == UserRole.developmentAgent;
  }

  /// Check if user is researcher
  static bool isResearcher(UserRole? role) {
    return role == UserRole.researcher;
  }

  /// Check if user is farmer
  static bool isFarmer(UserRole? role) {
    return role == UserRole.farmer;
  }

  /// Get role display name
  static String getRoleDisplayName(UserRole? role) {
    switch (role) {
      case UserRole.farmer:
        return 'Farmer';
      case UserRole.developmentAgent:
        return 'Development Agent';
      case UserRole.woredaOfficer:
        return 'Woreda Officer';
      case UserRole.researcher:
        return 'Researcher';
      case UserRole.admin:
        return 'Administrator';
      default:
        return 'User';
    }
  }

  /// Get role permissions description
  static String getRolePermissions(UserRole? role) {
    switch (role) {
      case UserRole.farmer:
        return 'View own farms, alerts, and diagnoses';
      case UserRole.developmentAgent:
        return 'Create alerts, manage farmers\' farms, register sensors';
      case UserRole.woredaOfficer:
        return 'Full alert management, regional oversight, analytics';
      case UserRole.researcher:
        return 'Access to analytics, data export, reports';
      case UserRole.admin:
        return 'Full system access and administration';
      default:
        return 'Limited access';
    }
  }
}
