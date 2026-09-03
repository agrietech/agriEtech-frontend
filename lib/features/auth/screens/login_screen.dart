import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
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
  final _phoneController = TextEditingController();
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
            _phoneController.text = remembered;
            _rememberMe = true;
          });
        }
      } catch (_) {}
    });

    _phoneController.addListener(_onFieldChanged);
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
    _phoneController.removeListener(_onFieldChanged);
    _passwordController.removeListener(_onFieldChanged);
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    ref.read(authProvider.notifier).clearError();
    if (_formKey.currentState!.validate()) {
      final rawInput = _phoneController.text.trim();
      final storage = ref.read(secureStorageServiceProvider);
      if (_rememberMe) {
        await storage.saveRememberedUser(rawInput);
      } else {
        await storage.clearRememberedUser();
      }

      try {
        await ref.read(authProvider.notifier).login(
              rawInput,
              _passwordController.text,
            );
        if (mounted) {
          context.go('/home');
        }
      } catch (_) {
        // Error state displayed via authProvider
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
      _phoneController.text = rememberedUser;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.fingerprint, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text('Biometric credential not yet linked. Please sign in with password first.'),
              ),
            ],
          ),
          backgroundColor: Color(0xFF1B5E20),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B130E) : const Color(0xFFF7F9F7),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? const [Color(0xFF0F1E13), Color(0xFF08100A)]
                  : const [Color(0xFFF7FAF7), Color(0xFFEEF3EE)],
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Focused Brand Logo
                      const Center(
                        child: AgriEtechLogo.stacked(
                          size: 80,
                          showTagline: false,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Minimalist Form Surface Card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 28),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF132116) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark ? const Color(0xFF223826) : const Color(0xFFE5E9E5),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Clean Header
                            Text(
                              'Welcome back',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.6,
                                color: isDark ? Colors.white : const Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 22),

                            // Error Alert Banner
                            if (authState.error != null || authState.accountLockoutMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFFCA5A5)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 18),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            authState.accountLockoutMessage != null
                                                ? 'Account Locked'
                                                : 'Authentication Failed',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                              color: Color(0xFF991B1B),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            authState.accountLockoutMessage ?? authState.error!.message,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFFB91C1C),
                                              height: 1.35,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        ref.read(authProvider.notifier).clearError();
                                        ref.read(authProvider.notifier).clearLockout();
                                      },
                                      child: const Icon(Icons.close, size: 16, color: Color(0xFFDC2626)),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Mobile Number
                            _buildFieldLabel('Mobile phone number', isDark),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.telephoneNumber],
                              enabled: !authState.isLoading,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                                color: isDark ? Colors.white : const Color(0xFF111827),
                              ),
                              decoration: InputDecoration(
                                hintText: '911 234 567',
                                hintStyle: TextStyle(
                                  color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),
                                prefixIcon: Container(
                                  margin: const EdgeInsets.only(left: 10, right: 10),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.phone_outlined, size: 18, color: Color(0xFF1B5E20)),
                                      const SizedBox(width: 8),
                                      Text(
                                        '+251',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13.5,
                                          color: isDark ? const Color(0xFFA7F3D0) : const Color(0xFF1B5E20),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 1,
                                        height: 18,
                                        color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                                      ),
                                    ],
                                  ),
                                ),
                                prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                                filled: true,
                                fillColor: isDark ? const Color(0xFF0E1A11) : const Color(0xFFF9FAFB),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: isDark ? const Color(0xFF374151) : const Color(0xFFD1D5DB),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: isDark ? const Color(0xFF26382A) : const Color(0xFFE5E7EB),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color(0xFF1B5E20), width: 1.5),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color(0xFFDC2626)),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
                              ),
                              validator: (value) => Validators.phone(value),
                            ),
                            const SizedBox(height: 16),

                            // Password
                            _buildFieldLabel('Password', isDark),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                              enabled: !authState.isLoading,
                              onFieldSubmitted: (_) => _login(),
                              style: TextStyle(
                                fontSize: 14.5,
                                letterSpacing: _obscurePassword ? 2.0 : 0.0,
                                color: isDark ? Colors.white : const Color(0xFF111827),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter your password',
                                hintStyle: TextStyle(
                                  color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                                  fontSize: 14,
                                  letterSpacing: 0,
                                ),
                                prefixIcon: const Icon(Icons.lock_outline, size: 18),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    size: 18,
                                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                                filled: true,
                                fillColor: isDark ? const Color(0xFF0E1A11) : const Color(0xFFF9FAFB),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: isDark ? const Color(0xFF374151) : const Color(0xFFD1D5DB),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: isDark ? const Color(0xFF26382A) : const Color(0xFFE5E7EB),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color(0xFF1B5E20), width: 1.5),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color(0xFFDC2626)),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            // Remember Me & Forgot Password
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        activeColor: const Color(0xFF1B5E20),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                                        onChanged: authState.isLoading
                                            ? null
                                            : (val) => setState(() => _rememberMe = val ?? false),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Remember me',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF374151),
                                      ),
                                    ),
                                  ],
                                ),
                                InkWell(
                                  onTap: authState.isLoading
                                      ? null
                                      : () => ForgotPasswordDialog.show(context),
                                  child: const Text(
                                    'Forgot password?',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1B5E20),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 22),

                            // Action Buttons: Sign In & Biometrics
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: authState.isLoading ? null : _login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF1B5E20),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: authState.isLoading
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.0,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : const Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Sign in',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                    letterSpacing: 0.2,
                                                  ),
                                                ),
                                                SizedBox(width: 6),
                                                Icon(Icons.arrow_forward_rounded, size: 16),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  height: 48,
                                  width: 48,
                                  child: OutlinedButton(
                                    onPressed: authState.isLoading ? null : _biometricLogin,
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      side: BorderSide(
                                        color: isDark ? const Color(0xFF26382A) : const Color(0xFFE5E7EB),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.fingerprint_rounded,
                                      size: 24,
                                      color: Color(0xFF1B5E20),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Sign Up Invitation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'New to AgriEtech? ',
                            style: TextStyle(
                              fontSize: 13.5,
                              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                            ),
                          ),
                          InkWell(
                            onTap: authState.isLoading ? null : () => context.go('/register'),
                            child: const Text(
                              'Create an account',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1B5E20),
                              ),
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
      ),
    );
  }

  Widget _buildFieldLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF374151),
        ),
      ),
    );
  }
}
