import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/input/text_input_formatters.dart';
import '../../../core/providers/user_session_invalidation.dart';
import '../../../core/validation/contact_validation.dart';
import '../domain/entities/auth_requests.dart';
import '../providers/auth_providers.dart';

class VerifyPhoneScreen extends ConsumerStatefulWidget {
  final String? phoneNumber;

  const VerifyPhoneScreen({super.key, this.phoneNumber});

  @override
  ConsumerState<VerifyPhoneScreen> createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends ConsumerState<VerifyPhoneScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  bool _isLoading = false;
  bool _hasSubmitted = false;
  String? _phoneError;
  String? _codeError;

  int _secondsLeft = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.phoneNumber != null) {
      _phoneController.text = widget.phoneNumber!;
    }
    _phoneController.addListener(_onFormChanged);
    _codeController.addListener(_onFormChanged);
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsLeft = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          t.cancel();
        }
      });
    });
  }

  void _onFormChanged() {
    if (!mounted) return;
    setState(() {
      if (_hasSubmitted) {
        _phoneError = validatePhoneNumber11Digits(_phoneController.text);
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

  bool get _canSubmit {
    final phone = _phoneController.text.trim();
    final code = _codeController.text.trim();
    return !_isLoading &&
        validatePhoneNumber11Digits(phone) == null &&
        _validateCode(code) == null;
  }

  Future<void> _verify() async {
    setState(() {
      _hasSubmitted = true;
      _phoneError = validatePhoneNumber11Digits(_phoneController.text);
      _codeError = _validateCode(_codeController.text);
    });

    if (_phoneError != null || _codeError != null) return;

    setState(() => _isLoading = true);

    final verifyPhone = ref.read(verifyPhoneUseCaseProvider);
    final response = await verifyPhone(
      PhoneVerificationData(
        phoneNumber: _phoneController.text.trim(),
        verificationCode: _codeController.text.trim(),
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

  void _resendCode() {
    _startCountdown();
    _showMessage('Demo code: 00000');
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 56),
                const Text(
                  'Verify your phone',
                  style: TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter the 5-digit code sent to your phone.',
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
                  'Verification code',
                  style: TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                _buildInputField(
                  controller: _codeController,
                  hint: '00000',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    ...digitsOnlyInputFormatters,
                    LengthLimitingTextInputFormatter(5),
                  ],
                  errorText: _codeError,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _secondsLeft > 0
                          ? 'Resend code in ${_secondsLeft}s'
                          : 'Did not receive the code?',
                      style: const TextStyle(
                        color: Color(0xFF8B8B8B),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    GestureDetector(
                      onTap: _secondsLeft == 0 ? _resendCode : null,
                      child: Text(
                        'Resend',
                        style: TextStyle(
                          color: _secondsLeft == 0
                              ? const Color(0xFF111111)
                              : const Color(0xFF9CA3AF),
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
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
                    onPressed: _canSubmit ? _verify : null,
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
                      _isLoading ? 'Verifying...' : 'Verify',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
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
}
