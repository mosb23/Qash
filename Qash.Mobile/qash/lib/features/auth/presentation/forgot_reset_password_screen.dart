import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/entities/auth_requests.dart';
import '../providers/auth_providers.dart';
import 'widgets/auth_password_field.dart';

class ForgotResetPasswordScreen extends ConsumerStatefulWidget {
  final String? phoneNumber;
  final String? verificationCode;

  const ForgotResetPasswordScreen({
    super.key,
    this.phoneNumber,
    this.verificationCode,
  });

  @override
  ConsumerState<ForgotResetPasswordScreen> createState() =>
      _ForgotResetPasswordScreenState();
}

class _ForgotResetPasswordScreenState
    extends ConsumerState<ForgotResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _resetPassword() async {
    final phone = widget.phoneNumber?.trim() ?? '';
    final code = widget.verificationCode?.trim() ?? '';
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (phone.isEmpty || code.isEmpty) {
      _showMessage('Missing phone number or verification code.');
      return;
    }

    if (password.isEmpty || confirm.isEmpty) {
      _showMessage('Enter and confirm your new password.');
      return;
    }

    if (password != confirm) {
      _showMessage('Passwords do not match.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final resetPassword = ref.read(resetForgotPasswordUseCaseProvider);
    final response = await resetPassword(
      ResetForgotPasswordData(
        phoneNumber: phone,
        verificationCode: code,
        newPassword: password,
        confirmPassword: confirm,
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    if (response.isSuccess) {
      context.go('/password-changed');
    } else {
      _showMessage(
        response.errors.isNotEmpty
            ? response.errors.join('\n')
            : response.message,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F3),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 56),
                const Text(
                  'Create new password',
                  style: TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Set a new password for your account.',
                  style: TextStyle(
                    color: Color(0xFF8B8B8B),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'New password',
                  style: TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                AuthPasswordField(
                  controller: _passwordController,
                  hintText: 'Enter new password',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Confirm password',
                  style: TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                AuthPasswordField(
                  controller: _confirmController,
                  hintText: 'Confirm new password',
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF111111),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _isLoading ? 'Updating...' : 'Update password',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () => context.go('/login'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF111111),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Back to login',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
