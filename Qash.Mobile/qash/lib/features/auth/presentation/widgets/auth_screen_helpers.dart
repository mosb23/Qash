import 'package:flutter/material.dart';
import 'package:qash/core/theme/qash_theme_extension.dart';

TextStyle authTitleStyle(BuildContext context) {
  final qash = context.qash;
  return TextStyle(
    color: qash.textPrimary,
    fontSize: 24,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w500,
  );
}

TextStyle authSubtitleStyle(BuildContext context) {
  final qash = context.qash;
  return TextStyle(
    color: qash.textSecondary,
    fontSize: 16,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400,
  );
}

TextStyle authLabelStyle(BuildContext context) {
  final qash = context.qash;
  return TextStyle(
    color: qash.textPrimary,
    fontSize: 14,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w500,
  );
}

TextStyle authLinkStyle(BuildContext context) {
  final qash = context.qash;
  return TextStyle(
    color: qash.textPrimary,
    fontSize: 16,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w500,
  );
}

TextStyle authMutedBodyStyle(BuildContext context) {
  final qash = context.qash;
  return TextStyle(
    color: qash.textSecondary,
    fontSize: 14,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400,
  );
}

Widget authPrimaryButton({
  required BuildContext context,
  required String label,
  required VoidCallback? onTap,
  bool enabled = true,
}) {
  final qash = context.qash;
  return GestureDetector(
    onTap: enabled ? onTap : null,
    child: Container(
      width: double.infinity,
      height: 56,
      decoration: ShapeDecoration(
        color: enabled ? qash.primaryButton : qash.textHint,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: qash.onPrimaryButton,
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ),
  );
}
