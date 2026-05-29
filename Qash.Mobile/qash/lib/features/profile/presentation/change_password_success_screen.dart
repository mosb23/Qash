import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qash/core/theme/qash_theme_extension.dart';

import '../../auth/presentation/widgets/auth_screen_helpers.dart';

class ProfileChangePasswordSuccessScreen extends StatelessWidget {
  const ProfileChangePasswordSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final qash = context.qash;

    return Scaffold(
      backgroundColor: qash.scaffoldBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: qash.accent.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        Icons.check_circle_outline,
                        size: 32,
                        color: qash.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Password changed',
                      textAlign: TextAlign.center,
                      style: authTitleStyle(context).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your password has been updated. You can continue using the app.',
                      textAlign: TextAlign.center,
                      style: authSubtitleStyle(context).copyWith(height: 1.4),
                    ),
                  ],
                ),
              ),
              authPrimaryButton(
                context: context,
                label: 'Back to profile',
                onTap: () => context.go('/profile'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
