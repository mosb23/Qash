import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/input/text_input_formatters.dart';
import '../../../core/validation/password_policy.dart';
import '../../../core/widgets/password_requirements_widget.dart';
import '../../auth/domain/entities/auth_requests.dart';
import '../../auth/providers/auth_providers.dart';

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
  bool _hasSubmitted = false;
  String? _codeError;

  @override
  void initState() {
    super.initState();
    _currentController.addListener(_onFormChanged);
    _codeController.addListener(_onFormChanged);
    _nextController.addListener(_onFormChanged);
    _confirmController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _currentController.dispose();
    _codeController.dispose();
    _nextController.dispose();
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

  Future<void> _handleSave() async {
    final current = _currentController.text.trim();
    final next = _nextController.text.trim();
    final confirm = _confirmController.text.trim();
    final policy = evaluatePasswordPolicy(next);

    setState(() {
      _hasSubmitted = true;
      _codeError = _validateCode(_codeController.text);
    });

    if (_codeError != null) return;

    if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields.')),
      );
      return;
    }

    if (!policy.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Password requirements:\n${policy.unmetRequirements.map((r) => '• $r').join('\n')}',
          ),
        ),
      );
      return;
    }

    if (next != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    setState(() => _loading = true);

    final result = await ref.read(changePasswordUseCaseProvider)(
      ChangePasswordData(
        userId: '',
        oldPassword: current,
        verificationCode: _codeController.text.trim(),
        newPassword: next,
        confirmPassword: confirm,
      ),
    );

    if (!mounted) return;

    setState(() {
      _loading = false;
      _done = result.isSuccess;
    });

    if (!result.isSuccess) {
      final message =
          result.message.isNotEmpty ? result.message : 'Failed to change password.';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  bool get _canSubmit {
    final current = _currentController.text.trim();
    final next = _nextController.text.trim();
    final confirm = _confirmController.text.trim();
    final policy = evaluatePasswordPolicy(next);
    return !_loading &&
        current.isNotEmpty &&
        _validateCode(_codeController.text) == null &&
        policy.isValid &&
        next == confirm;
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

    final next = _nextController.text.trim();
    final confirm = _confirmController.text.trim();
    final policy = evaluatePasswordPolicy(next);
    final showConfirmError =
        _hasSubmitted && confirm.isNotEmpty && next != confirm;

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
          _buildPasswordField(
            label: 'Current Password',
            controller: _currentController,
            showPassword: _showPassword,
            toggleVisibility: () =>
                setState(() => _showPassword = !_showPassword),
            showToggle: true,
          ),
          const SizedBox(height: 16),
          _buildCodeField(),
          const SizedBox(height: 16),
          _buildPasswordField(
            label: 'New Password',
            controller: _nextController,
            showPassword: _showPassword,
            toggleVisibility: () =>
                setState(() => _showPassword = !_showPassword),
            showToggle: true,
            hasError: _hasSubmitted && !policy.isValid,
          ),
          const SizedBox(height: 8),
          PasswordRequirementsWidget(
            policy: policy,
            showValidation: _hasSubmitted,
          ),
          const SizedBox(height: 16),
          _buildPasswordField(
            label: 'Confirm New Password',
            controller: _confirmController,
            showPassword: _showPassword,
            toggleVisibility: () =>
                setState(() => _showPassword = !_showPassword),
            showToggle: true,
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF111111),
                disabledBackgroundColor: const Color(0xFF9CA3AF),
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: _canSubmit ? _handleSave : null,
              child: Text(_loading ? 'Updating...' : 'Update Password'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeField() {
    final hasError = _codeError != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Verification Code',
          style: TextStyle(fontSize: 14, color: Color(0xFF111111)),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hasError ? const Color(0xFFD32F2F) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              ...digitsOnlyInputFormatters,
              LengthLimitingTextInputFormatter(5),
            ],
            decoration: const InputDecoration(
              hintText: '00000',
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                borderSide: BorderSide.none,
              ),
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
    required bool showPassword,
    VoidCallback? toggleVisibility,
    bool showToggle = false,
    String hintText = '••••••••',
    bool obscure = true,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool hasError = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF111111)),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hasError ? const Color(0xFFD32F2F) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure ? (showToggle ? !showPassword : true) : false,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
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
        ),
      ],
    );
  }
}
