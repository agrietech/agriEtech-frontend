import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user_model.dart';
import '../../../core/repositories/auth_repository.dart';
import '../../../core/error/app_error.dart';
import '../../../core/utils/logger.dart';

/// Authentication state
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final bool isInitializing;
  final AppError? error;
  final bool isAuthenticated;
  final String? accountLockoutMessage;

  AuthState({
    this.user,
    this.isLoading = false,
    this.isInitializing = false,
    this.error,
    this.isAuthenticated = false,
    this.accountLockoutMessage,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    bool? isInitializing,
    AppError? error,
    bool clearError = false,
    bool? isAuthenticated,
    String? accountLockoutMessage,
    bool clearLockout = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isInitializing: isInitializing ?? this.isInitializing,
      error: clearError ? null : (error ?? this.error),
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      accountLockoutMessage: clearLockout 
          ? null 
          : (accountLockoutMessage ?? this.accountLockoutMessage),
    );
  }

  bool get isFarmer => user?.role == UserRole.farmer;
  bool get isDevelopmentAgent => user?.role == UserRole.developmentAgent;
  bool get isWoredaOfficer => user?.role == UserRole.woredaOfficer;
  bool get isResearcher => user?.role == UserRole.researcher;
  bool get isAdmin => user?.role == UserRole.admin;

  bool get canCreateAlerts =>
      isWoredaOfficer || isDevelopmentAgent || isAdmin;
  
  bool get canAccessAllData => isResearcher || isAdmin;
  
  bool get hasWoredaAccess => user?.woredaId != null;
}

/// Authentication state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(AuthState(isInitializing: true)) {
    _checkAuthStatus();
  }

  /// Check authentication status on app start
  Future<void> _checkAuthStatus() async {
    try {
      AppLogger.info('Checking authentication status');
      
      final isLoggedIn = await _authRepository.isLoggedIn();
      
      if (isLoggedIn) {
        AppLogger.info('User is logged in, fetching profile');
        
        try {
          final user = await _authRepository.getProfile();
          state = state.copyWith(
            user: user,
            isAuthenticated: true,
            isInitializing: false,
          );
          
          AppLogger.info('Auth check complete - authenticated');
        } catch (e) {
          // Token might be expired
          AppLogger.warning('Failed to fetch profile, user not authenticated', e);
          
          state = state.copyWith(
            isAuthenticated: false,
            isInitializing: false,
          );
        }
      } else {
        AppLogger.info('Auth check complete - not authenticated');
        state = state.copyWith(
          isAuthenticated: false,
          isInitializing: false,
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error('Auth status check failed', e, stackTrace);
      
      state = state.copyWith(
        isAuthenticated: false,
        isInitializing: false,
      );
    }
  }

  /// Login with phone and password
  Future<void> login(String phone, String password, {String? deviceToken}) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearLockout: true,
    );
    
    try {
      AppLogger.info('Login attempt for phone: $phone');
      
      final request = LoginRequest(
        phone: phone,
        password: password,
        deviceToken: deviceToken,
      );
      
      final response = await _authRepository.login(request);
      
      state = state.copyWith(
        user: response.user,
        isAuthenticated: true,
        isLoading: false,
      );
      
      // Send FCM token to backend if available
      if (deviceToken != null && deviceToken.isNotEmpty) {
        try {
          await _authRepository.updateDeviceToken(deviceToken);
          AppLogger.info('Device token sent to backend');
        } catch (e) {
          AppLogger.warning('Failed to send device token', e);
          // Non-critical, don't fail login
        }
      }
      
      AppLogger.info('Login successful');
    } on AuthError catch (e) {
      AppLogger.error('Login failed - Auth error', e);
      
      // Handle account lockout specifically
      if (e.code == 'ACCOUNT_LOCKED') {
        state = state.copyWith(
          isLoading: false,
          error: e,
          accountLockoutMessage: e.message,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: e,
        );
      }
      
      rethrow;
    } on AppError catch (e) {
      AppLogger.error('Login failed - App error', e);
      
      state = state.copyWith(
        isLoading: false,
        error: e,
      );
      
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error('Login failed - Unknown error', e, stackTrace);
      
      final error = UnknownError(
        message: 'Login failed. Please try again.',
        details: e,
      );
      
      state = state.copyWith(
        isLoading: false,
        error: error,
      );
      
      throw error;
    }
  }

  /// Register new user
  Future<void> register({
    required String phone,
    required String password,
    required String fullName,
    String? email,
    String? woredaId,
    String? preferredLang,
    String? deviceToken,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      AppLogger.info('Registration attempt for phone: $phone');
      
      final request = RegisterRequest(
        phone: phone,
        password: password,
        fullName: fullName,
        email: email,
        woredaId: woredaId,
        preferredLang: preferredLang,
        deviceToken: deviceToken,
      );
      
      final response = await _authRepository.register(request);
      
      state = state.copyWith(
        user: response.user,
        isAuthenticated: true,
        isLoading: false,
      );
      
      AppLogger.info('Registration successful');
    } on AppError catch (e) {
      AppLogger.error('Registration failed', e);
      
      state = state.copyWith(
        isLoading: false,
        error: e,
      );
      
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error('Registration failed - Unknown error', e, stackTrace);
      
      final error = UnknownError(
        message: 'Registration failed. Please try again.',
        details: e,
      );
      
      state = state.copyWith(
        isLoading: false,
        error: error,
      );
      
      throw error;
    }
  }

  /// Update user password
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      AppLogger.info('Password update attempt');
      
      final request = UpdatePasswordRequest(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      
      await _authRepository.updatePassword(request);
      
      state = state.copyWith(isLoading: false);
      
      AppLogger.info('Password updated successfully');
    } on AppError catch (e) {
      AppLogger.error('Password update failed', e);
      
      state = state.copyWith(
        isLoading: false,
        error: e,
      );
      
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error('Password update failed - Unknown error', e, stackTrace);
      
      final error = UnknownError(
        message: 'Failed to update password. Please try again.',
        details: e,
      );
      
      state = state.copyWith(
        isLoading: false,
        error: error,
      );
      
      throw error;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    
    try {
      AppLogger.info('Logout attempt');
      
      await _authRepository.logout();
      
      state = AuthState();
      
      AppLogger.info('Logout successful');
    } catch (e, stackTrace) {
      AppLogger.error('Logout failed', e, stackTrace);
      
      // Even if logout fails on server, clear local state
      state = AuthState(
        error: UnknownError(
          message: 'Logout completed with errors',
          details: e,
        ),
      );
    }
  }

  /// Refresh user profile
  Future<void> refreshProfile() async {
    if (!state.isAuthenticated) return;
    
    try {
      AppLogger.info('Refreshing user profile');
      
      final user = await _authRepository.getProfile();
      
      state = state.copyWith(user: user);
      
      AppLogger.info('Profile refreshed successfully');
    } catch (e) {
      AppLogger.warning('Profile refresh failed', e);
      // Don't update state on error - keep existing profile
    }
  }

  /// Save device token for push notifications
  Future<void> saveDeviceToken(String token) async {
    try {
      await _authRepository.saveDeviceToken(token);
      AppLogger.info('Device token saved');
    } catch (e) {
      AppLogger.warning('Failed to save device token', e);
      // Non-critical, don't throw
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Clear account lockout message
  void clearLockout() {
    state = state.copyWith(clearLockout: true);
  }
}

/// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});

/// Current user provider (convenience)
final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user;
});
