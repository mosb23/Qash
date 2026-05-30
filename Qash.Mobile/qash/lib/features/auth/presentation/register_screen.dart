import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qash/core/theme/qash_theme_extension.dart';

import '../domain/entities/auth_requests.dart';
import '../providers/auth_providers.dart';
import 'widgets/auth_password_field.dart';
import 'widgets/auth_screen_helpers.dart';
import 'widgets/auth_text_field.dart';

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
  bool _isLoading = false;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessage('Fill in all fields.');
      return;
    }

    if (password != confirmPassword) {
      _showMessage('Passwords do not match.');
      return;
    }

    if (!_acceptedTerms) {
      _showMessage('Please accept the Terms of Service and Privacy Policy.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

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

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    if (response.isSuccess) {
      context.go('/verify?phone=$phone');
    } else {
      _showMessage(
        response.errors.isNotEmpty
            ? response.errors.join('\n')
            : response.message,
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final qash = context.qash;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            color: qash.scaffoldBackground,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 56),
                Text('Create Account', style: authTitleStyle(context)),
                const SizedBox(height: 8),
                Text('Start your financial journey', style: authSubtitleStyle(context)),
                const SizedBox(height: 40),
                Text('First name', style: authLabelStyle(context)),
                const SizedBox(height: 8),
                AuthTextField(controller: _firstNameController, hintText: 'Akmal'),
                const SizedBox(height: 16),
                Text('Last name', style: authLabelStyle(context)),
                const SizedBox(height: 8),
                AuthTextField(controller: _lastNameController, hintText: 'Nasruddin'),
                const SizedBox(height: 16),
                Text('Email address', style: authLabelStyle(context)),
                const SizedBox(height: 8),
                AuthTextField(
                  controller: _emailController,
                  hintText: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                Text('Phone number', style: authLabelStyle(context)),
                const SizedBox(height: 8),
                AuthTextField(
                  controller: _phoneController,
                  hintText: '+20 1xx xxx xxxx',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                Text('Password', style: authLabelStyle(context)),
                const SizedBox(height: 8),
                _passwordField(
                  controller: _passwordController,
                  hintText: 'Min. 8 characters',
                ),
                const SizedBox(height: 16),
                Text('Confirm password', style: authLabelStyle(context)),
                const SizedBox(height: 8),
                _passwordField(
                  controller: _confirmPasswordController,
                  hintText: 'Repeat your password',
                ),
                const SizedBox(height: 16),
                _termsAgreementRow(context),
                const SizedBox(height: 24),
                authPrimaryButton(
                  context: context,
                  label: _isLoading ? 'Creating...' : 'Create Account',
                  onTap: _isLoading || !_acceptedTerms ? null : _register,
                  enabled: _acceptedTerms && !_isLoading,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? ', style: authMutedBodyStyle(context)),
                    GestureDetector(
                      onTap: () {
                        context.pop();
                      },
                      child: Text('Sign In', style: authLinkStyle(context)),
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

  Widget _passwordField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return AuthPasswordField(controller: controller, hintText: hintText);
  }

  Widget _termsAgreementRow(BuildContext context) {
    final qash = context.qash;
    final bodyStyle = TextStyle(
      color: qash.textSecondary,
      fontSize: 12,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w400,
      height: 1.4,
    );
    final linkStyle = TextStyle(
      color: qash.textPrimary,
      fontSize: 12,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w500,
      decoration: TextDecoration.underline,
      height: 1.4,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _acceptedTerms,
            onChanged: (value) {
              setState(() => _acceptedTerms = value ?? false);
            },
            activeColor: qash.primaryButton,
            checkColor: qash.onPrimaryButton,
            side: BorderSide(color: qash.border, width: 1.5),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: bodyStyle,
              children: [
                const TextSpan(text: 'I agree to the '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: GestureDetector(
                    onTap: () => context.push('/profile/terms'),
                    child: Text('Terms of Service', style: linkStyle),
                  ),
                ),
                const TextSpan(text: ' and '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: GestureDetector(
                    onTap: () => context.push('/profile/privacy'),
                    child: Text('Privacy Policy', style: linkStyle),
                  ),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
