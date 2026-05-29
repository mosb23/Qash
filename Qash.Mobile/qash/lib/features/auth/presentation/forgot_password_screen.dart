import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qash/core/theme/qash_theme_extension.dart';

import '../domain/entities/auth_requests.dart';
import '../providers/auth_providers.dart';
import 'widgets/auth_screen_helpers.dart';
import 'widgets/auth_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _sendCode() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      _showMessage('Enter your phone number.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final requestForgotPassword = ref.read(
      requestForgotPasswordCodeUseCaseProvider,
    );
    final response = await requestForgotPassword(
      ForgotPasswordCodeRequestData(phoneNumber: phone),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    if (response.isSuccess) {
      final code = response.data?.verificationCode ?? '';
      final phoneParam = Uri.encodeComponent(phone);
      final codeParam = Uri.encodeComponent(code);
      final route = code.isEmpty
          ? '/forgot-verify?phone=$phoneParam'
          : '/forgot-verify?phone=$phoneParam&code=$codeParam';
      context.go(route);
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
                Text('Forgot password', style: authTitleStyle(context)),
                const SizedBox(height: 8),
                Text(
                  'Enter your phone number to receive a reset code.',
                  style: authSubtitleStyle(context),
                ),
                const SizedBox(height: 40),
                Text('Phone number', style: authLabelStyle(context)),
                const SizedBox(height: 8),
                AuthTextField(
                  controller: _phoneController,
                  hintText: '+20 1xx xxx xxxx',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),
                authPrimaryButton(
                  context: context,
                  label: _isLoading ? 'Sending...' : 'Send code',
                  onTap: _isLoading ? null : _sendCode,
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
