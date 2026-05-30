import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qash/core/theme/qash_theme_extension.dart';

import 'forgot_password_flow.dart';
import 'widgets/auth_screen_helpers.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/demo_otp_banner.dart';

class ForgotVerifyScreen extends StatefulWidget {
  final String? phoneNumber;
  final String? demoCode;

  const ForgotVerifyScreen({super.key, this.phoneNumber, this.demoCode});

  @override
  State<ForgotVerifyScreen> createState() => _ForgotVerifyScreenState();
}

class _ForgotVerifyScreenState extends State<ForgotVerifyScreen> {
  final TextEditingController _codeController = TextEditingController();

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _continueToReset() {
    final code = _codeController.text.trim();
    final phone = widget.phoneNumber?.trim() ?? '';

    if (code.isEmpty) {
      _showMessage('Enter the verification code.');
      return;
    }

    if (phone.isEmpty) {
      _showMessage('Phone number is missing. Go back and try again.');
      return;
    }

    // Code is validated on the server when resetting the password.
    context.go(
      '/forgot-reset',
      extra: ForgotPasswordFlowPayload(
        phoneNumber: phone,
        verificationCode: code,
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final qash = context.qash;
    final phone = widget.phoneNumber ?? '';
    final demoCode = widget.demoCode ?? '';

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
                const DemoOtpBanner(),
                const SizedBox(height: 16),
                Text('Verify code', style: authTitleStyle(context)),
                const SizedBox(height: 8),
                Text(
                  phone.isEmpty
                      ? 'Enter the demo verification code.'
                      : 'Enter the code for $phone.',
                  style: authSubtitleStyle(context),
                ),
                const SizedBox(height: 40),
                Text('Verification code', style: authLabelStyle(context)),
                const SizedBox(height: 8),
                AuthTextField(
                  controller: _codeController,
                  hintText: '00000',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                Text(
                  demoCode.isEmpty
                      ? 'If an account exists, use the demo code from the previous step.'
                      : 'Demo code (coursework): $demoCode',
                  style: TextStyle(
                    color: qash.textSecondary,
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 24),
                authPrimaryButton(
                  context: context,
                  label: 'Continue',
                  onTap: _continueToReset,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () => context.go('/forgot-password'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: qash.textPrimary,
                      side: BorderSide(color: qash.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Change phone number',
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
