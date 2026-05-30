import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../../auth/domain/entities/auth_requests.dart';

class ProfileChangePasswordScreen extends ConsumerStatefulWidget {
  const ProfileChangePasswordScreen({super.key});

  @override
  ConsumerState<ProfileChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends ConsumerState<ProfileChangePasswordScreen> {
  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nextController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _showPassword = false;
  bool _loading = false;
  bool _done = false;

  @override
  void dispose() {
    _currentController.dispose();
    _codeController.dispose();
    _nextController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_currentController.text.isEmpty ||
        _nextController.text.isEmpty ||
        _confirmController.text.isEmpty ||
        _codeController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields.')));
      return;
    }

    setState(() {
      _loading = true;
    });

    final result = await ref.read(changePasswordUseCaseProvider)(
      ChangePasswordData(
        userId: '',
        oldPassword: _currentController.text,
        verificationCode: _codeController.text,
        newPassword: _nextController.text,
        confirmPassword: _confirmController.text,
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F6F3),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF7F6F3),
          elevation: 0,
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          title: const Text(
            'Password Changed',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9F0C8),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.check,
                  size: 40,
                  color: Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Password Updated!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your password has been changed successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF8B8B8B)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF111111),
                    foregroundColor: Colors.white,
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
      backgroundColor: const Color(0xFFF7F6F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F6F3),
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Change Password',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: [
          _PasswordField(
            label: 'Current Password',
            controller: _currentController,
            showPassword: _showPassword,
            toggleVisibility: () => setState(() {
              _showPassword = !_showPassword;
            }),
            showToggle: true,
          ),
          const SizedBox(height: 16),
          _PasswordField(
            label: 'Verification Code',
            controller: _codeController,
            showPassword: false,
            obscure: false,
            hintText: '00000',
          ),
          const SizedBox(height: 16),
          _PasswordField(
            label: 'New Password',
            controller: _nextController,
            showPassword: _showPassword,
            toggleVisibility: () => setState(() {
              _showPassword = !_showPassword;
            }),
            showToggle: true,
          ),
          const SizedBox(height: 16),
          _PasswordField(
            label: 'Confirm New Password',
            controller: _confirmController,
            showPassword: _showPassword,
            toggleVisibility: () => setState(() {
              _showPassword = !_showPassword;
            }),
            showToggle: true,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF111111),
                disabledBackgroundColor: const Color(0xFF111111),
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: _loading ? () {} : _handleSave,
              child: Text(_loading ? 'Updating...' : 'Update Password'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.label,
    required this.controller,
    required this.showPassword,
    this.toggleVisibility,
    this.showToggle = false,
    this.hintText = '********',
    this.obscure = true,
  });

  final String label;
  final TextEditingController controller;
  final bool showPassword;
  final VoidCallback? toggleVisibility;
  final bool showToggle;
  final String hintText;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF111111)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure ? (showToggle ? !showPassword : true) : false,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            suffixIcon: showToggle
                ? IconButton(
                    onPressed: toggleVisibility,
                    icon: Icon(
                      showPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF8B8B8B),
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
