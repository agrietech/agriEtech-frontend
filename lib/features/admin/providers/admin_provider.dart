import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user_model.dart';
import '../../../core/utils/logger.dart';
import '../models/role_application_model.dart';
import '../repositories/admin_repository.dart';

class AdminUsersState {
  final List<UserModel> users;
  final List<RoleApplicationModel> pendingApplications;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final String? selectedRoleFilter;

  const AdminUsersState({
    this.users = const [],
    this.pendingApplications = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.selectedRoleFilter,
  });

  AdminUsersState copyWith({
    List<UserModel>? users,
    List<RoleApplicationModel>? pendingApplications,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? searchQuery,
    String? selectedRoleFilter,
    bool clearRoleFilter = false,
  }) {
    return AdminUsersState(
      users: users ?? this.users,
      pendingApplications: pendingApplications ?? this.pendingApplications,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      searchQuery: searchQuery ?? this.searchQuery,
      selectedRoleFilter: clearRoleFilter ? null : (selectedRoleFilter ?? this.selectedRoleFilter),
    );
  }
}

class AdminUsersNotifier extends StateNotifier<AdminUsersState> {
  final AdminRepository _repository;

  AdminUsersNotifier(this._repository) : super(const AdminUsersState()) {
    loadData();
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final users = await _repository.getUsers(
        search: state.searchQuery,
        role: state.selectedRoleFilter,
      );
      final pending = await _repository.getPendingRoleApplications();
      state = state.copyWith(
        users: users,
        pendingApplications: pending,
        isLoading: false,
      );
    } catch (e) {
      AppLogger.error('Failed to load admin users data', e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load user management data',
      );
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadData();
  }

  void setRoleFilter(String? role) {
    state = state.copyWith(
      selectedRoleFilter: role,
      clearRoleFilter: role == null,
    );
    loadData();
  }

  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      await _repository.updateUserRole(userId, newRole);
      // Update local state list
      final updatedUsers = state.users.map((u) {
        if (u.id == userId) {
          return u.copyWith(role: UserRole.fromString(newRole));
        }
        return u;
      }).toList();

      state = state.copyWith(users: updatedUsers);
    } catch (e) {
      AppLogger.error('Failed to update user role', e);
      rethrow;
    }
  }

  Future<void> approveApplication(String applicationId, {required String reviewerName}) async {
    try {
      await _repository.approveRoleApplication(applicationId, reviewerName: reviewerName);
      await loadData();
    } catch (e) {
      AppLogger.error('Failed to approve application', e);
      rethrow;
    }
  }

  Future<void> rejectApplication(String applicationId, {required String reason, required String reviewerName}) async {
    try {
      await _repository.rejectRoleApplication(applicationId, reason: reason, reviewerName: reviewerName);
      await loadData();
    } catch (e) {
      AppLogger.error('Failed to reject application', e);
      rethrow;
    }
  }
}

final adminUsersProvider = StateNotifierProvider<AdminUsersNotifier, AdminUsersState>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return AdminUsersNotifier(repository);
});
