import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/repositories/auth_repository.dart';
import '../../../core/utils/validators.dart';
import '../../../core/error/error_handler.dart';
import '../../../core/error/app_error.dart';

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

  @override
  void dispose() {
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
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
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
          const SizedBox(width: 12),
          Text(
            _passwordResetSuccess
                ? 'Password Reset'
                : (_codeSent ? 'Set New Password' : 'Reset Password'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: _passwordResetSuccess
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF2E7D32),
                    size: 54,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your password has been successfully updated!\nYou can now sign in with your new password.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
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
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.mark_email_read_outlined, color: Color(0xFF059669), size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'A 6-digit verification code has been sent to ${_identifierController.text.trim()}.',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF065F46),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
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
                            hintText: '123456',
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
                        const SizedBox(height: 14),
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
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _identifierController,
                          decoration: const InputDecoration(
                            labelText: 'Email Address or Phone',
                            hintText: 'user@example.com or 0911...',
                            prefixIcon: Icon(Icons.mail_outline),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _sendResetCode(),
                          validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter email or phone' : null,
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => setState(() => _codeSent = true),
                            child: const Text(
                              'I already have a 6-digit code',
                              style: TextStyle(fontSize: 12),
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

