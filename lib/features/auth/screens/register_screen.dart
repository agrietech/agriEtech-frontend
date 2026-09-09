import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../core/utils/validators.dart';
import '../../boundaries/providers/boundary_provider.dart';
import 'verify_phone_dialog.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  int _currentStep = 0;

  final _formKeyStep0 = GlobalKey<FormState>();
  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();

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
  String? _detectedCarrier;

  static const List<Map<String, dynamic>> _roleOptions = [
    {
      'id': 'FARMER',
      'title': 'Smallholder Farmer',
      'amharic': 'አርሶ አደር',
      'icon': Icons.agriculture_rounded,
      'color': Color(0xFF16A34A),
      'desc': 'Direct agronomic advisories, farm plot registration, and instant weather/pest USSD warnings.',
      'requiresInstitutional': false,
    },
    {
      'id': 'DEVELOPMENT_AGENT',
      'title': 'Development Agent (DA)',
      'amharic': 'የልማት ጣቢያ ባለሙያ',
      'icon': Icons.support_agent_rounded,
      'color': Color(0xFF0284C7),
      'desc': 'Kebele-level farmer plot registration, IoT soil sensor deployment, and field pest surveillance.',
      'requiresInstitutional': true,
    },
    {
      'id': 'WOREDA_OFFICER',
      'title': 'Woreda Agronomy Officer',
      'amharic': 'የወረዳ ግብርና መኮንን',
      'icon': Icons.admin_panel_settings_rounded,
      'color': Color(0xFFD97706),
      'desc': 'Woreda disaster alerts broadcast, USSD *212# farmer delivery, and GIS spatial hazard tracking.',
      'requiresInstitutional': true,
    },
    {
      'id': 'ZONAL_OFFICER',
      'title': 'Zonal Agricultural Lead',
      'amharic': 'የዞን ግብርና መምሪያ',
      'icon': Icons.domain_rounded,
      'color': Color(0xFF7C3AED),
      'desc': 'Cross-woreda analytics, SPI drought indexing, river basin flood telemetry, and input planning.',
      'requiresInstitutional': true,
    },
    {
      'id': 'REGIONAL_OFFICER',
      'title': 'Regional Bureau Director',
      'amharic': 'የክልል ግብርና ቢሮ',
      'icon': Icons.account_balance_rounded,
      'color': Color(0xFFDC2626),
      'desc': 'Regional command dashboard, seismic fault surveillance, food security models, and emergency response.',
      'requiresInstitutional': true,
    },
    {
      'id': 'RESEARCHER',
      'title': 'Agricultural Scientist',
      'amharic': 'ተመራማሪ / ሳይንቲስት',
      'icon': Icons.biotech_rounded,
      'color': Color(0xFF0D9488),
      'desc': 'Access to Sentinel-2 satellite time-series, digital soil maps, downscaled climate models, and data exports.',
      'requiresInstitutional': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(authProvider.notifier).clearError();
      ref.read(boundaryHierarchyProvider.notifier).loadRegions();
    });

    _phoneController.addListener(_onPhoneChanged);
    _passwordController.addListener(() => setState(() {}));
  }

  void _onPhoneChanged() {
    final clean = _phoneController.text.replaceAll(RegExp(r'[\s\-\(\)]'), '');
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

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
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

  void _nextStep() {
    ref.read(authProvider.notifier).clearError();
    if (_currentStep == 0) {
      if (_formKeyStep0.currentState!.validate()) {
        setState(() => _currentStep = 1);
      }
    } else if (_currentStep == 1) {
      final isNonFarmer = _selectedRole != 'FARMER';
      if (isNonFarmer) {
        if (_formKeyStep1.currentState!.validate()) {
          setState(() => _currentStep = 2);
        }
      } else {
        setState(() => _currentStep = 2);
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitRegistration() async {
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

    if (!_formKeyStep2.currentState!.validate()) return;

    try {
      final isNonFarmer = _selectedRole != 'FARMER';

      final regResult = await ref.read(authProvider.notifier).register(
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
        if (regResult.requiresPhoneVerification) {
          final verified = await VerifyPhoneDialog.show(
            context,
            phone: regResult.phone,
          );

          if (mounted) {
            if (verified == true) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.verified, color: Colors.white, size: 18),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Phone verified! Welcome to EthioFarm.',
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
              context.go('/login');
            }
          }
        } else {
          context.go('/home');
        }
      }
    } catch (_) {
      // Error rendered via authProvider
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B130E) : const Color(0xFFF7F9F7),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0F1E13) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentStep > 0) {
              _previousStep();
            } else {
              context.go('/login');
            }
          },
        ),
        title: const Text(
          'Register Account',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                // Stepper Header Progress Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  color: isDark ? const Color(0xFF132116) : Colors.white,
                  child: Row(
                    children: [
                      _buildStepIndicator(0, 'Identity', _currentStep >= 0, _currentStep == 0),
                      _buildStepConnector(_currentStep >= 1),
                      _buildStepIndicator(1, 'Role', _currentStep >= 1, _currentStep == 1),
                      _buildStepConnector(_currentStep >= 2),
                      _buildStepIndicator(2, 'Jurisdiction', _currentStep >= 2, _currentStep == 2),
                    ],
                  ),
                ),

                // Error Banner
                if (authState.error != null)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            authState.error!.message,
                            style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Stepper View Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: IndexedStack(
                      index: _currentStep,
                      children: [
                        _buildStep0Identity(isDark),
                        _buildStep1Role(isDark),
                        _buildStep2Jurisdiction(isDark),
                      ],
                    ),
                  ),
                ),

                // Bottom Controls Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF132116) : Colors.white,
                    border: Border(
                      top: BorderSide(color: isDark ? const Color(0xFF223826) : const Color(0xFFE5E7EB)),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (_currentStep > 0) ...[
                        OutlinedButton.icon(
                          onPressed: _previousStep,
                          icon: const Icon(Icons.arrow_back, size: 16),
                          label: const Text('Back'),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            key: _currentStep == 2 ? const Key('register_submit_button') : const Key('stepper_continue_button'),
                            onPressed: authState.isLoading
                                ? null
                                : (_currentStep == 2 ? _submitRegistration : _nextStep),
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
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _currentStep == 2 ? 'Create Account' : 'Continue',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(_currentStep == 2 ? Icons.check_circle_rounded : Icons.arrow_forward_rounded, size: 18),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int stepIndex, String title, bool isCompleted, bool isActive) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? const Color(0xFF1B5E20) : (isActive ? const Color(0xFF16A34A) : Colors.grey.shade300),
            ),
            child: Center(
              child: isCompleted && !isActive
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : Text(
                      '${stepIndex + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: isCompleted || isActive ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? const Color(0xFF1B5E20) : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(bool isCompleted) {
    return Container(
      width: 24,
      height: 2,
      color: isCompleted ? const Color(0xFF1B5E20) : Colors.grey.shade300,
      margin: const EdgeInsets.only(bottom: 16),
    );
  }

  // ──────────────── STEP 0: IDENTITY ────────────────
  Widget _buildStep0Identity(bool isDark) {
    return Form(
      key: _formKeyStep0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Step 1 of 3: Identity & Security', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 4),
          Text(
            'Provide your legal name and verified Ethiopian mobile number',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),

          // Full Name
          _buildFieldLabel('Full Name', isDark, isRequired: true),
          TextFormField(
            controller: _fullNameController,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration('e.g. Abebe Balcha (አበበ ባልቻ)', Icons.person_outline, isDark),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Full name is required';
              if (v.trim().length < 3) return 'Name must be at least 3 characters';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Mobile Phone
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: _buildFieldLabel('Ethiopian Mobile Phone', isDark, isRequired: true),
              ),
              if (_detectedCarrier != null)
                Text(
                  _detectedCarrier!,
                  style: const TextStyle(color: Color(0xFF1B5E20), fontSize: 10, fontWeight: FontWeight.bold),
                ),
            ],
          ),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration('911 234 567', Icons.phone_outlined, isDark, prefixText: '+251 '),
            validator: (v) => Validators.phone(v),
          ),
          const SizedBox(height: 16),

          // Email (Optional)
          _buildFieldLabel('Email Address (Optional)', isDark),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration('officer@ethiofarm.et', Icons.email_outlined, isDark),
            validator: (v) {
              if (v != null && v.trim().isNotEmpty) {
                return Validators.email(v.trim());
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Password
          _buildFieldLabel('Create Password', isDark, isRequired: true),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              'Minimum 8 chars with uppercase & number',
              Icons.lock_outline,
              isDark,
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (v) => Validators.password(v),
          ),
          _buildPasswordStrengthMeter(_passwordController.text),
          const SizedBox(height: 16),

          // Confirm Password
          _buildFieldLabel('Confirm Password', isDark, isRequired: true),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            decoration: _inputDecoration(
              'Re-enter your password',
              Icons.lock_clock_outlined,
              isDark,
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18),
                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
            ),
            validator: (v) => Validators.confirmPassword(v, _passwordController.text),
          ),
          const SizedBox(height: 18),

          // Preferred Language
          _buildFieldLabel('Preferred System Language', isDark),
          Wrap(
            spacing: 8,
            children: [
              _buildLangChip('am', 'አማርኛ (Amharic)'),
              _buildLangChip('om', 'Afaan Oromoo'),
              _buildLangChip('en', 'English'),
              _buildLangChip('ti', 'ትግርኛ (Tigrinya)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLangChip(String code, String label) {
    final isSelected = _selectedLang == code;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedLang = code),
      selectedColor: const Color(0xFF1B5E20),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
    );
  }

  Widget _buildPasswordStrengthMeter(String pass) {
    if (pass.isEmpty) return const SizedBox.shrink();
    int score = 0;
    if (pass.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(pass)) score++;
    if (RegExp(r'[0-9]').hasMatch(pass)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(pass)) score++;

    Color color = Colors.red;
    String label = 'Weak';
    if (score == 2) {
      color = Colors.orange;
      label = 'Fair';
    } else if (score == 3) {
      color = Colors.blue;
      label = 'Good';
    } else if (score >= 4) {
      color = const Color(0xFF16A34A);
      label = 'Strong';
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: score / 4.0,
                color: color,
                backgroundColor: Colors.grey.shade300,
                minHeight: 4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
        ],
      ),
    );
  }

  // ──────────────── STEP 1: ROLE SELECTION ────────────────
  Widget _buildStep1Role(bool isDark) {
    final selectedRoleData = _roleOptions.firstWhere((r) => r['id'] == _selectedRole);
    final requiresInstitutional = selectedRoleData['requiresInstitutional'] as bool;

    return Form(
      key: _formKeyStep1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Step 2 of 3: Role & Mandate Selection', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 4),
          Text(
            'Select your institutional or agricultural role within the Ethiopian agricultural framework',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 18),

          ..._roleOptions.map((role) {
            final isSelected = _selectedRole == role['id'];
            final color = role['color'] as Color;
            return Card(
              key: Key('role_card_${role['id']}'),
              margin: const EdgeInsets.only(bottom: 12),
              elevation: isSelected ? 2 : 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isSelected ? color : (isDark ? const Color(0xFF26382A) : const Color(0xFFE5E7EB)),
                  width: isSelected ? 2.0 : 1.0,
                ),
              ),
              color: isSelected
                  ? color.withValues(alpha: isDark ? 0.15 : 0.05)
                  : (isDark ? const Color(0xFF132116) : Colors.white),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => setState(() => _selectedRole = role['id']),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(role['icon'] as IconData, color: color, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  role['title'] as String,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                if (isSelected)
                                  Icon(Icons.check_circle_rounded, color: color, size: 18),
                              ],
                            ),
                            Text(
                              role['amharic'] as String,
                              style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              role['desc'] as String,
                              style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          // Institutional Fields if Officer / Researcher
          if (requiresInstitutional) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1B2E1E) : const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF86EFAC)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.verified_user_rounded, color: Color(0xFF16A34A), size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text('Institutional Mandate Verification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Administrative roles require institutional affiliation verified by the woreda/regional agriculture office.',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                  const SizedBox(height: 14),

                  _buildFieldLabel('Organization / Agricultural Bureau', isDark, isRequired: true),
                  TextFormField(
                    controller: _organizationController,
                    textInputAction: TextInputAction.next,
                    decoration: _inputDecoration('e.g. Oromia Bureau of Agriculture / EIAR', Icons.apartment_rounded, isDark),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Organization name is required' : null,
                  ),
                  const SizedBox(height: 12),

                  _buildFieldLabel('Staff ID / Official Badge Number', isDark, isRequired: true),
                  TextFormField(
                    controller: _staffIdController,
                    textInputAction: TextInputAction.next,
                    decoration: _inputDecoration('e.g. MOA-ET-2024-8841', Icons.badge_rounded, isDark),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Official staff ID is required' : null,
                  ),
                  const SizedBox(height: 12),

                  _buildFieldLabel('Official Mandate Justification', isDark, isRequired: true),
                  TextFormField(
                    controller: _justificationController,
                    maxLines: 2,
                    decoration: _inputDecoration('Briefly state your operational role and jurisdiction...', Icons.description_rounded, isDark),
                    validator: (v) => (v == null || v.trim().length < 10) ? 'Provide at least 10 characters justifying role' : null,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ──────────────── STEP 2: JURISDICTION ────────────────
  Widget _buildStep2Jurisdiction(bool isDark) {
    final hierarchyState = ref.watch(boundaryHierarchyProvider);
    final hierarchyNotifier = ref.read(boundaryHierarchyProvider.notifier);

    return Form(
      key: _formKeyStep2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Step 3 of 3: Administrative Jurisdiction', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 4),
          Text(
            'Select your geographic territory in Ethiopia for hazard alerts and USSD coverage',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),

          // Region
          _buildFieldLabel('Administrative Region', isDark, isRequired: true),
          DropdownButtonFormField<String>(
            initialValue: _selectedRegionId,
            isExpanded: true,
            decoration: _inputDecoration('Select Region', Icons.public_rounded, isDark),
            items: hierarchyState.regions.map((reg) {
              return DropdownMenuItem(value: reg.id, child: Text(reg.name));
            }).toList(),
            onChanged: (val) {
              setState(() {
                _selectedRegionId = val;
                _selectedZoneId = null;
                _selectedWoredaId = null;
              });
              if (val != null) {
                final match = hierarchyState.regions.where((r) => r.id == val).firstOrNull;
                hierarchyNotifier.selectRegion(match);
              }
            },
            validator: (v) => v == null ? 'Please select a region' : null,
          ),
          const SizedBox(height: 16),

          // Zone
          _buildFieldLabel('Administrative Zone', isDark),
          DropdownButtonFormField<String>(
            initialValue: _selectedZoneId,
            isExpanded: true,
            decoration: _inputDecoration('Select Zone', Icons.domain_rounded, isDark),
            items: hierarchyState.zones.map((zone) {
              return DropdownMenuItem(value: zone.id, child: Text(zone.name));
            }).toList(),
            onChanged: _selectedRegionId == null
                ? null
                : (val) {
                    setState(() {
                      _selectedZoneId = val;
                      _selectedWoredaId = null;
                    });
                    if (val != null) {
                      final match = hierarchyState.zones.where((z) => z.id == val).firstOrNull;
                      hierarchyNotifier.selectZone(match);
                    }
                  },
          ),
          const SizedBox(height: 16),

          // Woreda
          _buildFieldLabel('Woreda (District)', isDark),
          DropdownButtonFormField<String>(
            initialValue: _selectedWoredaId,
            isExpanded: true,
            decoration: _inputDecoration('Select Woreda', Icons.location_city_rounded, isDark),
            items: hierarchyState.woredas.map((wor) {
              return DropdownMenuItem(value: wor.id, child: Text(wor.name));
            }).toList(),
            onChanged: _selectedZoneId == null
                ? null
                : (val) {
                    setState(() => _selectedWoredaId = val);
                    if (val != null) {
                      final match = hierarchyState.woredas.where((w) => w.id == val).firstOrNull;
                      hierarchyNotifier.selectWoreda(match);
                    }
                  },
          ),
          const SizedBox(height: 16),

          // Kebele Name
          _buildFieldLabel('Kebele Name (Local Village)', isDark),
          TextFormField(
            controller: _kebeleController,
            decoration: _inputDecoration('e.g. Kebele 01 / Dobi Korme', Icons.holiday_village_rounded, isDark),
          ),
          const SizedBox(height: 24),

          // Terms & Agreement
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF132116) : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _termsError ? const Color(0xFFDC2626) : (isDark ? const Color(0xFF26382A) : const Color(0xFFE5E7EB)),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: _acceptTerms,
                    activeColor: const Color(0xFF1B5E20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onChanged: (val) => setState(() {
                      _acceptTerms = val ?? false;
                      if (_acceptTerms) _termsError = false;
                    }),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'I certify that the information provided is accurate and agree to the EthioFarm Terms of Service and data protection guidelines.',
                    style: TextStyle(
                      fontSize: 12,
                      color: _termsError ? const Color(0xFFDC2626) : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon, bool isDark, {String? prefixText, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
        fontSize: 13.5,
      ),
      prefixIcon: Icon(icon, size: 18, color: const Color(0xFF1B5E20)),
      prefixText: prefixText,
      prefixStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1B5E20)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: isDark ? const Color(0xFF0E1A11) : const Color(0xFFF9FAFB),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: isDark ? const Color(0xFF26382A) : const Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1B5E20), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
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
                    style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold),
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}
