import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/input/text_input_formatters.dart';
import '../../../core/validation/contact_validation.dart';
import '../../../core/validation/password_policy.dart';
import '../../../core/widgets/password_requirements_widget.dart';
import '../domain/entities/auth_requests.dart';
import '../providers/auth_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  late final TapGestureRecognizer _termsTapRecognizer;
  late final TapGestureRecognizer _privacyTapRecognizer;

  bool _isLoading = false;
  bool _passwordObscured = true;
  bool _confirmPasswordObscured = true;
  bool _hasSubmitted = false;
  String? _emailError;
  String? _phoneError;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onContactFieldChanged);
    _phoneController.addListener(_onContactFieldChanged);
    _passwordController.addListener(_onPasswordChanged);
    _confirmPasswordController.addListener(_onPasswordChanged);
    _termsTapRecognizer = TapGestureRecognizer()
      ..onTap = () => context.push('/profile/terms');
    _privacyTapRecognizer = TapGestureRecognizer()
      ..onTap = () => context.push('/profile/privacy');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _termsTapRecognizer.dispose();
    _privacyTapRecognizer.dispose();
    super.dispose();
  }

  void _onContactFieldChanged() {
    if (!mounted) return;
    setState(() {
      if (_hasSubmitted) {
        _emailError = validateEmailAddress(_emailController.text);
        _phoneError = validatePhoneNumber11Digits(_phoneController.text);
      }
    });
  }

  void _onPasswordChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _register() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final passwordPolicy = evaluatePasswordPolicy(password);

    setState(() {
      _hasSubmitted = true;
      _emailError = validateEmailAddress(_emailController.text);
      _phoneError = validatePhoneNumber11Digits(_phoneController.text);
    });

    if (_emailError != null || _phoneError != null) return;

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessage('Fill in all fields.');
      return;
    }

    if (!passwordPolicy.isValid) {
      _showMessage(
        'Password requirements:\n${passwordPolicy.unmetRequirements.map((r) => '• $r').join('\n')}',
      );
      return;
    }

    if (password != confirmPassword) {
      _showMessage('Passwords do not match.');
      return;
    }

    setState(() => _isLoading = true);

    final register = ref.read(registerUseCaseProvider);
    final response = await register(
      RegistrationData(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phone,
        password: password,
        confirmPassword: confirmPassword,
      ),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response.isSuccess) {
      context.go('/verify?phone=${Uri.encodeComponent(phone)}');
    } else {
      _showMessage(
        response.errors.isNotEmpty
            ? response.errors.join('\n')
            : response.message,
      );
    }
  }

  bool get _canSubmit {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final policy = evaluatePasswordPolicy(password);

    return !_isLoading &&
        firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        validateEmailAddress(email) == null &&
        validatePhoneNumber11Digits(phone) == null &&
        policy.isValid &&
        password == confirmPassword;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final passwordPolicy = evaluatePasswordPolicy(password);
    final passwordsMatch = password == confirmPassword;
    final showConfirmError =
        _hasSubmitted && confirmPassword.isNotEmpty && !passwordsMatch;

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
                  'Create Account',
                  style: TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Start your financial journey',
                  style: TextStyle(
                    color: Color(0xFF8B8B8B),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'First name',
                  style: TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                _inputField(
                  controller: _firstNameController,
                  hint: 'Akmal',
                  inputFormatters: nameInputFormatters,
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Last name',
                  style: TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                _inputField(
                  controller: _lastNameController,
                  hint: 'Nasruddin',
                  inputFormatters: nameInputFormatters,
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Email address',
                  style: TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                _inputField(
                  controller: _emailController,
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  errorText: _emailError,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Phone number',
                  style: TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                _inputField(
                  controller: _phoneController,
                  hint: kPhoneHint,
                  keyboardType: TextInputType.phone,
                  inputFormatters: phoneInputFormatters,
                  errorText: _phoneError,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Password',
                  style: TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                _passwordField(
                  controller: _passwordController,
                  hint: 'Min. 8 characters',
                  obscured: _passwordObscured,
                  hasError: _hasSubmitted && !passwordPolicy.isValid,
                  onToggle: () =>
                      setState(() => _passwordObscured = !_passwordObscured),
                ),
                const SizedBox(height: 12),
                PasswordRequirementsWidget(
                  policy: passwordPolicy,
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
                _passwordField(
                  controller: _confirmPasswordController,
                  hint: 'Repeat your password',
                  obscured: _confirmPasswordObscured,
                  hasError: showConfirmError,
                  onToggle: () => setState(
                    () =>
                        _confirmPasswordObscured = !_confirmPasswordObscured,
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
                const SizedBox(height: 16),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'By creating an account, you agree to our ',
                        style: TextStyle(
                          color: Color(0xFF8B8B8B),
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      TextSpan(
                        text: 'Terms of Service',
                        style: const TextStyle(
                          color: Color(0xFF111111),
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                        recognizer: _termsTapRecognizer,
                      ),
                      const TextSpan(
                        text: ' and ',
                        style: TextStyle(
                          color: Color(0xFF8B8B8B),
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: const TextStyle(
                          color: Color(0xFF111111),
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                        recognizer: _privacyTapRecognizer,
                      ),
                      const TextSpan(
                        text: '.',
                        style: TextStyle(
                          color: Color(0xFF8B8B8B),
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _canSubmit ? _register : null,
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
                      _isLoading ? 'Creating...' : 'Create Account',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(
                        color: Color(0xFF8B8B8B),
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: Color(0xFF111111),
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? errorText,
  }) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
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
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              errorText,
              style: const TextStyle(
                color: Color(0xFFD32F2F),
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }

  Widget _passwordField({
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
              obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: const Color(0xFFC4C4C4),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
