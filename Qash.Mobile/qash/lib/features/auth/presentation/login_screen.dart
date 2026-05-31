import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/input/text_input_formatters.dart';
import '../../../core/providers/user_session_invalidation.dart';
import '../../../core/validation/contact_validation.dart';
import '../domain/entities/auth_requests.dart';
import '../providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _hasSubmitted = false;
  String? _phoneError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onFormChanged);
    _passwordController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    if (!mounted) return;
    setState(() {
      if (_hasSubmitted) {
        _phoneError = validatePhoneNumber11Digits(_phoneController.text);
        _passwordError = _passwordController.text.trim().isEmpty
            ? 'Password is required.'
            : null;
      }
    });
  }

  bool get _canSubmit {
    return !_isLoading &&
        validatePhoneNumber11Digits(_phoneController.text) == null &&
        _passwordController.text.trim().isNotEmpty;
  }

  Future<void> _login() async {
    setState(() {
      _hasSubmitted = true;
      _phoneError = validatePhoneNumber11Digits(_phoneController.text);
      _passwordError = _passwordController.text.trim().isEmpty
          ? 'Password is required.'
          : null;
    });

    if (_phoneError != null || _passwordError != null) return;

    setState(() => _isLoading = true);

    final login = ref.read(loginUseCaseProvider);
    final response = await login(
      LoginCredentials(
        phoneNumber: _phoneController.text.trim(),
        password: _passwordController.text.trim(),
      ),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response.isSuccess) {
      invalidateUserSessionData(ref);
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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F3),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 56),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4D93A),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'Q',
                      style: TextStyle(
                        color: Color(0xFF111111),
                        fontSize: 24,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Welcome back 👋',
                  style: TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to your Qash account',
                  style: TextStyle(
                    color: Color(0xFF8B8B8B),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 40),
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
                _buildInputField(
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
                _buildPasswordField(
                  controller: _passwordController,
                  hint: 'Enter your password',
                  obscured: _obscurePassword,
                  onToggle: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  errorText: _passwordError,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => context.go('/forgot-password'),
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(
                        color: Color(0xFF111111),
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _canSubmit ? _login : null,
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
                      _isLoading ? 'Signing in...' : 'Sign In',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: Color(0xFF8B8B8B),
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/register'),
                      child: const Text(
                        'Sign Up',
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

  Widget _buildInputField({
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscured,
    required VoidCallback onToggle,
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
                tooltip: obscured ? 'Show password' : 'Hide password',
              ),
            ],
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
}
