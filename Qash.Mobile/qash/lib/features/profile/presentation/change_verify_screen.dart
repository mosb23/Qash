import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qash/core/theme/qash_theme_extension.dart';

import '../../auth/presentation/widgets/auth_screen_helpers.dart';
import '../../auth/presentation/widgets/auth_text_field.dart';
import '../providers/profile_providers.dart';

class ProfileChangeVerifyScreen extends ConsumerStatefulWidget {
  final String? phoneNumber;
  final String? demoCode;

  const ProfileChangeVerifyScreen({super.key, this.phoneNumber, this.demoCode});

  @override
  ConsumerState<ProfileChangeVerifyScreen> createState() =>
      _ProfileChangeVerifyScreenState();
}

class _ProfileChangeVerifyScreenState
    extends ConsumerState<ProfileChangeVerifyScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();

    if (code.isEmpty) {
      _showMessage('Enter the verification code.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    final phone = _resolvedPhone(ref);
    if (phone.isEmpty) {
      _showMessage('Missing phone number. Update your profile first.');
      return;
    }
    final phoneParam = Uri.encodeComponent(phone);
    final codeParam = Uri.encodeComponent(code);
    context.go('/profile/change-reset?phone=$phoneParam&code=$codeParam');
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(profileProvider);
    final qash = context.qash;
    final phone = _resolvedPhone(ref);
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
                Text('Verify code', style: authTitleStyle(context)),
                const SizedBox(height: 8),
                Text(
                  phone.isEmpty
                      ? 'Enter the code sent to your phone.'
                      : 'Enter the code sent to $phone.',
                  style: authSubtitleStyle(context),
                ),
                const SizedBox(height: 40),
                Text('Verification code', style: authLabelStyle(context)),
                const SizedBox(height: 8),
                AuthTextField(
                  controller: _codeController,
                  hintText: '000000',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                Text(
                  demoCode.isEmpty
                      ? 'Did not receive the code? Resend in 30s'
                      : 'Demo code: $demoCode',
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
                  onTap: _isLoading ? null : _verifyCode,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () => context.go('/profile'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: qash.textPrimary,
                      side: BorderSide(color: qash.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Back to profile',
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

  String _resolvedPhone(WidgetRef ref) {
    final directPhone = widget.phoneNumber?.trim() ?? '';
    if (directPhone.isNotEmpty) {
      return directPhone;
    }

    final profileAsync = ref.read(profileProvider);
    return profileAsync.maybeWhen(
      data: (result) => result.data?.phoneNumber ?? '',
      orElse: () => '',
    );
  }
}
