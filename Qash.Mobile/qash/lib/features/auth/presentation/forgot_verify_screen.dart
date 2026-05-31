import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/input/text_input_formatters.dart';
import '../domain/entities/auth_requests.dart';
import '../providers/auth_providers.dart';

class ForgotVerifyScreen extends ConsumerStatefulWidget {
  final String? phoneNumber;
  final String? demoCode;

  const ForgotVerifyScreen({super.key, this.phoneNumber, this.demoCode});

  @override
  ConsumerState<ForgotVerifyScreen> createState() => _ForgotVerifyScreenState();
}

class _ForgotVerifyScreenState extends ConsumerState<ForgotVerifyScreen> {
  final TextEditingController _codeController = TextEditingController();

  bool _isLoading = false;
  bool _hasSubmitted = false;
  String? _codeError;

  int _secondsLeft = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(_onFormChanged);
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
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

  bool get _canVerify =>
      !_isLoading && _validateCode(_codeController.text) == null;

  Future<void> _verifyCode() async {
    setState(() {
      _hasSubmitted = true;
      _codeError = _validateCode(_codeController.text);
    });

    if (_codeError != null) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => _isLoading = false);

    final phone = widget.phoneNumber ?? '';
    final code = _codeController.text.trim();
    final phoneParam = Uri.encodeComponent(phone);
    final codeParam = Uri.encodeComponent(code);
    context.go('/forgot-reset?phone=$phoneParam&code=$codeParam');
  }

  Future<void> _resendCode() async {
    final phone = widget.phoneNumber ?? '';
    if (phone.isEmpty) return;

    _startCountdown();

    final requestCode = ref.read(requestForgotPasswordCodeUseCaseProvider);
    final response = await requestCode(
      ForgotPasswordCodeRequestData(phoneNumber: phone),
    );

    if (!mounted) return;

    if (response.isSuccess) {
      final newCode = response.data?.verificationCode ?? '';
      _showMessage(
        newCode.isNotEmpty ? 'Code resent. Demo code: $newCode' : 'Code resent.',
      );
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
    final phone = widget.phoneNumber ?? '';
    final demoCode = widget.demoCode ?? '';

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
                  'Verify code',
                  style: TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  phone.isEmpty
                      ? 'Enter the 5-digit code sent to your phone.'
                      : 'Enter the 5-digit code sent to $phone.',
                  style: const TextStyle(
                    color: Color(0xFF8B8B8B),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 40),
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
                _buildCodeField(),
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
                if (demoCode.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Demo code: $demoCode',
                    style: const TextStyle(
                      color: Color(0xFF8B8B8B),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _canVerify ? _verifyCode : null,
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
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () => context.go('/forgot-password'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF111111),
                      side: const BorderSide(color: Color(0xFF9CA3AF)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Change phone number',
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
          ),
      ],
    );
  }
}
