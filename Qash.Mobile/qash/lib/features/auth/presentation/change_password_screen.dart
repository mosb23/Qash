import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/input/text_input_formatters.dart';
import '../../../core/validation/password_policy.dart';
import '../../../core/widgets/password_requirements_widget.dart';
import '../domain/entities/auth_requests.dart';
import '../providers/auth_providers.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _isLoading = false;
  bool _oldPasswordObscured = true;
  bool _newPasswordObscured = true;
  bool _confirmPasswordObscured = true;
  bool _hasSubmitted = false;
  String? _codeError;

  @override
  void initState() {
    super.initState();
    _oldPasswordController.addListener(_onFormChanged);
    _codeController.addListener(_onFormChanged);
    _newPasswordController.addListener(_onFormChanged);
    _confirmController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    if (!mounted) return;
    setState(() {
      if (_hasSubmitted) {
        _codeError = _validateCode(_codeController.text);
      }
    });
  }

  String? _validateCode(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Verification code is required.';
    if (!RegExp(r'^\d+$').hasMatch(v)) return 'Verification code must contain digits only.';
    if (v.length < 5) return 'Verification code must be exactly 5 digits.';
    if (v.length > 5) return 'Verification code must be exactly 5 digits.';
    return null;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _changePassword() async {
    final oldPassword = _oldPasswordController.text.trim();
    final code = _codeController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirm = _confirmController.text.trim();
    final passwordPolicy = evaluatePasswordPolicy(newPassword);

    setState(() {
      _hasSubmitted = true;
      _codeError = _validateCode(_codeController.text);
    });

    if (_codeError != null) return;

    if (oldPassword.isEmpty || newPassword.isEmpty || confirm.isEmpty) {
      _showMessage('Fill all fields to continue.');
      return;
    }

    if (!passwordPolicy.isValid) {
      _showMessage(
        'Password requirements:\n${passwordPolicy.unmetRequirements.map((r) => '• $r').join('\n')}',
      );
      return;
    }

    if (newPassword != confirm) {
      _showMessage('Passwords do not match.');
      return;
    }

    setState(() => _isLoading = true);

    final changePassword = ref.read(changePasswordUseCaseProvider);
    final response = await changePassword(
      ChangePasswordData(
        userId: '',
        oldPassword: oldPassword,
        verificationCode: code,
        newPassword: newPassword,
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
    final oldPassword = _oldPasswordController.text.trim();
    final code = _codeController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirm = _confirmController.text.trim();
    final policy = evaluatePasswordPolicy(newPassword);
    return !_isLoading &&
        oldPassword.isNotEmpty &&
        _validateCode(code) == null &&
        policy.isValid &&
        newPassword == confirm;
  }

  @override
  Widget build(BuildContext context) {
    final newPassword = _newPasswordController.text.trim();
    final confirm = _confirmController.text.trim();
    final policy = evaluatePasswordPolicy(newPassword);
    final showConfirmError =
        _hasSubmitted && confirm.isNotEmpty && newPassword != confirm;

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
                  'Change password',
                  style: TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your current password and verification code.',
                  style: TextStyle(
                    color: Color(0xFF8B8B8B),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 32),
                _buildPasswordField(
                  label: 'Current password',
                  controller: _oldPasswordController,
                  obscured: _oldPasswordObscured,
                  onToggle: () => setState(
                    () => _oldPasswordObscured = !_oldPasswordObscured,
                  ),
                  hint: 'Enter current password',
                ),
                const SizedBox(height: 16),
                _buildCodeField(),
                const SizedBox(height: 16),
                _buildPasswordField(
                  label: 'New password',
                  controller: _newPasswordController,
                  obscured: _newPasswordObscured,
                  onToggle: () => setState(
                    () => _newPasswordObscured = !_newPasswordObscured,
                  ),
                  hint: 'Enter new password',
                  hasError: _hasSubmitted && !policy.isValid,
                ),
                const SizedBox(height: 12),
                PasswordRequirementsWidget(
                  policy: policy,
                  showValidation: _hasSubmitted,
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  label: 'Confirm password',
                  controller: _confirmController,
                  obscured: _confirmPasswordObscured,
                  onToggle: () => setState(
                    () => _confirmPasswordObscured = !_confirmPasswordObscured,
                  ),
                  hint: 'Confirm new password',
                  hasError: showConfirmError,
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
                    onPressed: _canSubmit ? _changePassword : null,
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
                    onPressed: () => context.go('/home'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF111111),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Back to home',
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

  Widget _buildCodeField() {
    final hasError = _codeError != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Verification code',
          style: TextStyle(
            color: Color(0xFF111111),
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
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
          child: TextField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              ...digitsOnlyInputFormatters,
              LengthLimitingTextInputFormatter(5),
            ],
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: '00000',
              hintStyle: TextStyle(
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
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _codeError!,
              style: const TextStyle(
                color: Color(0xFFD32F2F),
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          )
        else
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              'Demo code: 00000',
              style: TextStyle(
                color: Color(0xFF8B8B8B),
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscured,
    required VoidCallback onToggle,
    String hint = '',
    bool hasError = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF111111),
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
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
        ),
      ],
    );
  }
}
