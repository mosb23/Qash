import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/validation/password_policy.dart';
import '../../../core/widgets/password_requirements_widget.dart';
import '../domain/entities/auth_requests.dart';
import '../providers/auth_providers.dart';

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
  bool _passwordObscured = true;
  bool _confirmPasswordObscured = true;
  bool _hasSubmitted = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onFormChanged);
    _confirmController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    if (mounted) setState(() {});
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _resetPassword() async {
    final phone = widget.phoneNumber?.trim() ?? '';
    final code = widget.verificationCode?.trim() ?? '';
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();
    final passwordPolicy = evaluatePasswordPolicy(password);

    setState(() => _hasSubmitted = true);

    if (phone.isEmpty || code.isEmpty) {
      _showMessage('Missing phone number or verification code.');
      return;
    }

    if (!passwordPolicy.isValid) {
      _showMessage(
        'Password requirements:\n${passwordPolicy.unmetRequirements.map((r) => '• $r').join('\n')}',
      );
      return;
    }

    if (password != confirm) {
      _showMessage('Passwords do not match.');
      return;
    }

    setState(() => _isLoading = true);

    final resetPassword = ref.read(resetForgotPasswordUseCaseProvider);
    final response = await resetPassword(
      ResetForgotPasswordData(
        phoneNumber: phone,
        verificationCode: code,
        newPassword: password,
        confirmPassword: confirm,
      ),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

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

  bool get _canSubmit {
    final phone = widget.phoneNumber?.trim() ?? '';
    final code = widget.verificationCode?.trim() ?? '';
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();
    final policy = evaluatePasswordPolicy(password);
    return !_isLoading &&
        phone.isNotEmpty &&
        code.isNotEmpty &&
        policy.isValid &&
        password == confirm;
  }

  @override
  Widget build(BuildContext context) {
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();
    final policy = evaluatePasswordPolicy(password);
    final showConfirmError =
        _hasSubmitted && confirm.isNotEmpty && password != confirm;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F3),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
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
                _buildPasswordField(
                  controller: _passwordController,
                  hint: 'Enter new password',
                  obscured: _passwordObscured,
                  hasError: _hasSubmitted && !policy.isValid,
                  onToggle: () =>
                      setState(() => _passwordObscured = !_passwordObscured),
                ),
                const SizedBox(height: 12),
                PasswordRequirementsWidget(
                  policy: policy,
                  showValidation: _hasSubmitted,
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
                _buildPasswordField(
                  controller: _confirmController,
                  hint: 'Confirm new password',
                  obscured: _confirmPasswordObscured,
                  hasError: showConfirmError,
                  onToggle: () => setState(
                    () => _confirmPasswordObscured = !_confirmPasswordObscured,
                  ),
                ),
                if (showConfirmError)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Passwords do not match.',
                      style: TextStyle(
                        color: Color(0xFFD32F2F),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _canSubmit ? _resetPassword : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF111111),
                      disabledBackgroundColor: const Color(0xFF9CA3AF),
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white,
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
                      side: const BorderSide(color: Color(0xFF9CA3AF)),
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscured,
    required VoidCallback onToggle,
    bool hasError = false,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasError ? const Color(0xFFD32F2F) : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 2,
            offset: Offset(0, 1),
            spreadRadius: -1,
          ),
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 3,
            offset: Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscured,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: const TextStyle(
                  color: Color(0xFFC4C4C4),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
              style: const TextStyle(
                color: Color(0xFF111111),
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          IconButton(
            onPressed: onToggle,
            icon: Icon(
              obscured
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: const Color(0xFFC4C4C4),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
