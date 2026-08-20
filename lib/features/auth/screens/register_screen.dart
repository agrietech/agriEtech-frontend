import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/app_localizations.dart';
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
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedLanguage = 'en';
  bool _acceptTerms = false;

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
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    ref.read(authProvider.notifier).clearError();
    final hierarchy = ref.read(boundaryHierarchyProvider);
    
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the terms and conditions to proceed'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
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
                        'Account created successfully! Welcome to AgriEtech.',
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
                  _emailController.text.trim().isNotEmpty
                      ? 'Your account has been created successfully! A verification email may have been sent to ${_emailController.text.trim()}. Please verify your email and sign in.'
                      : 'Your account has been registered successfully! You can now sign in with your phone number and password.',
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
                actions: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      context.go('/login');
                    },
                    icon: const Icon(Icons.login, size: 18),
                    label: const Text('Proceed to Login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF7),
      appBar: AppBar(
        title: const Text('Account Registration', style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E2E1E),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
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
                        size: 36,
                        showTagline: true,
                        customTagline: 'NATIONAL AGRICULTURAL EARLY WARNING PLATFORM',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Header Introduction Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor.withValues(alpha: 0.08),
                            AppTheme.primaryLightColor.withValues(alpha: 0.04),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.15)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.how_to_reg, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Create Farmer / Officer Account',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF0F3010),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Access satellite crop telemetry, pest alerts, and weather advisories',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
                                    'Registration Issue',
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

                    // SECTION 1: Personal & Contact Information
                    _buildSectionCard(
                      title: '1. Personal & Contact Information',
                      icon: Icons.person_pin_outlined,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _fullNameController,
                            decoration: InputDecoration(
                              labelText: 'Full Name *',
                              hintText: 'e.g. Abebe Bikila',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.words,
                            validator: (value) => Validators.required(value, 'Full name'),
                            enabled: !authState.isLoading,
                          ),
                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              labelText: 'Phone Number *',
                              hintText: 'e.g. 0911 234 567 or +251 91 123 4567',
                              prefixIcon: const Icon(Icons.phone_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: Colors.white,
                              helperText: 'Used for SMS early warnings and sign-in',
                            ),
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            validator: Validators.phone,
                            enabled: !authState.isLoading,
                          ),
                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email Address (Optional)',
                              hintText: 'e.g. abebe.b@agri.et',
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (value) => value != null && value.trim().isNotEmpty
                                ? Validators.email(value.trim())
                                : null,
                            enabled: !authState.isLoading,
                          ),
                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Username (Optional)',
                              hintText: 'e.g. abebe_farmer',
                              prefixIcon: const Icon(Icons.alternate_email),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            textInputAction: TextInputAction.next,
                            enabled: !authState.isLoading,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // SECTION 2: Geographic Jurisdiction (Region -> Zone -> Woreda)
                    _buildSectionCard(
                      title: '2. Administrative Jurisdiction',
                      icon: Icons.location_on_outlined,
                      subtitle: 'Select your agricultural jurisdiction for tailored risk maps and weather forecasts',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Region Dropdown
                          DropdownButtonFormField<String>(
                            key: ValueKey('reg_${hierarchy.regions.length}_${hierarchy.selectedRegion?.id}'),
                            value: hierarchy.regions.any((r) => r.id == hierarchy.selectedRegion?.id)
                                ? hierarchy.selectedRegion?.id
                                : null,
                            decoration: InputDecoration(
                              labelText: 'Region *',
                              prefixIcon: const Icon(Icons.public),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            ),
                            hint: const Text('Select Region (e.g. Oromia, Amhara)'),
                            items: hierarchy.regions.map((region) {
                              return DropdownMenuItem<String>(
                                value: region.id,
                                child: Text(region.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                              );
                            }).toList(),
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

                          // 2. Zone Dropdown
                          DropdownButtonFormField<String>(
                            key: ValueKey('zone_${hierarchy.zones.length}_${hierarchy.selectedZone?.id}'),
                            value: hierarchy.zones.any((z) => z.id == hierarchy.selectedZone?.id)
                                ? hierarchy.selectedZone?.id
                                : null,
                            decoration: InputDecoration(
                              labelText: 'Zone *',
                              prefixIcon: const Icon(Icons.map_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            ),
                            hint: Text(hierarchy.selectedRegion == null
                                ? 'Select Region first'
                                : 'Select Zone (e.g. East Shewa)'),
                            items: hierarchy.zones.map((zone) {
                              return DropdownMenuItem<String>(
                                value: zone.id,
                                child: Text(zone.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                              );
                            }).toList(),
                            onChanged: (authState.isLoading || hierarchy.selectedRegion == null)
                                ? null
                                : (zoneId) {
                                    if (zoneId != null) {
                                      final zone = hierarchy.zones.firstWhere((z) => z.id == zoneId);
                                      hierarchyNotifier.selectZone(zone);
                                    }
                                  },
                          ),
                          const SizedBox(height: 14),

                          // 3. Woreda Dropdown
                          DropdownButtonFormField<String>(
                            key: ValueKey('woreda_${hierarchy.woredas.length}_${hierarchy.selectedWoreda?.id}'),
                            value: hierarchy.woredas.any((w) => w.id == hierarchy.selectedWoreda?.id)
                                ? hierarchy.selectedWoreda?.id
                                : null,
                            decoration: InputDecoration(
                              labelText: 'Woreda / District *',
                              prefixIcon: const Icon(Icons.place_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            ),
                            hint: Text(hierarchy.selectedZone == null
                                ? 'Select Zone first'
                                : 'Select Woreda (e.g. Ada\'a, Ambo)'),
                            items: hierarchy.woredas.map((woreda) {
                              return DropdownMenuItem<String>(
                                value: woreda.id,
                                child: Text(woreda.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                              );
                            }).toList(),
                            onChanged: (authState.isLoading || hierarchy.selectedZone == null)
                                ? null
                                : (woredaId) {
                                    if (woredaId != null) {
                                      final woreda = hierarchy.woredas.firstWhere((w) => w.id == woredaId);
                                      hierarchyNotifier.selectWoreda(woreda);
                                    }
                                  },
                          ),

                          // Selected Hierarchy Summary Badge
                          if (hierarchy.selectedRegion != null) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.15)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle_outline, color: AppTheme.primaryColor, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Selected: ${hierarchyNotifier.getHierarchyString()}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // SECTION 3: Security & Password Credentials
                    _buildSectionCard(
                      title: '3. Account Security',
                      icon: Icons.security_outlined,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password *',
                              hintText: 'Minimum 6 characters',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
                            validator: Validators.password,
                            enabled: !authState.isLoading,
                          ),
                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _confirmPasswordController,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password *',
                              hintText: 'Re-enter your password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: Colors.white,
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

                    // SECTION 4: Preferences & Agreement
                    _buildSectionCard(
                      title: '4. System Preferences & Agreement',
                      icon: Icons.tune_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<String>(
                            value: _selectedLanguage,
                            decoration: InputDecoration(
                              labelText: 'Preferred Advisory Language',
                              prefixIcon: const Icon(Icons.language),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            items: const [
                              DropdownMenuItem(value: 'en', child: Text('English (Default)')),
                              DropdownMenuItem(value: 'am', child: Text('አማርኛ (Amharic)')),
                            ],
                            onChanged: authState.isLoading ? null : (v) => setState(() => _selectedLanguage = v!),
                          ),
                          const SizedBox(height: 14),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: _acceptTerms,
                                activeColor: AppTheme.primaryColor,
                                onChanged: authState.isLoading ? null : (v) => setState(() => _acceptTerms = v ?? false),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    'I acknowledge and agree to the AgriEtech National Agricultural Terms of Service and Privacy Policy.',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade800, height: 1.3),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton.icon(
                      onPressed: authState.isLoading ? null : _register,
                      icon: authState.isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.check_circle, size: 20),
                      label: Text(
                        authState.isLoading ? 'Creating Account...' : 'Complete Registration',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Sign In Footer Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already registered with AgriEtech? ',
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                        ),
                        TextButton(
                          onPressed: authState.isLoading ? null : () => context.go('/login'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
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
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E2E1E),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
