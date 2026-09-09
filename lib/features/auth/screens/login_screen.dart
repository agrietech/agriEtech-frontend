import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/agrietech_logo.dart';
import 'forgot_password_dialog.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/l10n/app_localizations.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  late TabController _tabController;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  // SMS OTP Flow State
  bool _otpSent = false;
  int _resendCountdown = 60;
  Timer? _countdownTimer;
  bool _isRequestingOtp = false;

  // Detected Ethiopian carrier
  String? _detectedCarrier;

  static const List<Map<String, String>> _demoAccounts = [
    {
      'role': 'FARMER',
      'label': 'Smallholder Farmer (አርሶ አደር)',
      'phone': '0911223344',
      'pass': 'FarmerPass123!',
      'badge': '🌾 Smallholder',
    },
    {
      'role': 'DEVELOPMENT_AGENT',
      'label': 'Development Agent (የልማት ጣቢያ)',
      'phone': '0922334455',
      'pass': 'AgentPass123!',
      'badge': '🧑‍🌾 DA / Kebele',
    },
    {
      'role': 'WOREDA_OFFICER',
      'label': 'Woreda Agronomy Officer (የወረዳ መኮንን)',
      'phone': '0933445566',
      'pass': 'WoredaPass123!',
      'badge': '🏛️ Woreda Lead',
    },
    {
      'role': 'RESEARCHER',
      'label': 'Agricultural Scientist (ተመራማሪ)',
      'phone': '0944556677',
      'pass': 'ScientistPass123!',
      'badge': '🔬 EIAR / Researcher',
    },
    {
      'role': 'ADMIN',
      'label': 'National Administrator (ዋና አስተዳዳሪ)',
      'phone': '0900000001',
      'pass': 'AdminPass123!',
      'badge': '🛡️ National Admin',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });

    Future.microtask(() async {
      ref.read(authProvider.notifier).clearError();
      try {
        final storage = ref.read(secureStorageServiceProvider);
        final remembered = await storage.getRememberedUser();
        if (remembered != null && remembered.isNotEmpty && mounted) {
          setState(() {
            _phoneController.text = remembered;
            _rememberMe = true;
            _detectCarrier(remembered);
          });
        }
      } catch (_) {}
    });

    _phoneController.addListener(_onPhoneChanged);
    _passwordController.addListener(_onFieldChanged);
  }

  void _onPhoneChanged() {
    _detectCarrier(_phoneController.text);
    _onFieldChanged();
  }

  void _detectCarrier(String raw) {
    final clean = raw.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    String? carrier;
    if (clean.startsWith('09') || clean.startsWith('9') || clean.startsWith('+2519') || clean.startsWith('2519')) {
      carrier = 'Ethio Telecom (ኢትዮ ቴሌኮም)';
    } else if (clean.startsWith('07') || clean.startsWith('7') || clean.startsWith('+2517') || clean.startsWith('2517')) {
      carrier = 'Safaricom Ethiopia (ሳፋሪኮም)';
    }
    if (carrier != _detectedCarrier && mounted) {
      setState(() => _detectedCarrier = carrier);
    }
  }

  void _onFieldChanged() {
    if (ref.read(authProvider).error != null || ref.read(authProvider).accountLockoutMessage != null) {
      ref.read(authProvider.notifier).clearError();
      ref.read(authProvider.notifier).clearLockout();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _tabController.dispose();
    _phoneController.removeListener(_onPhoneChanged);
    _passwordController.removeListener(_onFieldChanged);
    _phoneController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _resendCountdown = 60);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCountdown <= 1) {
        timer.cancel();
        setState(() => _resendCountdown = 0);
      } else {
        setState(() => _resendCountdown--);
      }
    });
  }

  Future<void> _loginWithPassword() async {
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
        // Error handled via authProvider
      }
    }
  }

  Future<void> _requestOtp() async {
    final phoneErr = Validators.phone(_phoneController.text);
    if (phoneErr != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(phoneErr),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isRequestingOtp = true);
    try {
      await ref.read(authProvider.notifier).requestLoginOtp(_phoneController.text.trim());
      setState(() {
        _isRequestingOtp = false;
        _otpSent = true;
      });
      _startCountdown();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.mark_email_read_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('6-digit login OTP dispatched to ${_phoneController.text.trim()}'),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF1B5E20),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _isRequestingOtp = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to request OTP: ${e.toString()}'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _verifyOtpAndLogin() async {
    final code = _otpController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the full 6-digit verification code'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      await ref.read(authProvider.notifier).verifyLoginOtp(
            phone: _phoneController.text.trim(),
            code: code,
          );
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      // Error handled via provider
    }
  }

  Future<void> _biometricLogin() async {
    ref.read(authProvider.notifier).clearError();
    final storage = ref.read(secureStorageServiceProvider);
    final savedToken = await storage.getAccessToken();
    final rememberedUser = await storage.getRememberedUser();

    if (savedToken != null && savedToken.isNotEmpty) {
      if (mounted) context.go('/home');
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

  void _showDemoAccountsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF132116) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(
                color: isDark ? const Color(0xFF223826) : const Color(0xFFE5E9E5),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.flash_on_rounded, color: Color(0xFFF59E0B), size: 22),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Select Enterprise Role for Testing',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Instantly fill verified credentials to evaluate role-specific capabilities:',
                  style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12.5),
                ),
                const SizedBox(height: 16),
                ..._demoAccounts.map((acc) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 0,
                    color: isDark ? const Color(0xFF0E1A11) : const Color(0xFFF9FAFB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isDark ? const Color(0xFF26382A) : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      title: Text(
                        acc['label']!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                      ),
                      subtitle: Text(
                        'Phone: ${acc['phone']} • Role: ${acc['role']}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 11.5),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B5E20).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          acc['badge']!,
                          style: const TextStyle(
                            color: Color(0xFF1B5E20),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _phoneController.text = acc['phone']!;
                          _passwordController.text = acc['pass']!;
                          _rememberMe = true;
                          _tabController.index = 0;
                        });
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Autofilled ${acc['label']} credentials'),
                            backgroundColor: const Color(0xFF1B5E20),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final currentLang = ref.watch(appLocaleProvider);
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
              constraints: const BoxConstraints(maxWidth: 460),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top Utility Bar: Language Selector & Quick Role Switcher
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Demo Role Switcher
                          InkWell(
                            key: const Key('demo_accounts_button'),
                            onTap: _showDemoAccountsModal,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.bolt_rounded, size: 14, color: Color(0xFFD97706)),
                                  SizedBox(width: 4),
                                  Text(
                                    'Demo Roles',
                                    style: TextStyle(
                                      color: Color(0xFFD97706),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Language Selector
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1B2E1E) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark ? const Color(0xFF2E4A33) : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildLangPill('en', 'EN', currentLang == 'en'),
                                const SizedBox(width: 4),
                                _buildLangPill('am', 'አማ', currentLang == 'am'),
                                const SizedBox(width: 4),
                                _buildLangPill('om', 'ORO', currentLang == 'om'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Brand Logo
                      const Center(
                        child: EthioFarmLogo.stacked(
                          size: 78,
                          showTagline: false,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Auth Surface Card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF132116) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? const Color(0xFF223826) : const Color(0xFFE5E9E5),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header
                            Text(
                              'Agricultural Command Access',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                                color: isDark ? Colors.white : const Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Sign in to your verified agricultural intelligence workspace',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Dual Authentication Mode Tabs
                            Container(
                              height: 42,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0E1A11) : const Color(0xFFF1F5F1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: TabBar(
                                controller: _tabController,
                                indicator: BoxDecoration(
                                  color: const Color(0xFF1B5E20),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                labelColor: Colors.white,
                                unselectedLabelColor: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                                indicatorSize: TabBarIndicatorSize.tab,
                                tabs: const [
                                  Tab(
                                    key: Key('tab_password_login'),
                                    iconMargin: EdgeInsets.zero,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.lock_rounded, size: 14),
                                        SizedBox(width: 6),
                                        Text('Password'),
                                      ],
                                    ),
                                  ),
                                  Tab(
                                    key: Key('tab_otp_login'),
                                    iconMargin: EdgeInsets.zero,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.sms_rounded, size: 14),
                                        SizedBox(width: 6),
                                        Text('SMS OTP'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),

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

                            // Mobile Phone Field (Shared by both tabs)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: _buildFieldLabel('Mobile phone number', isDark, isRequired: true),
                                ),
                                if (_detectedCarrier != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1B5E20).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      _detectedCarrier!,
                                      style: const TextStyle(
                                        color: Color(0xFF1B5E20),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            TextFormField(
                              key: const Key('phone_field'),
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              textInputAction: _tabController.index == 0 ? TextInputAction.next : TextInputAction.done,
                              enabled: !authState.isLoading && !_isRequestingOtp,
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
                                contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
                              ),
                              validator: (value) => Validators.phone(value),
                            ),
                            const SizedBox(height: 14),

                            // TAB 0: Password Flow
                            if (_tabController.index == 0) ...[
                              _buildFieldLabel('Password', isDark, isRequired: true),
                              TextFormField(
                                key: const Key('password_field'),
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [AutofillHints.password],
                                enabled: !authState.isLoading,
                                onFieldSubmitted: (_) => _loginWithPassword(),
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
                                  contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                              ),
                              Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                runSpacing: 6,
                                children: [
                                  InkWell(
                                    onTap: authState.isLoading ? null : () => setState(() => _rememberMe = !_rememberMe),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
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
                                  ),
                                  InkWell(
                                    onTap: authState.isLoading ? null : () => ForgotPasswordDialog.show(context),
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
                              const SizedBox(height: 20),

                              // Action Buttons: Sign In & Biometrics
                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 48,
                                      child: ElevatedButton(
                                        key: const Key('sign_in_button'),
                                        onPressed: authState.isLoading ? null : _loginWithPassword,
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

                            // TAB 1: SMS OTP Flow
                            if (_tabController.index == 1) ...[
                              if (!_otpSent) ...[
                                const Text(
                                  'A 6-digit one-time code will be dispatched via Ethio Telecom SMS to your mobile.',
                                  style: TextStyle(fontSize: 12.5, color: Colors.grey),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 48,
                                  child: ElevatedButton.icon(
                                    onPressed: _isRequestingOtp ? null : _requestOtp,
                                    icon: _isRequestingOtp
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                          )
                                        : const Icon(Icons.send_to_mobile_rounded, size: 18),
                                    label: const Text('Send SMS Login Code'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1B5E20),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                              ] else ...[
                                _buildFieldLabel('Enter 6-Digit SMS Code', isDark, isRequired: true),
                                TextFormField(
                                  key: const Key('otp_field'),
                                  controller: _otpController,
                                  keyboardType: TextInputType.number,
                                  maxLength: 6,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 8),
                                  decoration: InputDecoration(
                                    hintText: '••••••',
                                    counterText: '',
                                    filled: true,
                                    fillColor: isDark ? const Color(0xFF0E1A11) : const Color(0xFFF9FAFB),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _resendCountdown > 0
                                          ? 'Resend code in ${_resendCountdown}s'
                                          : 'Didn\'t receive code?',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                    if (_resendCountdown == 0)
                                      InkWell(
                                        onTap: _requestOtp,
                                        child: const Text(
                                          'Resend SMS',
                                          style: TextStyle(
                                            color: Color(0xFF1B5E20),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    key: const Key('verify_otp_button'),
                                    onPressed: authState.isLoading ? null : _verifyOtpAndLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1B5E20),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    child: authState.isLoading
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                          )
                                        : const Text('Verify & Enter Platform', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Sign Up Invitation
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'New to EthioFarm? ',
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

  Widget _buildLangPill(String code, String label, bool isSelected) {
    return InkWell(
      onTap: () => ref.read(appLocaleProvider.notifier).state = code,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1B5E20) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, bool isDark, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text.rich(
        TextSpan(
          text: label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF374151),
          ),
          children: isRequired
              ? const [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: Color(0xFFDC2626),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}
