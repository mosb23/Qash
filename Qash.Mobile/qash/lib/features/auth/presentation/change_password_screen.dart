import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qash/core/theme/qash_theme_extension.dart';

import '../domain/entities/auth_requests.dart';
import '../providers/auth_providers.dart';
import 'widgets/auth_password_field.dart';
import 'widgets/auth_screen_helpers.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _changePassword() async {
    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (oldPassword.isEmpty || newPassword.isEmpty || confirm.isEmpty) {
      _showMessage('Fill all fields to continue.');
      return;
    }

    if (newPassword != confirm) {
      _showMessage('Passwords do not match.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final changePassword = ref.read(changePasswordUseCaseProvider);
    final response = await changePassword(
      ChangePasswordData(
        userId: '',
        oldPassword: oldPassword,
        newPassword: newPassword,
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
                Text('Change password', style: authTitleStyle(context)),
                const SizedBox(height: 8),
                Text(
                  'Enter your current password and choose a new one.',
                  style: authSubtitleStyle(context),
                ),
                const SizedBox(height: 32),
                Text('Current password', style: authLabelStyle(context)),
                const SizedBox(height: 8),
                AuthPasswordField(
                  controller: _oldPasswordController,
                  hintText: 'Enter current password',
                ),
                const SizedBox(height: 16),
                Text('New password', style: authLabelStyle(context)),
                const SizedBox(height: 8),
                AuthPasswordField(
                  controller: _newPasswordController,
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
                  onTap: _isLoading ? null : _changePassword,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () => context.go('/home'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: qash.textPrimary,
                      side: BorderSide(color: qash.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Back to home', style: TextStyle(fontSize: 16)),
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
