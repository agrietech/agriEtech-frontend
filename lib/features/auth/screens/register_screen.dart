import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../core/utils/validators.dart';
import '../../../core/error/error_handler.dart';
import '../../../core/error/app_error.dart';
import '../../../core/widgets/agrietech_logo.dart';
import '../../boundaries/repositories/boundary_local_cache.dart';
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
  final _organizationController = TextEditingController();
  final _staffIdController = TextEditingController();
  final _justificationController = TextEditingController();
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

  static const _ethiopicFontFallback = ['Noto Sans Ethiopic', 'Abyssinica SIL', 'sans-serif'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(authProvider.notifier).clearError();
    });

    _fullNameController.addListener(_clearError);
    _phoneController.addListener(_clearError);
    _emailController.addListener(_clearError);
    _passwordController.addListener(_clearError);
    _confirmPasswordController.addListener(_clearError);
    _organizationController.addListener(_clearError);
    _staffIdController.addListener(_clearError);
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
    _confirmPasswordController.removeListener(_clearError);
    _organizationController.removeListener(_clearError);
    _staffIdController.removeListener(_clearError);
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _organizationController.dispose();
    _staffIdController.dispose();
    _justificationController.dispose();
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
        final isNonFarmer = _selectedRole != 'FARMER';

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
              organizationName: isNonFarmer ? _organizationController.text.trim() : null,
              staffIdNumber: isNonFarmer ? _staffIdController.text.trim() : null,
              justification: isNonFarmer ? _justificationController.text.trim() : null,
            );

        if (mounted) {
          final isAuth = ref.read(authProvider).isAuthenticated;
          if (isAuth) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Account registered successfully',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Color(0xFF1B5E20),
                duration: Duration(seconds: 3),
              ),
            );
            context.go('/home');
          } else {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                title: const Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Color(0xFF1B5E20), size: 24),
                    SizedBox(width: 10),
                    Text('Registration Successful', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
                  ],
                ),
                content: Text(
                  isNonFarmer
                      ? 'Your platform credential has been registered for $_selectedRole. You can now sign in with your phone number.'
                      : 'Your account has been created. You can now sign in with your mobile phone number.',
                  style: const TextStyle(fontSize: 13.5, height: 1.4),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      context.go('/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    ),
                    child: const Text('Sign in'),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                title: const Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 22),
                    SizedBox(width: 8),
                    Text('Validation Error', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  ],
                ),
                content: Text(errorMessage, style: const TextStyle(fontSize: 13)),
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

  void _showRolePicker(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF162319) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final roles = [
          {
            'id': 'FARMER',
            'title': 'Farmer / Producer',
            'amharic': 'አርሶ አደር',
            'desc': 'Smallholder crop producer and livestock farmer',
            'icon': Icons.agriculture_outlined,
          },
          {
            'id': 'DEVELOPMENT_AGENT',
            'title': 'Development Agent (DA)',
            'amharic': 'የልማት ጣቢያ ባለሙያ',
            'desc': 'Frontline kebele extension and agronomic advisor',
            'icon': Icons.assignment_ind_outlined,
          },
          {
            'id': 'WOREDA_OFFICER',
            'title': 'Woreda Agricultural Officer',
            'amharic': 'የወረዳ ግብርና መኮንን',
            'desc': 'Woreda desk officer managing early warning alerts',
            'icon': Icons.admin_panel_settings_outlined,
          },
          {
            'id': 'ZONAL_OFFICER',
            'title': 'Zonal Agricultural Officer',
            'amharic': 'የዞን ግብርና መኮንን',
            'desc': 'Zonal desk officer coordinating woreda early warnings',
            'icon': Icons.domain_outlined,
          },
          {
            'id': 'REGIONAL_OFFICER',
            'title': 'Regional Agricultural Officer',
            'amharic': 'የክልል ግብርና መኮንን',
            'desc': 'Regional agricultural bureau officer coordinating zones',
            'icon': Icons.public_outlined,
          },
          {
            'id': 'RESEARCHER',
            'title': 'Agronomist / Researcher',
            'amharic': 'ተመራማሪ / ሳይንቲስት',
            'desc': 'Research specialist analyzing agro-climatic data',
            'icon': Icons.biotech_outlined,
          },
        ];

        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.85,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Platform Role',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...roles.map((r) {
                    final isSelected = _selectedRole == r['id'];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? const Color(0xFF1E3A24) : const Color(0xFFECFDF5))
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF1B5E20)
                              : (isDark ? const Color(0xFF26382A) : const Color(0xFFE5E7EB)),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: ListTile(
                        dense: true,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        leading: Icon(
                          r['icon'] as IconData,
                          size: 22,
                          color: isSelected
                              ? const Color(0xFF1B5E20)
                              : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                        ),
                        title: Row(
                          children: [
                            Text(
                              r['title'] as String,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                color: isSelected
                                    ? (isDark ? const Color(0xFFA7F3D0) : const Color(0xFF065F46))
                                    : (isDark ? Colors.white : const Color(0xFF111827)),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '• ${r['amharic']}',
                              style: TextStyle(
                                fontFamilyFallback: _ethiopicFontFallback,
                                fontSize: 12,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          r['desc'] as String,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: Color(0xFF1B5E20), size: 18)
                            : null,
                        onTap: () {
                          setState(() => _selectedRole = r['id'] as String);
                          Navigator.of(ctx).pop();
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLanguagePicker(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF162319) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final languages = [
          {'code': 'am', 'native': 'አማርኛ', 'english': 'Amharic', 'desc': 'Official national working language'},
          {'code': 'om', 'native': 'Afaan Oromoo', 'english': 'Oromo', 'desc': 'Regional working language in Oromia'},
          {'code': 'ti', 'native': 'ትግርኛ', 'english': 'Tigrinya', 'desc': 'Regional working language in Tigray'},
          {'code': 'so', 'native': 'Soomaali', 'english': 'Somali', 'desc': 'Regional working language in Somali Region'},
          {'code': 'en', 'native': 'English', 'english': 'English', 'desc': 'International and scientific technical language'},
        ];

        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.85,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Preferred Language',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...languages.map((l) {
                    final isSelected = _selectedLang == l['code'];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? const Color(0xFF1E3A24) : const Color(0xFFECFDF5))
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF1B5E20)
                              : (isDark ? const Color(0xFF26382A) : const Color(0xFFE5E7EB)),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: ListTile(
                        dense: true,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        title: Row(
                          children: [
                            Text(
                              l['native'] as String,
                              style: TextStyle(
                                fontFamilyFallback: _ethiopicFontFallback,
                                fontSize: 13.5,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                color: isSelected
                                    ? (isDark ? const Color(0xFFA7F3D0) : const Color(0xFF065F46))
                                    : (isDark ? Colors.white : const Color(0xFF111827)),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '(${l['english']})',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          l['desc'] as String,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: Color(0xFF1B5E20), size: 18)
                            : null,
                        onTap: () {
                          setState(() => _selectedLang = l['code'] as String);
                          Navigator.of(ctx).pop();
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleSelectorField(bool isDark) {
    final roleNames = {
      'FARMER': 'Farmer / Producer (አርሶ አደር)',
      'DEVELOPMENT_AGENT': 'Development Agent (DA) • የልማት ጣቢያ ባለሙያ',
      'WOREDA_OFFICER': 'Woreda Agricultural Officer • የወረዳ ግብርና መኮንን',
      'ZONAL_OFFICER': 'Zonal Agricultural Officer • የዞን ግብርና መኮንን',
      'REGIONAL_OFFICER': 'Regional Agricultural Officer • የክልል ግብርና መኮንን',
      'RESEARCHER': 'Agronomist / Researcher • ተመራማሪ',
    };
    final roleIcons = {
      'FARMER': Icons.agriculture_outlined,
      'DEVELOPMENT_AGENT': Icons.assignment_ind_outlined,
      'WOREDA_OFFICER': Icons.admin_panel_settings_outlined,
      'ZONAL_OFFICER': Icons.domain_outlined,
      'REGIONAL_OFFICER': Icons.public_outlined,
      'RESEARCHER': Icons.biotech_outlined,
    };

    return InkWell(
      onTap: () => _showRolePicker(context, isDark),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0E1A11) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? const Color(0xFF26382A) : const Color(0xFFE5E7EB),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              roleIcons[_selectedRole] ?? Icons.badge_outlined,
              size: 18,
              color: const Color(0xFF1B5E20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                roleNames[_selectedRole] ?? _selectedRole,
                style: TextStyle(
                  fontFamilyFallback: _ethiopicFontFallback,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelectorField(bool isDark) {
    final langNames = {
      'am': 'አማርኛ (Amharic)',
      'om': 'Afaan Oromoo (Oromo)',
      'ti': 'ትግርኛ (Tigrinya)',
      'so': 'Soomaali (Somali)',
      'en': 'English (English)',
    };

    return InkWell(
      onTap: () => _showLanguagePicker(context, isDark),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0E1A11) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? const Color(0xFF26382A) : const Color(0xFFE5E7EB),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.language_outlined,
              size: 18,
              color: Color(0xFF1B5E20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                langNames[_selectedLang] ?? _selectedLang,
                style: TextStyle(
                  fontFamilyFallback: _ethiopicFontFallback,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final regionsAsync = ref.watch(regionsProvider);
    final zonesAsync = ref.watch(zonesByRegionProvider(_selectedRegionId));
    final woredasAsync = ref.watch(woredasByZoneProvider(_selectedZoneId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final availableRegions = regionsAsync.valueOrNull ?? BoundaryLocalCache.defaultRegions;
    final availableZones = zonesAsync.valueOrNull ?? [];
    final availableWoredas = woredasAsync.valueOrNull ?? [];

    final hasRegion = _selectedRegionId != null && _selectedRegionId!.isNotEmpty;
    final hasZone = _selectedZoneId != null && _selectedZoneId!.isNotEmpty;
    final isNonFarmer = _selectedRole != 'FARMER';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B130E) : const Color(0xFFF7F9F7),
      appBar: AppBar(
        title: const Text('Create Account', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF132116) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF111827),
      ),
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
              constraints: const BoxConstraints(maxWidth: 560),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Brand Header
                      const Center(
                        child: AgriEtechLogo.horizontal(
                          size: 38,
                          showTagline: false,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Error Alert Banner
                      if (authState.error != null) ...[
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
                                    const Text(
                                      'Registration Failed',
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF991B1B)),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      authState.error!.message,
                                      style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // ═══════════════════════════════════════════════════════
                      // Section 1: Account Details
                      // ═══════════════════════════════════════════════════════
                      _buildSectionHeader(
                        icon: Icons.person_outline,
                        title: 'Account details',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF132116) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? const Color(0xFF223826) : const Color(0xFFE5E9E5),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Full Name
                            _buildFieldLabel('Full name', isDark),
                            TextFormField(
                              controller: _fullNameController,
                              textInputAction: TextInputAction.next,
                              enabled: !authState.isLoading,
                              style: TextStyle(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF111827)),
                              decoration: _buildInputDecoration(
                                hint: 'e.g. Abebe Bikila',
                                icon: Icons.person_outline,
                                isDark: isDark,
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Please enter your full name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // Mobile Number
                            _buildFieldLabel('Mobile phone number', isDark),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              enabled: !authState.isLoading,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.4,
                                color: isDark ? Colors.white : const Color(0xFF111827),
                              ),
                              decoration: InputDecoration(
                                hintText: '911 234 567',
                                hintStyle: TextStyle(
                                  color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                                  fontSize: 14,
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
                              validator: (v) => Validators.phone(v),
                            ),
                            const SizedBox(height: 14),

                            // Email Address
                            _buildFieldLabel('Email address', isDark),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              enabled: !authState.isLoading,
                              style: TextStyle(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF111827)),
                              decoration: _buildInputDecoration(
                                hint: 'abebealemu@gmail.com',
                                icon: Icons.email_outlined,
                                isDark: isDark,
                              ),
                              validator: (v) {
                                if (v != null && v.trim().isNotEmpty) {
                                  return Validators.email(v.trim());
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // Password
                            _buildFieldLabel('Password', isDark),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.next,
                              enabled: !authState.isLoading,
                              style: TextStyle(
                                fontSize: 14,
                                letterSpacing: _obscurePassword ? 2.0 : 0.0,
                                color: isDark ? Colors.white : const Color(0xFF111827),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Minimum 8 characters with uppercase and number',
                                hintStyle: TextStyle(
                                  color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                                  fontSize: 13,
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
                                if (value.length < 8) {
                                  return 'Password must be at least 8 characters';
                                }
                                if (!value.contains(RegExp(r'[A-Z]'))) {
                                  return 'Include at least one uppercase letter (A-Z)';
                                }
                                if (!value.contains(RegExp(r'[0-9]'))) {
                                  return 'Include at least one number (0-9)';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // Confirm Password
                            _buildFieldLabel('Confirm password', isDark),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              textInputAction: TextInputAction.next,
                              enabled: !authState.isLoading,
                              style: TextStyle(
                                fontSize: 14,
                                letterSpacing: _obscureConfirmPassword ? 2.0 : 0.0,
                                color: isDark ? Colors.white : const Color(0xFF111827),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Re-enter your password',
                                hintStyle: TextStyle(
                                  color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                                  fontSize: 13,
                                  letterSpacing: 0,
                                ),
                                prefixIcon: const Icon(Icons.lock_outline, size: 18),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    size: 18,
                                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                  ),
                                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
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
                                  return 'Please confirm your password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ═══════════════════════════════════════════════════════
                      // Section 2: Platform Role & Verification Credentials
                      // ═══════════════════════════════════════════════════════
                      _buildSectionHeader(
                        icon: Icons.badge_outlined,
                        title: 'Operational role',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF132116) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? const Color(0xFF223826) : const Color(0xFFE5E9E5),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Role', isDark),
                            _buildRoleSelectorField(isDark),

                            // Dynamic Credential Fields (Only if non-farmer role is selected)
                            if (isNonFarmer) ...[
                              const SizedBox(height: 16),
                              // Organization Name
                              _buildFieldLabel('Organization', isDark),
                              TextFormField(
                                controller: _organizationController,
                                textInputAction: TextInputAction.next,
                                enabled: !authState.isLoading,
                                style: TextStyle(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF111827)),
                                decoration: _buildInputDecoration(
                                  hint: 'e.g. Ministry of Agriculture / Woreda Office / EIAR',
                                  icon: Icons.business_outlined,
                                  isDark: isDark,
                                ),
                                validator: (v) {
                                  if (isNonFarmer && (v == null || v.trim().isEmpty)) {
                                    return 'Organization or agency name is required for official roles';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),

                              // Official Staff ID / Badge Number
                              _buildFieldLabel('Staff ID', isDark),
                              TextFormField(
                                controller: _staffIdController,
                                textInputAction: TextInputAction.next,
                                enabled: !authState.isLoading,
                                style: TextStyle(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF111827)),
                                decoration: _buildInputDecoration(
                                  hint: 'e.g. MOA-ET-2024-884 or AGRI-W-441',
                                  icon: Icons.badge_outlined,
                                  isDark: isDark,
                                ),
                                validator: (v) {
                                  if (isNonFarmer && (v == null || v.trim().isEmpty)) {
                                    return 'Staff ID is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),

                              // Professional Scope / Justification
                              _buildFieldLabel('Jurisdiction', isDark),
                              TextFormField(
                                controller: _justificationController,
                                textInputAction: TextInputAction.next,
                                enabled: !authState.isLoading,
                                style: TextStyle(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF111827)),
                                decoration: _buildInputDecoration(
                                  hint: 'Briefly state your responsibilities',
                                  icon: Icons.description_outlined,
                                  isDark: isDark,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ═══════════════════════════════════════════════════════
                      // Section 3: Administrative Location
                      // ═══════════════════════════════════════════════════════
                      _buildSectionHeader(
                        icon: Icons.location_on_outlined,
                        title: 'Administrative location',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF132116) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? const Color(0xFF223826) : const Color(0xFFE5E9E5),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Region
                            _buildFieldLabel('Region', isDark),
                            DropdownButtonFormField<String>(
                              key: ValueKey('reg_$_selectedRegionId'),
                              initialValue: availableRegions.any((r) => r.id == _selectedRegionId) ? _selectedRegionId : null,
                              decoration: _buildInputDecoration(
                                hint: 'Select administrative region',
                                icon: Icons.public,
                                isDark: isDark,
                              ),
                              items: availableRegions.map((region) {
                                return DropdownMenuItem<String>(
                                  value: region.id,
                                  child: Text(region.name, style: const TextStyle(fontSize: 13.5)),
                                );
                              }).toList(),
                              validator: (v) => v == null || v.isEmpty ? 'Please select your administrative region' : null,
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

                            // Zone
                            _buildFieldLabel(
                              _selectedRole == 'REGIONAL_OFFICER' ? 'Zone (Regional authority)' : 'Zone',
                              isDark,
                            ),
                            DropdownButtonFormField<String>(
                              key: ValueKey('zone_${_selectedRegionId}_$_selectedZoneId'),
                              initialValue: hasRegion && availableZones.any((z) => z.id == _selectedZoneId) ? _selectedZoneId : null,
                              decoration: _buildInputDecoration(
                                hint: !hasRegion
                                    ? 'Select region first'
                                    : (_selectedRole == 'REGIONAL_OFFICER'
                                        ? 'All zones (or specify primary)'
                                        : (availableZones.isEmpty ? 'Loading zones...' : 'Select zone')),
                                icon: Icons.map_outlined,
                                isDark: isDark,
                                isDisabled: !hasRegion,
                              ),
                              items: hasRegion
                                  ? availableZones.map((zone) {
                                      return DropdownMenuItem<String>(
                                        value: zone.id,
                                        child: Text(zone.name, style: const TextStyle(fontSize: 13.5)),
                                      );
                                    }).toList()
                                  : null,
                              validator: (v) {
                                if (_selectedRole != 'REGIONAL_OFFICER' && (v == null || v.isEmpty)) {
                                  return 'Please select your administrative zone';
                                }
                                return null;
                              },
                              onChanged: (!hasRegion || authState.isLoading)
                                  ? null
                                  : (zoneId) {
                                      setState(() {
                                        _selectedZoneId = zoneId;
                                        _selectedWoredaId = null;
                                      });
                                    },
                            ),
                            const SizedBox(height: 14),

                            // Woreda
                            _buildFieldLabel(
                              (_selectedRole == 'REGIONAL_OFFICER' || _selectedRole == 'ZONAL_OFFICER')
                                  ? 'Woreda (Optional)'
                                  : 'Woreda',
                              isDark,
                            ),
                            DropdownButtonFormField<String>(
                              key: ValueKey('woreda_${_selectedZoneId}_$_selectedWoredaId'),
                              initialValue: hasZone && availableWoredas.any((w) => w.id == _selectedWoredaId) ? _selectedWoredaId : null,
                              decoration: _buildInputDecoration(
                                hint: !hasZone
                                    ? (_selectedRole == 'REGIONAL_OFFICER' || _selectedRole == 'ZONAL_OFFICER'
                                        ? 'All woredas in jurisdiction'
                                        : 'Select zone first')
                                    : (availableWoredas.isEmpty ? 'Loading woredas...' : 'Select woreda'),
                                icon: Icons.holiday_village_outlined,
                                isDark: isDark,
                                isDisabled: !hasZone,
                              ),
                              items: hasZone
                                  ? availableWoredas.map((woreda) {
                                      return DropdownMenuItem<String>(
                                        value: woreda.id,
                                        child: Text(woreda.name, style: const TextStyle(fontSize: 13.5)),
                                      );
                                    }).toList()
                                  : null,
                              validator: (v) {
                                if (_selectedRole != 'REGIONAL_OFFICER' &&
                                    _selectedRole != 'ZONAL_OFFICER' &&
                                    (v == null || v.isEmpty)) {
                                  return 'Please select your woreda';
                                }
                                return null;
                              },
                              onChanged: (!hasZone || authState.isLoading)
                                  ? null
                                  : (woredaId) {
                                      setState(() {
                                        _selectedWoredaId = woredaId;
                                      });
                                    },
                            ),
                            const SizedBox(height: 14),

                            // Kebele
                            _buildFieldLabel(
                              (_selectedRole == 'REGIONAL_OFFICER' || _selectedRole == 'ZONAL_OFFICER')
                                  ? 'Kebele (Optional)'
                                  : 'Kebele',
                              isDark,
                            ),
                            TextFormField(
                              controller: _kebeleController,
                              textInputAction: TextInputAction.done,
                              enabled: !authState.isLoading,
                              style: TextStyle(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF111827)),
                              decoration: _buildInputDecoration(
                                hint: 'e.g. Kebele 03',
                                icon: Icons.signpost_outlined,
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ═══════════════════════════════════════════════════════
                      // Section 4: Preferred Language
                      // ═══════════════════════════════════════════════════════
                      _buildSectionHeader(
                        icon: Icons.language_outlined,
                        title: 'Choose your preferred language',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF132116) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? const Color(0xFF223826) : const Color(0xFFE5E9E5),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Language', isDark),
                            _buildLanguageSelectorField(isDark),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Terms of Service Checkbox (10px radius)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: _termsError ? const Color(0xFFFEF2F2) : (isDark ? const Color(0xFF132116) : Colors.white),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _termsError ? const Color(0xFFEF4444) : (isDark ? const Color(0xFF223826) : const Color(0xFFE5E9E5)),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: Checkbox(
                                value: _acceptTerms,
                                activeColor: const Color(0xFF1B5E20),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                                onChanged: authState.isLoading
                                    ? null
                                    : (val) {
                                        setState(() {
                                          _acceptTerms = val ?? false;
                                          if (_acceptTerms) _termsError = false;
                                        });
                                      },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'I agree to the Terms of Service and data privacy policies.',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: _termsError
                                      ? const Color(0xFF991B1B)
                                      : (isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Submit Registration Button
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: authState.isLoading ? null : _register,
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
                                      'Create account',
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
                      const SizedBox(height: 20),

                      // Sign In Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(
                              fontSize: 13.5,
                              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                            ),
                          ),
                          InkWell(
                            onTap: authState.isLoading ? null : () => context.go('/login'),
                            child: const Text(
                              'Sign in',
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

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1B3822) : const Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 15, color: const Color(0xFF1B5E20)),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: isDark ? Colors.white : const Color(0xFF111827),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Divider(
          height: 1,
          thickness: 1,
          color: isDark ? const Color(0xFF26382A) : const Color(0xFFE5E7EB),
        ),
      ],
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

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    required bool isDark,
    bool isDisabled = false,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
        fontSize: 13.5,
      ),
      prefixIcon: Icon(
        icon,
        size: 18,
        color: isDisabled
            ? (isDark ? Colors.grey.shade700 : Colors.grey.shade400)
            : (isDark ? const Color(0xFFA7F3D0) : const Color(0xFF1B5E20)),
      ),
      filled: true,
      fillColor: isDisabled
          ? (isDark ? const Color(0xFF101912) : const Color(0xFFF3F4F6))
          : (isDark ? const Color(0xFF0E1A11) : const Color(0xFFF9FAFB)),
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
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
    );
  }
}
