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
      ref.read(authProvider.notifier).clearError();
      ref.read(boundaryHierarchyProvider.notifier).loadRegions();
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
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
          content: Text('Please accept the Terms of Service'),
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
                        'Account created successfully',
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
                    Icon(Icons.check_circle_outline, color: Color(0xFF2E7D32), size: 28),
                    SizedBox(width: 10),
                    Text('Account Created', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                content: const Text(
                  'Your account has been created successfully. You can now sign in.',
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
        title: const Text('Register', style: TextStyle(fontWeight: FontWeight.w700)),
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1B2E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1E2E1E),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
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

                    // Section: Account Details
                    _buildSectionCard(
                      title: 'Account Details',
                      icon: Icons.person_outline,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Full Name
                          TextFormField(
                            controller: _fullNameController,
                            decoration: InputDecoration(
                              labelText: 'Full Name',
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
                          const SizedBox(height: 14),

                          // Phone Number
                          TextFormField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              prefixIcon: const Icon(Icons.phone_android_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF1B2E1E) : Colors.white,
                            ),
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            validator: Validators.phone,
                            enabled: !authState.isLoading,
                          ),
                          const SizedBox(height: 14),

                          // Email Address
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email Address',
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
                          const SizedBox(height: 14),

                          // Password
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
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
                          const SizedBox(height: 14),

                          // Confirm Password
                          TextFormField(
                            controller: _confirmPasswordController,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Section: Farm Location & Language
                    _buildSectionCard(
                      title: 'Farm Location & Language',
                      icon: Icons.location_on_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Region Dropdown
                          DropdownButtonFormField<String>(
                            key: ValueKey('reg_${hierarchy.regions.length}_${hierarchy.selectedRegion?.id}'),
                            initialValue: hierarchy.regions.any((r) => r.id == hierarchy.selectedRegion?.id)
                                ? hierarchy.selectedRegion?.id
                                : null,
                            decoration: InputDecoration(
                              labelText: 'Region',
                              prefixIcon: const Icon(Icons.public),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF1B2E1E) : Colors.white,
                            ),
                            items: hierarchy.regions.map((region) {
                              return DropdownMenuItem<String>(
                                value: region.id,
                                child: Text(region.name),
                              );
                            }).toList(),
                            validator: (v) => v == null || v.isEmpty ? 'Please select a region' : null,
                            onChanged: authState.isLoading
                                ? null
                                : (regionId) {
                                    if (regionId != null) {
                                      final region = hierarchy.regions.firstWhere((r) => r.id == regionId);
                                      hierarchyNotifier.selectRegion(region);
                                    }
                                  },
                          ),
                          const SizedBox(height: 14),

                          // Zone Dropdown
                          DropdownButtonFormField<String>(
                            key: ValueKey('zone_${hierarchy.zones.length}_${hierarchy.selectedZone?.id}'),
                            initialValue: hierarchy.zones.any((z) => z.id == hierarchy.selectedZone?.id)
                                ? hierarchy.selectedZone?.id
                                : null,
                            hint: Text(
                              hierarchy.selectedRegion == null ? 'Select Region first' : 'Select Zone',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                            decoration: InputDecoration(
                              labelText: 'Zone',
                              helperText: hierarchy.selectedRegion == null ? 'Select a Region above to enable' : null,
                              helperStyle: const TextStyle(fontSize: 11),
                              prefixIcon: const Icon(Icons.map_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF1B2E1E) : (hierarchy.selectedRegion == null ? Colors.grey.shade100 : Colors.white),
                            ),
                            items: hierarchy.zones.map((zone) {
                              return DropdownMenuItem<String>(
                                value: zone.id,
                                child: Text(zone.name),
                              );
                            }).toList(),
                            validator: (v) => v == null || v.isEmpty ? 'Please select a zone' : null,
                            onChanged: (hierarchy.selectedRegion == null || authState.isLoading)
                                ? null
                                : (zoneId) {
                                    if (zoneId != null) {
                                      final zone = hierarchy.zones.firstWhere((z) => z.id == zoneId);
                                      hierarchyNotifier.selectZone(zone);
                                    }
                                  },
                          ),
                          const SizedBox(height: 14),

                          // Woreda Dropdown
                          DropdownButtonFormField<String>(
                            key: ValueKey('woreda_${hierarchy.woredas.length}_${hierarchy.selectedWoreda?.id}'),
                            initialValue: hierarchy.woredas.any((w) => w.id == hierarchy.selectedWoreda?.id)
                                ? hierarchy.selectedWoreda?.id
                                : null,
                            hint: Text(
                              hierarchy.selectedZone == null ? 'Select Zone first' : 'Select Woreda',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                            decoration: InputDecoration(
                              labelText: 'Woreda',
                              helperText: hierarchy.selectedZone == null ? 'Select a Zone above to enable' : null,
                              helperStyle: const TextStyle(fontSize: 11),
                              prefixIcon: const Icon(Icons.holiday_village_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF1B2E1E) : (hierarchy.selectedZone == null ? Colors.grey.shade100 : Colors.white),
                            ),
                            items: hierarchy.woredas.map((woreda) {
                              return DropdownMenuItem<String>(
                                value: woreda.id,
                                child: Text(woreda.name),
                              );
                            }).toList(),
                            validator: (v) => v == null || v.isEmpty ? 'Please select a woreda' : null,
                            onChanged: (hierarchy.selectedZone == null || authState.isLoading)
                                ? null
                                : (woredaId) {
                                    if (woredaId != null) {
                                      final woreda = hierarchy.woredas.firstWhere((w) => w.id == woredaId);
                                      hierarchyNotifier.selectWoreda(woreda);
                                    }
                                  },
                          ),
                          
                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 14),

                          // Preferred Language Label
                          Text(
                            'Preferred Language',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildLangChip('en', 'English'),
                              _buildLangChip('am', 'አማርኛ (Amharic)'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Terms and Conditions Checkbox
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
                                'I agree to the Terms of Service & Privacy Policy',
                                style: TextStyle(fontSize: 13, height: 1.3),
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
                          elevation: 2,
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
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sign In Redirection
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

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
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
          const Divider(height: 20),
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
