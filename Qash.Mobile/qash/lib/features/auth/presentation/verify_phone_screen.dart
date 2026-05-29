import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qash/core/theme/qash_theme_extension.dart';

import '../domain/entities/auth_requests.dart';
import '../providers/auth_providers.dart';
import 'widgets/auth_screen_helpers.dart';
import 'widgets/auth_text_field.dart';

class VerifyPhoneScreen extends ConsumerStatefulWidget {
  final String? phoneNumber;

  const VerifyPhoneScreen({super.key, this.phoneNumber});

  @override
  ConsumerState<VerifyPhoneScreen> createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends ConsumerState<VerifyPhoneScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.phoneNumber != null) {
      _phoneController.text = widget.phoneNumber!;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final phone = _phoneController.text.trim();
    final code = _codeController.text.trim();

    if (phone.isEmpty || code.isEmpty) {
      _showMessage('Enter phone number and code.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final verifyPhone = ref.read(verifyPhoneUseCaseProvider);
    final response = await verifyPhone(
      PhoneVerificationData(phoneNumber: phone, verificationCode: code),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    if (response.isSuccess) {
      markUserAuthenticated(ref);
      _showMessage('Phone verified. Welcome to Qash.');
      context.go('/home');
    } else {
      _showMessage(
        response.errors.isNotEmpty
            ? response.errors.join('\n')
            : response.message,
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
                Text('Verify your phone', style: authTitleStyle(context)),
                const SizedBox(height: 8),
                Text(
                  'Use the 5-digit code sent to your phone.',
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
                const SizedBox(height: 16),
                Text('Verification code', style: authLabelStyle(context)),
                const SizedBox(height: 8),
                AuthTextField(
                  controller: _codeController,
                  hintText: '00000',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                Text(
                  'Demo code: 00000',
                  style: TextStyle(
                    color: qash.textSecondary,
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 24),
                authPrimaryButton(
                  context: context,
                  label: _isLoading ? 'Verifying...' : 'Verify',
                  onTap: _isLoading ? null : _verify,
                  enabled: !_isLoading,
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
