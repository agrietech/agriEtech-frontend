import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../core/error/error_handler.dart';
import '../../../core/error/app_error.dart';
import '../../../core/widgets/agrietech_logo.dart';
import '../../boundaries/repositories/boundary_local_cache.dart';
import '../../boundaries/providers/boundary_provider.dart';

class _RoleOption {
  final String roleKey;
  final String title;
  final String amharicTitle;
  final String subtitle;
  final IconData icon;

  const _RoleOption({
    required this.roleKey,
    required this.title,
    required this.amharicTitle,
    required this.subtitle,
    required this.icon,
  });
}

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _kebeleController = TextEditingController();

  String _selectedRole = 'FARMER';
  String? _selectedRegionId;
  String? _selectedZoneId;
  String? _selectedWoredaId;
  String _selectedLang = 'am';

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  bool _termsError = false;

  static const List<_RoleOption> _roles = [
    _RoleOption(
      roleKey: 'FARMER',
      title: 'Farmer / Producer',
      amharicTitle: 'አርሶ / አርብቶ አደር',
      subtitle: 'Crop health alerts, localized weather, AI leaf scanner',
      icon: Icons.agriculture_rounded,
    ),
    _RoleOption(
      roleKey: 'DEVELOPMENT_AGENT',
      title: 'Development Agent (DA)',
      amharicTitle: 'የልማት ጣቢያ ባለሙያ',
      subtitle: 'Kebele farmer registry, field sensor telemetry',
      icon: Icons.support_agent_rounded,
    ),
    _RoleOption(
      roleKey: 'WOREDA_OFFICER',
      title: 'Woreda Agronomy Officer',
      amharicTitle: 'የወረዳ ግብርና መኮንን',
      subtitle: 'Woreda disaster alerts, USSD broadcast, GIS tracking',
      icon: Icons.admin_panel_settings_rounded,
    ),
    _RoleOption(
      roleKey: 'ZONAL_OFFICER',
      title: 'Zonal Agricultural Lead',
      amharicTitle: 'የዞን ግብርና መምሪያ',
      subtitle: 'Zonal cross-woreda analytics, resource allocation',
      icon: Icons.domain_rounded,
    ),
    _RoleOption(
      roleKey: 'REGIONAL_OFFICER',
      title: 'Regional Bureau Director',
      amharicTitle: 'የክልል ግብርና ቢሮ',
      subtitle: 'Regional food security dashboard, seismic risk',
      icon: Icons.account_balance_rounded,
    ),
    _RoleOption(
      roleKey: 'RESEARCHER',
      title: 'Agricultural Researcher',
      amharicTitle: 'ተመራማሪ / ሳይንቲስት',
      subtitle: 'Satellite datasets, RUSLE soil loss, downscaled forecasts',
      icon: Icons.biotech_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(authProvider.notifier).clearError();
      ref.read(boundaryHierarchyProvider.notifier).loadRegions();
    });

    _fullNameController.addListener(_clearError);
    _phoneController.addListener(_clearError);
    _emailController.addListener(_clearError);
    _passwordController.addListener(_clearError);
  }

  void _clearError() {
    if (ref.read(authProvider).error != null) {
      ref.read(authProvider.notifier).clearError();
    }
  }

  @override
  void dispose() {
    _fullNameController.removeListener(_clearError);
    _phoneController.removeListener(_clearError);
    _emailController.removeListener(_clearError);
    _passwordController.removeListener(_clearError);
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _kebeleController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    ref.read(authProvider.notifier).clearError();

    if (!_acceptTerms) {
      setState(() => _termsError = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms of Service to continue'),
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
              email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
              role: _selectedRole,
              regionId: _selectedRegionId,
              zoneId: _selectedZoneId,
              woredaId: _selectedWoredaId,
              kebeleName: _kebeleController.text.trim().isEmpty ? null : _kebeleController.text.trim(),
              preferredLang: _selectedLang,
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
                        'Account registered successfully',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Color(0xFF2E7D32),
                duration: Duration(seconds: 3),
              ),
            );
            context.go('/home');
          } else {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedLg),
                title: const Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Color(0xFF2E7D32), size: 28),
                    SizedBox(width: 10),
                    Text('Registration Successful', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                content: const Text(
                  'Your account has been created. You can now sign in with your phone number.',
                  style: TextStyle(fontSize: 14, height: 1.4),
                ),
                actions: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      context.go('/login');
                    },
                    icon: const Icon(Icons.login, size: 18),
                    label: const Text('Sign In'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedSm),
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
                shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedLg),
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
    final regionsAsync = ref.watch(regionsProvider);
    final zonesAsync = ref.watch(zonesByRegionProvider(_selectedRegionId));
    final woredasAsync = ref.watch(woredasByZoneProvider(_selectedZoneId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final availableRegions = regionsAsync.valueOrNull ?? BoundaryLocalCache.defaultRegions;
    final availableZones = zonesAsync.valueOrNull ?? [];
    final availableWoredas = woredasAsync.valueOrNull ?? [];

    return Scaffold(
      backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
      appBar: AppBar(
        title: const Text('Create Account', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF18281B) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1E2E1E),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
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
                    const SizedBox(height: AppSpacing.screenPadding),

                    // Error Alert Banner
                    if (authState.error != null) ...[
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
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Registration Failed',
                                    style: AppTypography.subtitle.copyWith(
                                      color: Colors.red,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    authState.error!.message,
                                    style: TextStyle(color: Colors.red.shade900, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // Section 1: Professional Role Selector
                    _buildSectionCard(
                      title: 'Professional Role',
                      icon: Icons.assignment_ind_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<String>(
                            initialValue: _selectedRole,
                            decoration: InputDecoration(
                              labelText: 'Applied Role / የስራ ድርሻ',
                              prefixIcon: const Icon(Icons.badge_outlined),
                              border: const OutlineInputBorder(borderRadius: AppRadii.roundedMd),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF1E3321) : const Color(0xFFF9FAF9),
                            ),
                            items: _roles.map((r) {
                              return DropdownMenuItem<String>(
                                value: r.roleKey,
                                child: Row(
                                  children: [
                                    Icon(r.icon, size: 18, color: AppTheme.primaryColor),
                                    const SizedBox(width: 10),
                                    Text(
                                      '${r.title} (${r.amharicTitle})',
                                      style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: authState.isLoading
                                ? null
                                : (val) {
                                    if (val != null) {
                                      setState(() => _selectedRole = val);
                                    }
                                  },
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _roles.firstWhere((r) => r.roleKey == _selectedRole).subtitle,
                            style: AppTypography.caption.copyWith(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Section 2: Account Credentials
                    _buildSectionCard(
                      title: 'Account Credentials',
                      icon: Icons.person_outline,
                      child: Column(
                        children: [
                          // Full Name
                          TextFormField(
                            controller: _fullNameController,
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: const OutlineInputBorder(borderRadius: AppRadii.roundedMd),
                              filled: true,
                              fillColor: isDark ? AppTheme.surfaceDark : const Color(0xFFF8FAF8),
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Full name is required' : null,
                            enabled: !authState.isLoading,
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          // Phone Number
                          TextFormField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              prefixIcon: const Icon(Icons.phone_outlined),
                              border: const OutlineInputBorder(borderRadius: AppRadii.roundedMd),
                              filled: true,
                              fillColor: isDark ? AppTheme.surfaceDark : const Color(0xFFF8FAF8),
                            ),
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            validator: Validators.phone,
                            enabled: !authState.isLoading,
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          // Email (Optional)
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email Address (Optional)',
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: const OutlineInputBorder(borderRadius: AppRadii.roundedMd),
                              filled: true,
                              fillColor: isDark ? AppTheme.surfaceDark : const Color(0xFFF8FAF8),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (v) => (v == null || v.trim().isEmpty) ? null : Validators.email(v.trim()),
                            enabled: !authState.isLoading,
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          // Password
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              border: const OutlineInputBorder(borderRadius: AppRadii.roundedMd),
                              filled: true,
                              fillColor: isDark ? AppTheme.surfaceDark : const Color(0xFFF8FAF8),
                            ),
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
                            validator: Validators.password,
                            enabled: !authState.isLoading,
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          // Confirm Password
                          TextFormField(
                            controller: _confirmPasswordController,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              prefixIcon: const Icon(Icons.lock_reset_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                              ),
                              border: const OutlineInputBorder(borderRadius: AppRadii.roundedMd),
                              filled: true,
                              fillColor: isDark ? AppTheme.surfaceDark : const Color(0xFFF8FAF8),
                            ),
                            obscureText: _obscureConfirmPassword,
                            textInputAction: TextInputAction.done,
                            validator: (value) => Validators.confirmPassword(
                              value,
                              _passwordController.text,
                            ),
                            enabled: !authState.isLoading,
                          ),
                          const SizedBox(height: 14),

                          // Preferred Language Dropdown
                          DropdownButtonFormField<String>(
                            initialValue: _selectedLang,
                            decoration: InputDecoration(
                              labelText: 'Preferred Language / ቋንቋ',
                              prefixIcon: const Icon(Icons.language_outlined),
                              border: const OutlineInputBorder(borderRadius: AppRadii.roundedMd),
                              filled: true,
                              fillColor: isDark ? AppTheme.surfaceDark : const Color(0xFFF8FAF8),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'am', child: Text('አማርኛ (Amharic)')),
                              DropdownMenuItem(value: 'om', child: Text('Afaan Oromoo (Oromo)')),
                              DropdownMenuItem(value: 'ti', child: Text('ትግርኛ (Tigrinya)')),
                              DropdownMenuItem(value: 'so', child: Text('Soomaali (Somali)')),
                              DropdownMenuItem(value: 'en', child: Text('English')),
                            ],
                            onChanged: authState.isLoading
                                ? null
                                : (val) {
                                    if (val != null) {
                                      setState(() => _selectedLang = val);
                                    }
                                  },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Section 3: Administrative Location
                    _buildSectionCard(
                      title: 'Administrative Location',
                      icon: Icons.location_on_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Region Dropdown
                          DropdownButtonFormField<String>(
                            key: ValueKey('reg_$_selectedRegionId'),
                            initialValue: availableRegions.any((r) => r.id == _selectedRegionId) ? _selectedRegionId : null,
                            decoration: InputDecoration(
                              labelText: 'Region / ክልል *',
                              prefixIcon: const Icon(Icons.public),
                              border: const OutlineInputBorder(borderRadius: AppRadii.roundedMd),
                              filled: true,
                              fillColor: isDark ? AppTheme.surfaceDark : const Color(0xFFF8FAF8),
                            ),
                            items: availableRegions.map((region) {
                              return DropdownMenuItem<String>(
                                value: region.id,
                                child: Text(region.name),
                              );
                            }).toList(),
                            validator: (v) => v == null || v.isEmpty ? 'Please select your region' : null,
                            onChanged: authState.isLoading
                                ? null
                                : (regionId) {
                                    setState(() {
                                      _selectedRegionId = regionId;
                                      _selectedZoneId = null;
                                      _selectedWoredaId = null;
                                    });
                                  },
                          ),
                          const SizedBox(height: 14),

                          // Zone Dropdown
                          DropdownButtonFormField<String>(
                            key: ValueKey('zone_${_selectedRegionId}_$_selectedZoneId'),
                            initialValue: availableZones.any((z) => z.id == _selectedZoneId) ? _selectedZoneId : null,
                            hint: Text(
                              _selectedRegionId == null ? 'Select Region first' : 'Select Zone (Optional)',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                            decoration: InputDecoration(
                              labelText: 'Zone / ዞን',
                              prefixIcon: const Icon(Icons.map_outlined),
                              border: const OutlineInputBorder(borderRadius: AppRadii.roundedMd),
                              filled: true,
                              fillColor: isDark
                                  ? AppTheme.surfaceDark
                                  : (_selectedRegionId == null ? Colors.grey.shade100 : const Color(0xFFF8FAF8)),
                            ),
                            items: availableZones.map((zone) {
                              return DropdownMenuItem<String>(
                                value: zone.id,
                                child: Text(zone.name),
                              );
                            }).toList(),
                            onChanged: (_selectedRegionId == null || authState.isLoading)
                                ? null
                                : (zoneId) {
                                    setState(() {
                                      _selectedZoneId = zoneId;
                                      _selectedWoredaId = null;
                                    });
                                  },
                          ),
                          const SizedBox(height: 14),

                          // Woreda Dropdown
                          DropdownButtonFormField<String>(
                            key: ValueKey('woreda_${_selectedZoneId}_$_selectedWoredaId'),
                            initialValue: availableWoredas.any((w) => w.id == _selectedWoredaId) ? _selectedWoredaId : null,
                            hint: Text(
                              _selectedRegionId == null ? 'Select Region first' : 'Select Woreda (Optional)',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                            decoration: InputDecoration(
                              labelText: 'Woreda / ወረዳ',
                              prefixIcon: const Icon(Icons.holiday_village_outlined),
                              border: const OutlineInputBorder(borderRadius: AppRadii.roundedMd),
                              filled: true,
                              fillColor: isDark
                                  ? AppTheme.surfaceDark
                                  : (_selectedRegionId == null ? Colors.grey.shade100 : const Color(0xFFF8FAF8)),
                            ),
                            items: availableWoredas.map((woreda) {
                              return DropdownMenuItem<String>(
                                value: woreda.id,
                                child: Text(woreda.name),
                              );
                            }).toList(),
                            onChanged: (_selectedRegionId == null || authState.isLoading)
                                ? null
                                : (woredaId) {
                                    setState(() {
                                      _selectedWoredaId = woredaId;
                                    });
                                  },
                          ),
                          const SizedBox(height: 14),

                          // Kebele (Optional)
                          TextFormField(
                            controller: _kebeleController,
                            decoration: InputDecoration(
                              labelText: 'Kebele / Tabia / Ganda (Optional)',
                              prefixIcon: const Icon(Icons.signpost_outlined),
                              border: const OutlineInputBorder(borderRadius: AppRadii.roundedMd),
                              filled: true,
                              fillColor: isDark ? AppTheme.surfaceDark : const Color(0xFFF8FAF8),
                            ),
                            textInputAction: TextInputAction.done,
                            enabled: !authState.isLoading,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Terms and Conditions
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _termsError ? Colors.red.shade50 : (isDark ? AppTheme.cardDark : Colors.white),
                        borderRadius: AppRadii.roundedMd,
                        border: Border.all(
                          color: _termsError ? AppTheme.errorColor : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
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
                                : (val) {
                                    setState(() {
                                      _acceptTerms = val ?? false;
                                      if (_acceptTerms) _termsError = false;
                                    });
                                  },
                          ),
                          Expanded(
                            child: Text(
                              'I agree to the Terms of Service & Privacy Policy for the National Agricultural Platform.',
                              style: TextStyle(
                                fontSize: 12,
                                color: _termsError ? Colors.red.shade900 : (isDark ? Colors.grey.shade300 : Colors.black87),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Submit Registration Button
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: authState.isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B5E20),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: authState.isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Register Account',
                                style: AppTypography.titleMedium,
                              ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Sign In Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: AppTypography.body.copyWith(
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                        TextButton(
                          onPressed: authState.isLoading ? null : () => context.go('/login'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF1B5E20),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                          child: const Text(
                            'Sign In',
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

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF18281B) : Colors.white,
        borderRadius: AppRadii.roundedXl,
        border: Border.all(
          color: isDark ? const Color(0xFF263E26) : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF1B5E20)),
              const SizedBox(width: AppSpacing.xs),
              Text(
                title,
                style: AppTypography.subtitle,
              ),
            ],
          ),
          const Divider(height: 22),
          child,
        ],
      ),
    );
  }
}
