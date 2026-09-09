import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../../core/error/error_handler.dart';
import '../../../core/error/app_error.dart';

/// Enterprise Out-of-Band Phone Ownership Verification Dialog
class VerifyPhoneDialog extends ConsumerStatefulWidget {
  final String phone;
  final VoidCallback? onSuccess;

  const VerifyPhoneDialog({
    super.key,
    required this.phone,
    this.onSuccess,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String phone,
    VoidCallback? onSuccess,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => VerifyPhoneDialog(phone: phone, onSuccess: onSuccess),
    );
  }

  @override
  ConsumerState<VerifyPhoneDialog> createState() => _VerifyPhoneDialogState();
}

class _VerifyPhoneDialogState extends ConsumerState<VerifyPhoneDialog> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  String? _successMessage;
  int _cooldownSeconds = 60;
  Timer? _cooldownTimer;

  String get _formattedCooldown {
    final s = _cooldownSeconds.toString().padLeft(2, '0');
    return '00:$s';
  }

  String get _displayPhone {
    final raw = widget.phone.trim();
    if (raw.startsWith('+251') && raw.length == 13) {
      return '+251 ${raw.substring(4, 6)} ${raw.substring(6, 9)} ${raw.substring(9)}';
    }
    if (raw.startsWith('09') && raw.length == 10) {
      return '09${raw.substring(2, 4)} ${raw.substring(4, 7)} ${raw.substring(7)}';
    }
    if (raw.startsWith('07') && raw.length == 10) {
      return '07${raw.substring(2, 4)} ${raw.substring(4, 7)} ${raw.substring(7)}';
    }
    return raw;
  }

  @override
  void initState() {
    super.initState();
    _startCooldown();
    _otpController.addListener(_onOtpChanged);
  }

  void _onOtpChanged() {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
    final text = _otpController.text.trim();
    if (text.length == 6 && !_isLoading) {
      _verifyCode();
    }
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _cooldownSeconds = 60);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds > 0) {
        if (mounted) setState(() => _cooldownSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _otpController.removeListener(_onOtpChanged);
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    if (_isLoading) return;
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final code = _otpController.text.trim();
        await ref.read(authProvider.notifier).verifyPhoneOtp(
              phone: widget.phone,
              code: code,
            );

        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.of(context).pop(true);
          widget.onSuccess?.call();
        }
      } on AppError catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = ErrorHandler.getUserMessage(e);
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Verification failed: ${e.toString().replaceAll("Exception: ", "")}';
          });
        }
      }
    }
  }

  Future<void> _resendCode() async {
    if (_cooldownSeconds > 0 || _isResending) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await ref.read(authProvider.notifier).resendPhoneOtp(widget.phone);

      if (mounted) {
        setState(() {
          _isResending = false;
          _successMessage = 'A new 6-digit verification code has been sent via SMS.';
        });
        _startCooldown();
      }
    } on AppError catch (e) {
      if (mounted) {
        setState(() {
          _isResending = false;
          _errorMessage = ErrorHandler.getUserMessage(e);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isResending = false;
          _errorMessage = 'Failed to resend code: ${e.toString().replaceAll("Exception: ", "")}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: isDark ? const Color(0xFF132116) : Colors.white,
      titlePadding: const EdgeInsets.fromLTRB(20, 18, 14, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1B5E20).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.phonelink_lock,
              color: Color(0xFF1B5E20),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verify Phone Number',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                Text(
                  'የስልክ ቁጥር ማረጋገጫ',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20, color: Colors.grey),
            tooltip: 'Cancel',
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notice Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F291E) : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? const Color(0xFF1B5E20) : const Color(0xFFA5D6A7),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.sms_outlined, color: Color(0xFF2E7D32), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDark ? const Color(0xFFA7F3D0) : const Color(0xFF1B5E20),
                            height: 1.4,
                          ),
                          children: [
                            const TextSpan(text: 'A 6-digit code has been sent via SMS to '),
                            TextSpan(
                              text: _displayPhone,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(text: '. Enter the code to verify ownership and activate your account.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Inline Error Banner
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFB91C1C),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Inline Success Banner
              if (_successMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: Color(0xFF16A34A), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _successMessage!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF15803D),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // OTP Input Field
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                autofocus: true,
                textAlign: TextAlign.center,
                enabled: !_isLoading,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: InputDecoration(
                  labelText: '6-Digit Verification Code',
                  hintText: '• • • • • •',
                  alignLabelWithHint: true,
                  floatingLabelAlignment: FloatingLabelAlignment.center,
                  prefixIcon: const Icon(Icons.pin, color: Color(0xFF1B5E20)),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0E1A11) : const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF2E4D33) : const Color(0xFFE5E7EB),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF1B5E20), width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFDC2626)),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Verification code is required';
                  }
                  if (val.trim().length != 6) {
                    return 'Must be exactly 6 digits';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 18),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Verify & Activate Account',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                ),
              ),

              const SizedBox(height: 12),

              // Resend Code Button
              Center(
                child: TextButton.icon(
                  onPressed: _cooldownSeconds > 0 || _isResending || _isLoading ? null : _resendCode,
                  icon: _isResending
                      ? const SizedBox(
                          height: 14,
                          width: 14,
                          child: CircularProgressIndicator(strokeWidth: 1.5),
                        )
                      : const Icon(Icons.refresh, size: 16),
                  label: Text(
                    _cooldownSeconds > 0
                        ? 'Resend Code in $_formattedCooldown'
                        : 'Resend Code via SMS',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _cooldownSeconds > 0 ? Colors.grey : const Color(0xFF1B5E20),
                    ),
                  ),
                ),
              ),

              Center(
                child: TextButton(
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancel / Change details',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
