import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/input/text_input_formatters.dart';
import '../../../core/validation/contact_validation.dart';
import '../domain/entities/auth_requests.dart';
import '../providers/auth_providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _hasSubmitted = false;
  String? _phoneError;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    if (!mounted) return;
    setState(() {
      if (_hasSubmitted) {
        _phoneError = validatePhoneNumber11Digits(_phoneController.text);
      }
    });
  }

  bool get _canSubmit =>
      !_isLoading &&
      validatePhoneNumber11Digits(_phoneController.text) == null;

  Future<void> _sendCode() async {
    setState(() {
      _hasSubmitted = true;
      _phoneError = validatePhoneNumber11Digits(_phoneController.text);
    });

    if (_phoneError != null) return;

    setState(() => _isLoading = true);

    final requestForgotPassword = ref.read(
      requestForgotPasswordCodeUseCaseProvider,
    );
    final response = await requestForgotPassword(
      ForgotPasswordCodeRequestData(phoneNumber: _phoneController.text.trim()),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response.isSuccess) {
      final code = response.data?.verificationCode ?? '';
      final phone = _phoneController.text.trim();
      final phoneParam = Uri.encodeComponent(phone);
      final route = code.isEmpty
          ? '/forgot-verify?phone=$phoneParam'
          : '/forgot-verify?phone=$phoneParam&code=${Uri.encodeComponent(code)}';
      context.go(route);
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
    final hasPhoneError = _phoneError != null;
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
                  'Forgot password',
                  style: TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your phone number to receive a reset code.',
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
                Column(
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
                          color: hasPhoneError
                              ? const Color(0xFFD32F2F)
                              : Colors.transparent,
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
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: phoneInputFormatters,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: kPhoneHint,
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
                    if (hasPhoneError)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          _phoneError!,
                          style: const TextStyle(
                            color: Color(0xFFD32F2F),
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _canSubmit ? _sendCode : null,
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
                      _isLoading ? 'Sending...' : 'Send code',
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
}
