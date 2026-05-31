import 'package:flutter/material.dart';

import '../validation/password_policy.dart';

class PasswordRequirementsWidget extends StatelessWidget {
  const PasswordRequirementsWidget({
    super.key,
    required this.policy,
    required this.showValidation,
  });

  final PasswordPolicyResult policy;
  final bool showValidation;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RequirementItem(
          text: 'At least 8 characters',
          met: policy.hasMinLength,
          showValidation: showValidation,
        ),
        _RequirementItem(
          text: 'At least 1 uppercase letter',
          met: policy.hasUppercase,
          showValidation: showValidation,
        ),
        _RequirementItem(
          text: 'At least 1 lowercase letter',
          met: policy.hasLowercase,
          showValidation: showValidation,
        ),
        _RequirementItem(
          text: 'At least 1 number',
          met: policy.hasNumber,
          showValidation: showValidation,
        ),
      ],
    );
  }
}

class _RequirementItem extends StatelessWidget {
  const _RequirementItem({
    required this.text,
    required this.met,
    required this.showValidation,
  });

  final String text;
  final bool met;
  final bool showValidation;

  @override
  Widget build(BuildContext context) {
    final color = met
        ? const Color(0xFF00A63E)
        : showValidation
        ? const Color(0xFFD32F2F)
        : const Color(0xFF8B8B8B);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '${met ? '✓' : '•'} $text',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
