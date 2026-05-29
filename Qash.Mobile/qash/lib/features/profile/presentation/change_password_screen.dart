import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qash/core/theme/qash_theme_extension.dart';

import '../../auth/domain/entities/auth_requests.dart';
import '../../auth/presentation/widgets/auth_password_field.dart';
import '../../../core/assets/qash_icons.dart';
import '../../../core/widgets/qash_icon.dart';
import '../../auth/presentation/widgets/auth_screen_helpers.dart';
import '../../auth/providers/auth_providers.dart';

class ProfileChangePasswordScreen extends ConsumerStatefulWidget {
  const ProfileChangePasswordScreen({super.key});

  @override
  ConsumerState<ProfileChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ProfileChangePasswordScreen> {
  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _nextController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _loading = false;
  bool _done = false;

  @override
  void dispose() {
    _currentController.dispose();
    _nextController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final oldPassword = _currentController.text.trim();
    final newPassword = _nextController.text.trim();
    final confirmPassword = _confirmController.text.trim();

    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields.')),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    final result = await ref.read(changePasswordUseCaseProvider)(
      ChangePasswordData(
        userId: '',
        oldPassword: oldPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      ),
    );

    if (!mounted) return;

    setState(() {
      _loading = false;
      _done = result.isSuccess;
    });

    if (!result.isSuccess) {
      final message = result.message.isNotEmpty
          ? result.message
          : 'Failed to change password.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, String title) {
    final qash = context.qash;
    return AppBar(
      elevation: 0,
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
            color: qash.surface,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: qash.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: qash.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final qash = context.qash;

    if (_done) {
      return Scaffold(
        appBar: _buildAppBar(context, 'Password Changed'),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: qash.accent.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const QashIcon(
                  assetPath: QashIcons.actionSuccess,
                  fallback: Icons.check,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Password Updated!',
                style: authTitleStyle(context).copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your password has been changed successfully.',
                textAlign: TextAlign.center,
                style: authMutedBodyStyle(context),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: qash.primaryButton,
                    foregroundColor: qash.onPrimaryButton,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text('Back to Profile'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(context, 'Change Password'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: qash.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: qash.border),
            ),
            child: Text(
              'You are signed in. Enter your current password to update — no SMS code required.',
              style: TextStyle(color: qash.textSecondary, fontSize: 12, height: 1.35),
            ),
          ),
          const SizedBox(height: 16),
          Text('Current Password', style: authLabelStyle(context)),
          const SizedBox(height: 8),
          AuthPasswordField(
            controller: _currentController,
            hintText: '********',
          ),
          const SizedBox(height: 16),
          Text('New Password', style: authLabelStyle(context)),
          const SizedBox(height: 8),
          AuthPasswordField(
            controller: _nextController,
            hintText: '********',
          ),
          const SizedBox(height: 16),
          Text('Confirm New Password', style: authLabelStyle(context)),
          const SizedBox(height: 8),
          AuthPasswordField(
            controller: _confirmController,
            hintText: '********',
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: qash.primaryButton,
                foregroundColor: qash.onPrimaryButton,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: _loading ? null : _handleSave,
              child: Text(_loading ? 'Updating...' : 'Update Password'),
            ),
          ),
        ],
      ),
    );
  }
}
