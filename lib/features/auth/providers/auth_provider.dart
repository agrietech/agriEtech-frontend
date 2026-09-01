import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user_model.dart';
import '../../../core/repositories/auth_repository.dart';
import '../../../core/services/notification_service.dart';
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

  // ── Role identity getters ──────────────────────────────────────────
  bool get isFarmer => user?.role == UserRole.farmer;
  bool get isDevelopmentAgent => user?.role == UserRole.developmentAgent;
  bool get isWoredaOfficer => user?.role == UserRole.woredaOfficer;
  bool get isZonalOfficer => user?.role == UserRole.zonalOfficer;
  bool get isRegionalOfficer => user?.role == UserRole.regionalOfficer;
  bool get isResearcher => user?.role == UserRole.researcher;
  bool get isAdmin => user?.role == UserRole.admin;

  // ── Composite role groups ──────────────────────────────────────────
  /// Any administrative officer (woreda, zonal, regional, or national admin)
  bool get isOfficer =>
      isWoredaOfficer || isZonalOfficer || isRegionalOfficer || isAdmin;

  /// Supervisory roles that oversee subordinate jurisdictions
  bool get isSupervisory =>
      isZonalOfficer || isRegionalOfficer || isAdmin;

  // ── Jurisdiction level ─────────────────────────────────────────────
  /// Returns the hierarchical jurisdiction scope for the authenticated user
  String get jurisdictionLevel {
    switch (user?.role) {
      case UserRole.farmer:
        return 'KEBELE';
      case UserRole.developmentAgent:
        return 'KEBELE';
      case UserRole.woredaOfficer:
        return 'WOREDA';
      case UserRole.zonalOfficer:
        return 'ZONE';
      case UserRole.regionalOfficer:
        return 'REGION';
      case UserRole.researcher:
        return 'NATIONAL';
      case UserRole.admin:
        return 'NATIONAL';
      default:
        return 'KEBELE';
    }
  }

  // ── Permission flags ───────────────────────────────────────────────
  bool get canCreateAlerts =>
      isWoredaOfficer || isZonalOfficer || isRegionalOfficer ||
      isDevelopmentAgent || isAdmin;

  bool get canAccessAllData => isResearcher || isAdmin;

  bool get canManageUsers => isAdmin;

  bool get canViewSystemHealth =>
      isWoredaOfficer || isZonalOfficer || isRegionalOfficer || isAdmin;

  bool get canViewAggregateData =>
      isZonalOfficer || isRegionalOfficer || isResearcher || isAdmin;

  bool get canManageSensors =>
      isDevelopmentAgent || isWoredaOfficer || isZonalOfficer ||
      isRegionalOfficer || isAdmin;

  bool get canExportData =>
      isResearcher || isZonalOfficer || isRegionalOfficer ||
      isWoredaOfficer || isAdmin;

  bool get canAccessUssdConsole =>
      isWoredaOfficer || isZonalOfficer || isRegionalOfficer || isAdmin;

  bool get hasWoredaAccess => user?.woredaId != null;
}

/// Authentication state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(AuthState(isInitializing: true)) {
    NotificationService().setTokenUpdateHandler(
      (token) => _authRepository.updateDeviceToken(token),
    );
    _checkAuthStatus();
  }

  /// Check authentication status on app start (supports full offline session persistence)
  Future<void> _checkAuthStatus() async {
    try {
      AppLogger.info('Checking authentication status');
      
      final isLoggedIn = await _authRepository.isLoggedIn();
      
      if (isLoggedIn) {
        AppLogger.info('User is logged in, checking local cached profile');
        final cachedUser = await _authRepository.getCachedUser();
        
        if (cachedUser != null) {
          // Immediately authenticate user with cached credentials (zero offline latency)
          state = state.copyWith(
            user: cachedUser,
            isAuthenticated: true,
            isInitializing: false,
          );
        }
        
        try {
          final user = await _authRepository.getProfile();
          state = state.copyWith(
            user: user,
            isAuthenticated: true,
            isInitializing: false,
          );
          AppLogger.info('Auth check complete - profile refreshed from network');
        } catch (e) {
          if (cachedUser != null) {
            // Keep user authenticated in offline mode
            AppLogger.info('Network unreachable, continuing in offline authenticated mode with cached profile');
            state = state.copyWith(
              user: cachedUser,
              isAuthenticated: true,
              isInitializing: false,
            );
          } else {
            AppLogger.warning('Failed to fetch profile and no cached user found', e);
            state = state.copyWith(
              isAuthenticated: false,
              isInitializing: false,
            );
          }
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

  /// Login with phone, email, or identifier and password
  Future<void> login(String credential, String password, {String? deviceToken}) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearLockout: true,
    );
    
    try {
      AppLogger.info('Login attempt for: $credential');
      final isEmail = credential.contains('@');
      
      final request = LoginRequest(
        email: isEmail ? credential : null,
        phone: !isEmail ? credential : null,
        identifier: credential,
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
        message: 'Login failed. Please verify your credentials and try again.',
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
    String? role,
    String? regionId,
    String? zoneId,
    String? woredaId,
    String? kebeleId,
    String? kebeleName,
    String? preferredLang,
    String? deviceToken,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      AppLogger.info('Registration attempt for phone: $phone with role: ${role ?? "FARMER"}');
      
      final request = RegisterRequest(
        phone: phone,
        password: password,
        fullName: fullName,
        email: email,
        role: role,
        regionId: regionId,
        zoneId: zoneId,
        woredaId: woredaId,
        kebeleId: kebeleId,
        kebeleName: kebeleName,
        preferredLang: preferredLang,
        deviceToken: deviceToken,
      );
      
      final response = await _authRepository.register(request);
      var hasToken = response.accessToken.isNotEmpty;
      UserModel user = response.user;

      // If registration succeeded on server but didn't return an auth token directly, auto-login seamlessly
      if (!hasToken) {
        try {
          final loginResponse = await _authRepository.login(
            LoginRequest(
              phone: phone,
              email: email,
              password: password,
              deviceToken: deviceToken,
            ),
          );
          user = loginResponse.user;
          hasToken = loginResponse.accessToken.isNotEmpty;
        } catch (loginErr) {
          AppLogger.warning('Auto-login after register did not complete: $loginErr');
        }
      }
      
      state = state.copyWith(
        user: user,
        isAuthenticated: hasToken,
        isLoading: false,
      );
      
      AppLogger.info('Registration successful (authenticated: $hasToken)');
    } on AuthError catch (e) {
      // If user already exists (e.g. created during a timeout or earlier attempt), attempt auto-login with provided credentials
      if (e.code == 'CONFLICT') {
        try {
          AppLogger.info('User already registered on backend, attempting auto-login...');
          final loginResponse = await _authRepository.login(
            LoginRequest(
              phone: phone,
              email: email,
              password: password,
              deviceToken: deviceToken,
            ),
          );
          state = state.copyWith(
            user: loginResponse.user,
            isAuthenticated: true,
            isLoading: false,
          );
          AppLogger.info('Auto-login succeeded after conflict recovery');
          return;
        } catch (loginErr) {
          AppLogger.warning('Auto-login failed after conflict, showing error: $loginErr');
        }
      }

      AppLogger.error('Registration failed', e);
      state = state.copyWith(
        isLoading: false,
        error: e,
      );
      rethrow;
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
        message: 'Registration failed. Please verify your information and try again.',
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
        message: 'Failed to update password. Please verify your current password and try again.',
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
