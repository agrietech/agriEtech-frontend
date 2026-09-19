import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_view.dart';
import '../models/mfa_model.dart';
import '../providers/auth_provider.dart';

class MfaSetupScreen extends ConsumerStatefulWidget {
  const MfaSetupScreen({super.key});

  @override
  ConsumerState<MfaSetupScreen> createState() => _MfaSetupScreenState();
}

class _MfaSetupScreenState extends ConsumerState<MfaSetupScreen> {
  bool _isLoading = false;
  MfaSetupResponse? _setupData;
  String? _error;
  final _verificationController = TextEditingController();
  bool _isVerifying = false;
  bool _showBackupCodes = false;

  @override
  void initState() {
    super.initState();
    _initiateMfaSetup();
  }

  @override
  void dispose() {
    _verificationController.dispose();
    super.dispose();
  }

  Future<void> _initiateMfaSetup() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ref.read(authProvider.notifier).setupMfa();
      setState(() {
        _setupData = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyAndEnable() async {
    if (_verificationController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit code')),
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final success = await ref
          .read(authProvider.notifier)
          .verifyMfa(_verificationController.text);

      if (success && mounted) {
        setState(() {
          _isVerifying = false;
          _showBackupCodes = true;
        });
      } else if (mounted) {
        setState(() => _isVerifying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Invalid code. Please try again.'),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isVerifying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enable Two-Factor Authentication'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: AppLoadingIndicator())
          : _error != null
              ? AppErrorView(
                  title: 'Setup Failed',
                  message: _error!,
                  onRetry: _initiateMfaSetup,
                )
              : _showBackupCodes
                  ? _buildBackupCodesView()
                  : _buildSetupView(),
    );
  }

  Widget _buildSetupView() {
    if (_setupData == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: const Color(0xFF0891B2).withValues(alpha: 0.1),
              borderRadius: AppRadius.radiusMd,
              border: Border.all(color: const Color(0xFF0891B2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.security, color: Color(0xFF0891B2)),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Two-factor authentication adds an extra layer of security to your account',
                    style: AppTypography.bodySmall,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Step 1: Scan QR Code
          const Text(
            'Step 1: Scan QR Code',
            style: AppTypography.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Use an authenticator app (Google Authenticator, Authy, etc.) to scan this QR code:',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),

          Center(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.radiusMd,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Image.memory(
                _decodeBase64(_setupData!.qrCode),
                width: 200,
                height: 200,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error, size: 200),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Manual Entry Option
          const Text(
            'Or enter this code manually:',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: AppRadius.radiusSm,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _setupData!.secret,
                    style: AppTypography.bodyMedium.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _setupData!.secret));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Secret copied to clipboard')),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Step 2: Verify Code
          const Text(
            'Step 2: Enter Verification Code',
            style: AppTypography.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Enter the 6-digit code from your authenticator app:',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),

          TextField(
            controller: _verificationController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: AppTypography.headlineMedium.copyWith(
              letterSpacing: 8,
              fontWeight: FontWeight.bold,
            ),
            decoration: const InputDecoration(
              hintText: '000000',
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: AppRadius.radiusMd,
              ),
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),

          const SizedBox(height: AppSpacing.lg),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isVerifying ? null : _verifyAndEnable,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(AppSpacing.md),
                backgroundColor: const Color(0xFF16A34A),
              ),
              child: _isVerifying
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Verify and Enable'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupCodesView() {
    if (_setupData == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xFF16A34A),
            size: 64,
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Two-Factor Authentication Enabled!',
            style: AppTypography.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),

          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: const Color(0xFFD97706).withValues(alpha: 0.1),
              borderRadius: AppRadius.radiusMd,
              border: Border.all(color: const Color(0xFFD97706)),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_rounded, color: Color(0xFFD97706)),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Save these backup codes in a safe place. You can use them to access your account if you lose your phone.',
                    style: AppTypography.bodySmall,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          const Text(
            'Backup Recovery Codes',
            style: AppTypography.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),

          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.radiusMd,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: _setupData!.backupCodes
                  .map((code) => Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xs),
                        child: Text(
                          code,
                          style: AppTypography.bodyLarge.copyWith(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final codesText = _setupData!.backupCodes.join('\n');
                Clipboard.setData(ClipboardData(text: codesText));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Backup codes copied to clipboard')),
                );
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copy All Codes'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(AppSpacing.md),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(AppSpacing.md),
              ),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }

  Uint8List _decodeBase64(String base64String) {
    try {
      // Remove data:image/png;base64, prefix if present
      final base64Data = base64String.contains(',')
          ? base64String.split(',')[1]
          : base64String;
      return const Base64Decoder().convert(base64Data);
    } catch (e) {
      return Uint8List(0);
    }
  }
}

class Base64Decoder {
  const Base64Decoder();

  Uint8List convert(String input) {
    return Uint8List.fromList(
      input.codeUnits.map((c) => c & 0xFF).toList(),
    );
  }
}
