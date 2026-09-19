import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../utils/role_utils.dart';
import '../../features/auth/providers/auth_provider.dart';

/// RBAC Guard Widget for conditional rendering based on user role/permissions
/// 
/// Usage:
/// ```dart
/// RBACGuard(
///   roles: [UserRole.admin, UserRole.woredaOfficer],
///   child: ElevatedButton(...),
///   fallback: Text('Access Denied'),
/// )
/// ```
class RBACGuard extends ConsumerWidget {
  /// Child widget to show if user has required permissions
  final Widget child;
  
  /// Fallback widget to show if user doesn't have permissions (default: empty SizedBox)
  final Widget? fallback;
  
  /// Required roles (user must have at least ONE of these roles)
  final List<UserRole>? roles;
  
  /// Custom permission check function
  final bool Function(UserRole?)? permissionCheck;
  
  /// Whether to hide completely vs show fallback (default: hide)
  final bool hideWhenDenied;

  const RBACGuard({
    super.key,
    required this.child,
    this.fallback,
    this.roles,
    this.permissionCheck,
    this.hideWhenDenied = true,
  }) : assert(roles != null || permissionCheck != null, 
              'Must provide either roles or permissionCheck');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final userRole = user?.role;
    
    bool hasPermission = false;
    
    if (permissionCheck != null) {
      hasPermission = permissionCheck!(userRole);
    } else if (roles != null) {
      hasPermission = roles!.contains(userRole);
    }
    
    if (hasPermission) {
      return child;
    }
    
    if (hideWhenDenied) {
      return const SizedBox.shrink();
    }
    
    return fallback ?? const SizedBox.shrink();
  }
}

/// RBAC Guard for multiple permission checks (user must pass ALL checks)
class RBACGuardAll extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;
  final List<bool Function(UserRole?)> checks;
  final bool hideWhenDenied;

  const RBACGuardAll({
    super.key,
    required this.child,
    this.fallback,
    required this.checks,
    this.hideWhenDenied = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final userRole = user?.role;
    
    final hasPermission = checks.every((check) => check(userRole));
    
    if (hasPermission) {
      return child;
    }
    
    if (hideWhenDenied) {
      return const SizedBox.shrink();
    }
    
    return fallback ?? const SizedBox.shrink();
  }
}

/// Convenience RBAC widgets for common permission checks

class CanCreateAlerts extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;
  
  const CanCreateAlerts({super.key, required this.child, this.fallback});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RBACGuard(
      permissionCheck: RoleUtils.canCreateAlerts,
      fallback: fallback,
      child: child,
    );
  }
}

class CanManageFarms extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;
  
  const CanManageFarms({super.key, required this.child, this.fallback});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RBACGuard(
      permissionCheck: RoleUtils.canManageFarms,
      fallback: fallback,
      child: child,
    );
  }
}

/// Farm mutations are deliberately narrower than farm visibility. Officers
/// may inspect farms in their jurisdiction, while only the owner, a DA, or an
/// administrator can edit or remove a plot.
class CanEditFarms extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;

  const CanEditFarms({super.key, required this.child, this.fallback});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RBACGuard(
      roles: const [
        UserRole.farmer,
        UserRole.developmentAgent,
        UserRole.admin,
      ],
      fallback: fallback,
      child: child,
    );
  }
}

class CanViewAnalytics extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;
  
  const CanViewAnalytics({super.key, required this.child, this.fallback});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RBACGuard(
      permissionCheck: RoleUtils.canViewAnalytics,
      fallback: fallback,
      child: child,
    );
  }
}

class CanRegisterSensors extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;
  
  const CanRegisterSensors({super.key, required this.child, this.fallback});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RBACGuard(
      permissionCheck: RoleUtils.canRegisterSensors,
      fallback: fallback,
      child: child,
    );
  }
}

class CanEditKebeleBoundary extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;
  
  const CanEditKebeleBoundary({super.key, required this.child, this.fallback});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RBACGuard(
      permissionCheck: RoleUtils.canEditKebeleBoundary,
      fallback: fallback,
      child: child,
    );
  }
}

class CanExportData extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;
  
  const CanExportData({super.key, required this.child, this.fallback});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RBACGuard(
      permissionCheck: RoleUtils.canExportData,
      fallback: fallback,
      child: child,
    );
  }
}

class OnlyFarmers extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;
  
  const OnlyFarmers({super.key, required this.child, this.fallback});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RBACGuard(
      roles: const [UserRole.farmer],
      fallback: fallback,
      child: child,
    );
  }
}

class OnlyOfficers extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;
  
  const OnlyOfficers({super.key, required this.child, this.fallback});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RBACGuard(
      roles: const [
        UserRole.woredaOfficer,
        UserRole.zonalOfficer,
        UserRole.regionalOfficer,
      ],
      fallback: fallback,
      child: child,
    );
  }
}

class OnlyAdmin extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;
  
  const OnlyAdmin({super.key, required this.child, this.fallback});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RBACGuard(
      roles: const [UserRole.admin],
      fallback: fallback,
      child: child,
    );
  }
}
