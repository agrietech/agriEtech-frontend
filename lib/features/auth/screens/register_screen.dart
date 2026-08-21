import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../core/error/error_handler.dart';
import '../../../core/error/app_error.dart';
import '../../../core/widgets/agrietech_logo.dart';
import '../../boundaries/providers/boundary_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedLanguage = 'en';
  bool _acceptTerms = false;
  bool _termsError = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(boundaryHierarchyProvider.notifier).loadRegions();
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    ref.read(authProvider.notifier).clearError();
    final hierarchy = ref.read(boundaryHierarchyProvider);

    if (!_acceptTerms) {
      setState(() => _termsError = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms of Service & Privacy Policy to proceed'),
          backgroundColor: Color(0xFFD97706),
        ),
      );
      return;
    } else {
      setState(() => _termsError = false);
    }

    if (_formKey.currentState!.validate()) {
      try {
        await ref.read(authProvider.notifier).register(
              phone: _phoneController.text.trim(),
              password: _passwordController.text,
              fullName: _fullNameController.text.trim(),
              email: _emailController.text.trim(),
              preferredLang: _selectedLanguage,
              woredaId: hierarchy.selectedWoreda?.id,
            );

        if (mounted) {
          final isAuth = ref.read(authProvider).isAuthenticated;
          if (isAuth) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Account created successfully! Welcome to agriEtech.',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Color(0xFF2E7D32),
                duration: Duration(seconds: 4),
              ),
            );
            context.go('/home');
          } else {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: const Row(
                  children: [
                    Icon(Icons.mark_email_read_outlined, color: Color(0xFF2E7D32), size: 28),
                    SizedBox(width: 10),
                    Text('Account Created', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                content: Text(
                  'Your account has been registered successfully! A confirmation notice has been sent to ${_emailController.text.trim()}. You can now sign in.',
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
                actions: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      context.go('/login');
                    },
                    icon: const Icon(Icons.login, size: 18),
                    label: const Text('Proceed to Sign In'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            );
          }
        }
      } on ValidationError catch (e) {
        if (mounted) {
          if (e.fieldErrors != null) {
            final errorMessage = e.fieldErrors!.entries
                .map((entry) => '• ${entry.key}: ${entry.value.join(", ")}')
                .join('\n');

            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: const Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Validation Error'),
                  ],
                ),
                content: Text(errorMessage),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          } else {
            ErrorHandler.showErrorSnackBar(context, e);
          }
        }
      } on AppError catch (e) {
        if (mounted) {
          ErrorHandler.showErrorSnackBar(context, e);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final hierarchy = ref.watch(boundaryHierarchyProvider);
    final hierarchyNotifier = ref.read(boundaryHierarchyProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121E14) : const Color(0xFFF7FAF7),
      appBar: AppBar(
        title: const Text('Account Registration', style: TextStyle(fontWeight: FontWeight.w700)),
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1B2E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1E2E1E),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Header
                    const Center(
                      child: AgriEtechLogo.horizontal(
                        size: 38,
                        showTagline: true,
                        customTagline: 'NATIONAL AGRICULTURAL EARLY WARNING PLATFORM',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Header Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor.withValues(alpha: 0.1),
                            const Color(0xFFF59E0B).withValues(alpha: 0.06),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.how_to_reg, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Register New Account',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF0F3010),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Both phone and email credentials are required for verification and multi-hazard broadcasts.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Error Alert Banner
                    if (authState.error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Registration Failed',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    authState.error!.message,
                                    style: TextStyle(
                                      color: Colors.red.shade900,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // SECTION 1: Personal & Security Credentials
                    _buildSectionCard(
                      title: '1. User Credentials',
                      icon: Icons.badge_outlined,
                      subtitle: 'Provide your name, username handle, and dual verification credentials.',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Full Name
                          TextFormField(
                            controller: _fullNameController,
                            decoration: InputDecoration(
                              labelText: 'Full Name *',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF1B2E1E) : Colors.white,
                            ),
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.words,
                            validator: (value) => Validators.required(value, 'Full name'),
                            enabled: !authState.isLoading,
                          ),
                          _buildFieldHelper('Given name and paternal family name (e.g. Abebe Bikila)'),
                          const SizedBox(height: 14),

                          // Username
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Username *',
                              prefixIcon: const Icon(Icons.alternate_email),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF1B2E1E) : Colors.white,
                            ),
                            textInputAction: TextInputAction.next,
                            validator: Validators.username,
                            enabled: !authState.isLoading,
                          ),
                          _buildFieldHelper('Unique alphanumeric username handle for direct sign-in (e.g. abebe_bikila)'),
                          const SizedBox(height: 14),

                          // Phone Number
                          TextFormField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              labelText: 'Phone Number (SMS & Calls) *',
                              prefixIcon: const Icon(Icons.phone_android),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF1B2E1E) : Colors.white,
                            ),
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            validator: Validators.phone,
                            enabled: !authState.isLoading,
                          ),
                          _buildFieldHelper('Supports Ethio Telecom (09...) and Safaricom (07...) prefixes'),
                          const SizedBox(height: 14),

                          // Email Address
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email Address (Advisories & Reports) *',
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF1B2E1E) : Colors.white,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: Validators.email,
                            enabled: !authState.isLoading,
                          ),
                          _buildFieldHelper('Required for analytical bulletins, harvest forecasts, and security recovery'),
                          const SizedBox(height: 14),

                          // Password
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password *',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF1B2E1E) : Colors.white,
                            ),
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
                            validator: Validators.password,
                            enabled: !authState.isLoading,
                          ),
                          _buildFieldHelper('Must contain at least 8 characters, 1 uppercase, 1 number, and 1 symbol'),
                          const SizedBox(height: 14),

                          // Confirm Password
                          TextFormField(
                            controller: _confirmPasswordController,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password *',
                              prefixIcon: const Icon(Icons.lock_reset),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                ),
                                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF1B2E1E) : Colors.white,
                            ),
                            obscureText: _obscureConfirmPassword,
                            textInputAction: TextInputAction.done,
                            validator: (value) => Validators.confirmPassword(
                              value,
                              _passwordController.text,
                            ),
                            enabled: !authState.isLoading,
                          ),
                          _buildFieldHelper('Re-enter the exact password configured above'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // SECTION 2: Administrative Jurisdiction & Language
                    _buildSectionCard(
                      title: '2. Administrative Jurisdiction & Language',
                      icon: Icons.location_on_outlined,
                      subtitle: 'Select your agricultural zone and preferred broadcast language for localized advisory.',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Region Dropdown
                          DropdownButtonFormField<String>(
                            key: ValueKey('reg_${hierarchy.regions.length}_${hierarchy.selectedRegion?.id}'),
                            initialValue: hierarchy.regions.any((r) => r.id == hierarchy.selectedRegion?.id)
                                ? hierarchy.selectedRegion?.id
                                : null,
                            decoration: InputDecoration(
                              labelText: 'Region *',
                              prefixIcon: const Icon(Icons.public),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF1B2E1E) : Colors.white,
                            ),
                            items: hierarchy.regions.map((region) {
                              return DropdownMenuItem<String>(
                                value: region.id,
                                child: Text(region.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                              );
                            }).toList(),
                            validator: (v) => v == null || v.isEmpty ? 'Please select your region' : null,
                            onChanged: authState.isLoading
                                ? null
                                : (regionId) {
                                    if (regionId != null) {
                                      final region = hierarchy.regions.firstWhere((r) => r.id == regionId);
                                      hierarchyNotifier.selectRegion(region);
                                    }
                                  },
                          ),
                          _buildFieldHelper('Select your administrative region (e.g. Oromia, Amhara, Sidama)'),
                          const SizedBox(height: 14),

                          // 2. Zone Dropdown
                          DropdownButtonFormField<String>(
                            key: ValueKey('zone_${hierarchy.zones.length}_${hierarchy.selectedZone?.id}'),
                            initialValue: hierarchy.zones.any((z) => z.id == hierarchy.selectedZone?.id)
                                ? hierarchy.selectedZone?.id
                                : null,
                            decoration: InputDecoration(
                              labelText: 'Zone *',
                              prefixIcon: const Icon(Icons.map_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF1B2E1E) : Colors.white,
                            ),
                            items: hierarchy.zones.map((zone) {
                              return DropdownMenuItem<String>(
                                value: zone.id,
                                child: Text(zone.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                              );
                            }).toList(),
                            validator: (v) => v == null || v.isEmpty ? 'Please select your zone' : null,
                            onChanged: (hierarchy.selectedRegion == null || authState.isLoading)
                                ? null
                                : (zoneId) {
                                    if (zoneId != null) {
                                      final zone = hierarchy.zones.firstWhere((z) => z.id == zoneId);
                                      hierarchyNotifier.selectZone(zone);
                                    }
                                  },
                          ),
                          _buildFieldHelper('Select your administrative zone (e.g. East Shewa, Arsi)'),
                          const SizedBox(height: 14),

                          // 3. Woreda Dropdown
                          DropdownButtonFormField<String>(
                            key: ValueKey('woreda_${hierarchy.woredas.length}_${hierarchy.selectedWoreda?.id}'),
                            initialValue: hierarchy.woredas.any((w) => w.id == hierarchy.selectedWoreda?.id)
                                ? hierarchy.selectedWoreda?.id
                                : null,
                            decoration: InputDecoration(
                              labelText: 'Woreda *',
                              prefixIcon: const Icon(Icons.holiday_village_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF1B2E1E) : Colors.white,
                            ),
                            items: hierarchy.woredas.map((woreda) {
                              return DropdownMenuItem<String>(
                                value: woreda.id,
                                child: Text(woreda.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                              );
                            }).toList(),
                            validator: (v) => v == null || v.isEmpty ? 'Please select your woreda' : null,
                            onChanged: (hierarchy.selectedZone == null || authState.isLoading)
                                ? null
                                : (woredaId) {
                                    if (woredaId != null) {
                                      final woreda = hierarchy.woredas.firstWhere((w) => w.id == woredaId);
                                      hierarchyNotifier.selectWoreda(woreda);
                                    }
                                  },
                          ),
                          _buildFieldHelper('Select your woreda jurisdiction (e.g. Bishoftu, Adama Zuria)'),
                          const SizedBox(height: 18),

                          // Language Preference
                          const Text(
                            'Preferred Advisory Language *',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildLangChip('en', 'English'),
                              _buildLangChip('am', 'አማርኛ (Amharic)'),
                              _buildLangChip('om', 'Afaan Oromoo'),
                              _buildLangChip('ti', 'ትግርኛ (Tigrinya)'),
                            ],
                          ),
                          _buildFieldHelper('Language used for SMS, voice synthesized alerts, and telemetry alerts'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // SECTION 3: Terms and Conditions
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: _termsError ? Colors.red.shade50 : (isDark ? const Color(0xFF1B2E1E) : Colors.white),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _termsError ? Colors.red : Colors.grey.shade300,
                          width: _termsError ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _acceptTerms,
                            activeColor: AppTheme.primaryColor,
                            onChanged: authState.isLoading
                                ? null
                                : (val) => setState(() {
                                      _acceptTerms = val ?? false;
                                      if (_acceptTerms) _termsError = false;
                                    }),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _acceptTerms = !_acceptTerms;
                                if (_acceptTerms) _termsError = false;
                              }),
                              child: const Text(
                                'I agree to the Terms of Service, Geospatial Data Policy, and Emergency Warning Broadcasts.',
                                style: TextStyle(fontSize: 12, height: 1.3),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Registration Button
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: authState.isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B5E20),
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
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
                                  Text('Creating Account...'),
                                ],
                              )
                            : const Text(
                                'Create Account',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Already have an account?
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                        ),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF1B5E20),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldHelper(String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required String subtitle,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF162518) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF263E26) : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const Divider(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildLangChip(String code, String label) {
    final isSelected = _selectedLanguage == code;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : const Color(0xFF1E2E1E)),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedLanguage = code);
        }
      },
    );
  }
}
