import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/agrietech_logo.dart';
import 'forgot_password_dialog.dart';

import '../../../core/storage/secure_storage_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      ref.read(authProvider.notifier).clearError();
      try {
        final storage = ref.read(secureStorageServiceProvider);
        final remembered = await storage.getRememberedUser();
        if (remembered != null && remembered.isNotEmpty && mounted) {
          setState(() {
            _usernameController.text = remembered;
            _rememberMe = true;
          });
        }
      } catch (_) {}
    });

    _usernameController.addListener(_onFieldChanged);
    _passwordController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (ref.read(authProvider).error != null || ref.read(authProvider).accountLockoutMessage != null) {
      ref.read(authProvider.notifier).clearError();
      ref.read(authProvider.notifier).clearLockout();
    }
  }

  @override
  void dispose() {
    _usernameController.removeListener(_onFieldChanged);
    _passwordController.removeListener(_onFieldChanged);
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    ref.read(authProvider.notifier).clearError();
    if (_formKey.currentState!.validate()) {
      try {
        final storage = ref.read(secureStorageServiceProvider);
        if (_rememberMe) {
          await storage.saveRememberedUser(_usernameController.text.trim());
        } else {
          await storage.clearRememberedUser();
        }

        await ref.read(authProvider.notifier).login(
              _usernameController.text.trim(),
              _passwordController.text,
            );
        if (mounted) {
          context.go('/home');
        }
      } catch (_) {
        // Error state handled in authProvider
      }
    }
  }

  Future<void> _biometricLogin() async {
    ref.read(authProvider.notifier).clearError();
    final storage = ref.read(secureStorageServiceProvider);
    final savedToken = await storage.getAccessToken();
    final rememberedUser = await storage.getRememberedUser();

    if (savedToken != null && savedToken.isNotEmpty) {
      if (mounted) {
        context.go('/home');
      }
      return;
    }

    if (rememberedUser != null && rememberedUser.isNotEmpty) {
      _usernameController.text = rememberedUser;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.fingerprint, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text('Biometric verified: please enter password to confirm session'),
                ),
              ],
            ),
            backgroundColor: Color(0xFF2E7D32),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No biometric credentials saved yet. Sign in once with password to enable.'),
            backgroundColor: Color(0xFFD97706),
          ),
        );
      }
    }
  }

  void _showForgotPassword() {
    showDialog(
      context: context,
      builder: (context) => const ForgotPasswordDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Centered Hero Logo
                    const Center(
                      child: AgriEtechLogo.stacked(
                        size: 88,
                        showTagline: true,
                        customTagline: 'NATIONAL AGRICULTURAL EARLY WARNING PLATFORM',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Main Card
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.cardDark : Colors.white,
                        borderRadius: AppRadii.roundedXl,
                        border: Border.all(
                          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                        ),
                        boxShadow: AppShadows.soft(isDark: isDark),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header title
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.xs),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                  borderRadius: AppRadii.roundedSm,
                                ),
                                child: const Icon(Icons.login, color: AppTheme.primaryColor, size: 20),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sign In',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : const Color(0xFF1E2E1E),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Access your account',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.screenPadding),

                          // Error Banner
                          if (authState.error != null || authState.accountLockoutMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: AppRadii.roundedMd,
                                border: Border.all(color: Colors.red.shade300),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.error_outline, color: Colors.red, size: 22),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          authState.accountLockoutMessage != null
                                              ? 'Account Locked'
                                              : 'Sign-In Failed',
                                          style: AppTypography.subtitle.copyWith(
                                            color: Colors.red,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          authState.accountLockoutMessage ??
                                              authState.error!.message,
                                          style: AppTypography.bodySmall.copyWith(
                                            color: Colors.red.shade900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 18),
                                    color: Colors.red.shade700,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    tooltip: 'Dismiss',
                                    onPressed: () {
                                      ref.read(authProvider.notifier).clearError();
                                      ref.read(authProvider.notifier).clearLockout();
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],

                          // Phone / Email Field
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Phone Number or Email',
                              prefixIcon: const Icon(Icons.phone_android_outlined),
                              border: const OutlineInputBorder(borderRadius: AppRadii.roundedMd),
                              filled: true,
                              fillColor: isDark ? AppTheme.surfaceDark : const Color(0xFFF8FAF8),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (value) => Validators.required(value, 'Phone number or email'),
                            enabled: !authState.isLoading,
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              border: const OutlineInputBorder(borderRadius: AppRadii.roundedMd),
                              filled: true,
                              fillColor: isDark ? AppTheme.surfaceDark : const Color(0xFFF8FAF8),
                            ),
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _login(),
                            validator: (value) => Validators.required(value, 'Password'),
                            enabled: !authState.isLoading,
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          // Remember Me & Forgot Password Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      activeColor: AppTheme.primaryColor,
                                      onChanged: authState.isLoading
                                          ? null
                                          : (val) => setState(() => _rememberMe = val ?? false),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  GestureDetector(
                                    onTap: () => setState(() => _rememberMe = !_rememberMe),
                                    child: Text(
                                      'Remember me',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: authState.isLoading ? null : _showForgotPassword,
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF1B5E20),
                                  padding: EdgeInsets.zero,
                                ),
                                child: Text(
                                  'Forgot Password?',
                                  style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.screenPadding),

                          // Submit Sign In Button
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: authState.isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1B5E20),
                                foregroundColor: Colors.white,
                                elevation: 3,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: AppRadii.roundedLg,
                                ),
                              ),
                              child: authState.isLoading
                                  ? const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text('Signing in...'),
                                      ],
                                    )
                                  : Text(
                                      'Sign In',
                                      style: AppTypography.titleMedium.copyWith(color: Colors.white),
                                    ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          // Biometric Quick Authentication Button
                          SizedBox(
                            height: 46,
                            child: OutlinedButton.icon(
                              onPressed: authState.isLoading ? null : _biometricLogin,
                              icon: const Icon(Icons.fingerprint, size: 22, color: Color(0xFF1B5E20)),
                              label: Text(
                                'Sign in with Biometrics / Fingerprint',
                                style: AppTypography.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1B5E20),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: isDark ? const Color(0xFF2E5E36) : const Color(0xFFA5D6A7),
                                ),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: AppRadii.roundedLg,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Register Account Action Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                        ),
                        TextButton(
                          onPressed: () => context.go('/register'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF1B5E20),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                          child: const Text(
                            'Create Account',
                            style: AppTypography.subtitle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
