import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/repositories/auth_repository.dart';
import '../../../core/utils/validators.dart';
import '../../../core/error/error_handler.dart';
import '../../../core/error/app_error.dart';
import '../../../core/theme/app_theme.dart';

/// Professional dialog for requesting password reset via Phone/Email and entering new password
class ForgotPasswordDialog extends ConsumerStatefulWidget {
  const ForgotPasswordDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const ForgotPasswordDialog(),
    );
  }

  @override
  ConsumerState<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends ConsumerState<ForgotPasswordDialog> {
  final _requestFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();
  
  final _identifierController = TextEditingController();
  final _tokenController = TextEditingController();
  final _newPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _codeSent = false;
  bool _passwordResetSuccess = false;
  bool _obscurePassword = true;

  int _remainingSeconds = 300; // 5 minutes
  Timer? _countdownTimer;

  String get _formattedRemainingTime {
    final m = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _remainingSeconds = 300);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        if (mounted) setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _identifierController.dispose();
    _tokenController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendResetCode() async {
    if (_requestFormKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final identifier = _identifierController.text.trim();
        final authRepo = ref.read(authRepositoryProvider);
        await authRepo.requestPasswordReset(identifier);

        if (mounted) {
          setState(() {
            _isLoading = false;
            _codeSent = true;
          });
          _startCountdown();
        }
      } on AppError catch (e) {

        if (mounted) {
          setState(() => _isLoading = false);
          ErrorHandler.showErrorSnackBar(context, e);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to send reset code: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _submitNewPassword() async {
    if (_resetFormKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final token = _tokenController.text.trim();
        final newPassword = _newPasswordController.text;
        final authRepo = ref.read(authRepositoryProvider);
        await authRepo.resetPassword(token: token, newPassword: newPassword);

        if (mounted) {
          setState(() {
            _isLoading = false;
            _passwordResetSuccess = true;
          });
        }
      } on AppError catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ErrorHandler.showErrorSnackBar(context, e);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Password reset failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadii.roundedXl,
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1B5E20).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_reset,
              color: Color(0xFF1B5E20),
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            _passwordResetSuccess
                ? 'Password Reset'
                : (_codeSent ? 'Set New Password' : 'Reset Password'),
            style: AppTypography.titleMedium,
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: _passwordResetSuccess
            ? const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF2E7D32),
                    size: 54,
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'Your password has been successfully updated!\nYou can now sign in with your new password.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall,
                  ),
                ],
              )
            : _codeSent
                ? Form(
                    key: _resetFormKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.1),
                            borderRadius: AppRadii.roundedSm,
                            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.mark_email_read_outlined, color: Color(0xFF059669), size: 20),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  'A 6-digit verification code has been sent to ${_identifierController.text.trim()}.',
                                  style: AppTypography.caption.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF065F46),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: _remainingSeconds > 60
                                ? const Color(0xFFE8F5E9)
                                : const Color(0xFFFEF2F2),
                            borderRadius: AppRadii.roundedSm,
                            border: Border.all(
                              color: _remainingSeconds > 60
                                  ? const Color(0xFF81C784)
                                  : const Color(0xFFEF5350),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.timer_outlined,
                                    size: 16,
                                    color: _remainingSeconds > 60
                                        ? const Color(0xFF2E7D32)
                                        : const Color(0xFFC62828),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    _remainingSeconds > 0
                                        ? 'Code valid for: $_formattedRemainingTime'
                                        : 'Code expired (5-min window)',
                                    style: AppTypography.caption.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: _remainingSeconds > 60
                                          ? const Color(0xFF1B5E20)
                                          : const Color(0xFFB71C1C),
                                    ),
                                  ),
                                ],
                              ),
                              if (_remainingSeconds == 0)
                                TextButton(
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  onPressed: _isLoading ? null : _sendResetCode,
                                  child: Text(
                                    'Resend Code',
                                    style: AppTypography.caption.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF2E7D32),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _tokenController,

                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            letterSpacing: 6,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: const InputDecoration(
                            labelText: '6-Digit Reset Code (OTP)',
                            prefixIcon: Icon(Icons.pin_outlined),
                            helperText: 'Enter the 6-digit number received in your email',
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter the 6-digit reset code';
                            }
                            final clean = val.trim();
                            if (clean.length < 6) {
                              return 'Code must be at least 6 characters';
                            }
                            return null;
                          },
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          controller: _newPasswordController,
                          decoration: InputDecoration(
                            labelText: 'New Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          obscureText: _obscurePassword,
                          validator: Validators.password,
                          enabled: !_isLoading,
                        ),
                      ],
                    ),
                  )
                : Form(
                    key: _requestFormKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enter your Email Address or Phone Number to receive a 6-digit password reset code.',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _identifierController,
                          decoration: const InputDecoration(
                            labelText: 'Email Address or Phone Number',
                            prefixIcon: Icon(Icons.mail_outline),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _sendResetCode(),
                          validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter email or phone' : null,
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => setState(() => _codeSent = true),
                            child: const Text(
                              'I already have a 6-digit code',
                              style: AppTypography.caption,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
      actions: [
        if (_passwordResetSuccess)
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Sign In Now'),
          )
        else if (_codeSent) ...[
          TextButton(
            onPressed: _isLoading ? null : () => setState(() => _codeSent = false),
            child: const Text('Back'),
          ),
          FilledButton(
            onPressed: _isLoading ? null : _submitNewPassword,
            child: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Update Password'),
          ),
        ] else ...[
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: _isLoading ? null : _sendResetCode,
            child: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Send Reset Code'),
          ),
        ],
      ],
    );
  }
}

