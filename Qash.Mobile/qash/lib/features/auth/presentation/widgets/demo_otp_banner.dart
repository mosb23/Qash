import 'package:flutter/material.dart';
import 'package:qash/core/theme/qash_theme_extension.dart';

/// Visible reminder that OTP is demo/local-only, not production SMS.
class DemoOtpBanner extends StatelessWidget {
  const DemoOtpBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final qash = context.qash;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: qash.accent.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: qash.border),
      ),
      child: Text(
        'Demo mode: no SMS is sent. Use the demo code shown below.',
        style: TextStyle(
          color: qash.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.35,
        ),
      ),
    );
  }
}
