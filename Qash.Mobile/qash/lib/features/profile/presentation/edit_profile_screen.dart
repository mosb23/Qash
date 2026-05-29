import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qash/core/theme/qash_theme_extension.dart';

import '../../../core/utils/profile_form_validators.dart';
import '../../auth/presentation/widgets/auth_screen_helpers.dart';
import '../domain/entities/profile_update.dart';
import '../providers/profile_providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _loading = false;
  bool _initialized = false;
  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool _validateFields() {
    final firstName = _firstNameController.text;
    final lastName = _lastNameController.text;
    final email = _emailController.text;

    final firstNameError = ProfileFormValidators.validateFirstName(firstName);
    final lastNameError = ProfileFormValidators.validateLastName(lastName);
    final emailError = ProfileFormValidators.validateEmail(email);

    setState(() {
      _firstNameError = firstNameError;
      _lastNameError = lastNameError;
      _emailError = emailError;
    });

    return firstNameError == null &&
        lastNameError == null &&
        emailError == null;
  }

  Future<void> _handleSave() async {
    if (!_validateFields()) {
      return;
    }

    setState(() => _loading = true);

    final result = await ref.read(updateProfileUseCaseProvider)(
      ProfileUpdateData(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
      ),
    );

    if (!mounted) return;

    setState(() => _loading = false);

    if (result.isSuccess) {
      ref.invalidate(profileProvider);
      Navigator.of(context).maybePop();
      return;
    }

    final message = result.message.isNotEmpty
        ? result.message
        : 'Failed to update profile.';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final qash = context.qash;
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              color: qash.surface,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: qash.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: qash.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: profileAsync.when(
        data: (result) {
          final profile = result.data;
          if (profile != null && !_initialized) {
            _firstNameController.text = profile.firstName;
            _lastNameController.text = profile.lastName;
            _emailController.text = profile.email;
            _phoneController.text = profile.phoneNumber;
            _initialized = true;
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: [
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF4ADE80), Color(0xFF10B981)],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      profile?.alias ?? 'UN',
                      style: const TextStyle(fontSize: 28, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _InputField(
                label: 'First Name',
                controller: _firstNameController,
                keyboardType: TextInputType.name,
                hintText: 'First name',
                errorText: _firstNameError,
                onChanged: (_) {
                  if (_firstNameError != null) {
                    setState(
                      () => _firstNameError = ProfileFormValidators.validateFirstName(
                        _firstNameController.text,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              _InputField(
                label: 'Last Name',
                controller: _lastNameController,
                keyboardType: TextInputType.name,
                hintText: 'Last name',
                errorText: _lastNameError,
                onChanged: (_) {
                  if (_lastNameError != null) {
                    setState(
                      () => _lastNameError = ProfileFormValidators.validateLastName(
                        _lastNameController.text,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              _InputField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                hintText: 'your@email.com',
                errorText: _emailError,
                onChanged: (_) {
                  if (_emailError != null) {
                    setState(
                      () => _emailError = ProfileFormValidators.validateEmail(
                        _emailController.text,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              _InputField(
                label: 'Phone',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                hintText: 'Phone number',
                enabled: false,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: qash.primaryButton,
                    foregroundColor: qash.onPrimaryButton,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: _loading ? null : _handleSave,
                  child: Text(_loading ? 'Saving...' : 'Save Changes'),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Failed to load profile.',
            style: TextStyle(color: qash.textSecondary, fontSize: 12),
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.controller,
    required this.keyboardType,
    required this.hintText,
    this.enabled = true,
    this.errorText,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String hintText;
  final bool enabled;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final qash = context.qash;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: authLabelStyle(context)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          enabled: enabled,
          onChanged: onChanged,
          style: TextStyle(
            fontSize: 14,
            color: enabled ? qash.textPrimary : qash.textSecondary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(fontSize: 14, color: qash.textHint),
            errorText: errorText,
            filled: true,
            fillColor: enabled ? qash.surface : qash.surfaceElevated,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: qash.danger),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: qash.danger),
            ),
          ),
        ),
      ],
    );
  }
}
