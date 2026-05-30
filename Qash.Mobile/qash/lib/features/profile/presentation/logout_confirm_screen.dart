import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qash/core/theme/qash_theme_extension.dart';

import '../../auth/providers/auth_providers.dart';
import '../../../core/assets/qash_icons.dart';
import '../../../core/auth/auth_state.dart';
import '../../../core/widgets/qash_icon.dart';

class LogoutConfirmScreen extends ConsumerWidget {
  const LogoutConfirmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qash = context.qash;

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
          'Sign Out',
          style: TextStyle(
            color: qash.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: qash.danger.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const QashIcon(
                assetPath: QashIcons.profileLogout,
                fallback: Icons.logout,
                size: 36,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Are you sure you want to sign out?',
              style: TextStyle(fontSize: 16, color: qash.textPrimary),
            ),
            const SizedBox(height: 32),
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
                onPressed: () async {
                  await ref.read(logoutUseCaseProvider)();
                  ref.read(authStatusProvider.notifier).setUnauthenticated();
                  if (!context.mounted) return;
                  context.go('/login');
                },
                child: const Text('Sign Out'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: qash.textPrimary,
                  side: BorderSide(color: qash.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
