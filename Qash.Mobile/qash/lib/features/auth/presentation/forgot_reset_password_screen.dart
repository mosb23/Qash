import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qash/core/theme/qash_theme_extension.dart';

import '../domain/entities/auth_requests.dart';
import '../providers/auth_providers.dart';
import 'widgets/auth_password_field.dart';
import 'widgets/auth_screen_helpers.dart';

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
    final qash = context.qash;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            color: qash.scaffoldBackground,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 56),
                Text('Create new password', style: authTitleStyle(context)),
                const SizedBox(height: 8),
                Text(
                  'Set a new password for your account.',
                  style: authSubtitleStyle(context),
                ),
                const SizedBox(height: 40),
                Text('New password', style: authLabelStyle(context)),
                const SizedBox(height: 8),
                AuthPasswordField(
                  controller: _passwordController,
                  hintText: 'Enter new password',
                ),
                const SizedBox(height: 16),
                Text('Confirm password', style: authLabelStyle(context)),
                const SizedBox(height: 8),
                AuthPasswordField(
                  controller: _confirmController,
                  hintText: 'Confirm new password',
                ),
                const SizedBox(height: 24),
                authPrimaryButton(
                  context: context,
                  label: _isLoading ? 'Updating...' : 'Update password',
                  onTap: _isLoading ? null : _resetPassword,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () => context.go('/login'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: qash.textPrimary,
                      side: BorderSide(color: qash.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Back to login', style: TextStyle(fontSize: 16)),
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
