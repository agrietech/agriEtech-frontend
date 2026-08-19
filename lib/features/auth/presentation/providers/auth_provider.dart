///
/// @file auth_provider.dart
/// @feature auth
/// @description Riverpod StateNotifier for email-based authentication.
/// Supports: email login, phone login, register, forgot password, reset password.
///
library auth_provider;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/repositories/auth_repository.dart';
import '../../../../core/utils/logger.dart';

class AuthState {
  final UserModel? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
  }) =>
      AuthState(
        user: user ?? this.user,
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  AuthNotifier(this._repo) : super(const AuthState());

  /// Login with email or phone + password
  Future<bool> login({required String identifier, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Detect if identifier is email or phone
      final bool isEmail = identifier.contains('@');
      final request = isEmail
          ? LoginRequest(email: identifier, phone: '', password: password)
          : LoginRequest(phone: identifier, password: password);

      final response = await _repo.login(request);
      state = state.copyWith(
        user: response.user,
        isAuthenticated: true,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Register new user with email authentication
  Future<bool> register({
    required String fullName,
    required String password,
    String? email,
    String? phone,
    String? woredaId,
    String preferredLang = 'am',
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final request = RegisterRequest(
        fullName: fullName,
        password: password,
        email: email,
        phone: phone ?? '',
        woredaId: woredaId,
        preferredLang: preferredLang,
      );
      final response = await _repo.register(request);
      state = state.copyWith(
        user: response.user,
        isAuthenticated: true,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Send forgot password email
  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.requestPasswordReset(email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Reset password with token from email link
  Future<bool> resetPassword({required String token, required String newPassword}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.resetPassword(token: token, newPassword: newPassword);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> loadProfile() async {
    try {
      final user = await _repo.getProfile();
      state = state.copyWith(user: user, isAuthenticated: true);
    } catch (e) {
      AppLogger.warning('Profile load failed: $e');
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

/// Convenience provider for current user
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});
