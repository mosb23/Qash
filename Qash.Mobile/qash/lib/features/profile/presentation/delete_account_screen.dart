import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qash/core/theme/qash_theme_extension.dart';

import '../../../config/providers.dart';
import '../../auth/presentation/widgets/auth_password_field.dart';
import '../providers/profile_providers.dart';

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete() async {
    final password = _passwordController.text.trim();
    final qash = context.qash;

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your password to continue.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: qash.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete account?',
          style: TextStyle(color: qash.textPrimary, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'This action cannot be undone. Your account and all data will be permanently deleted.',
          style: TextStyle(color: qash.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: qash.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: qash.danger)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    await _handleDelete(password);
  }

  Future<void> _handleDelete(String password) async {
    setState(() => _loading = true);

    final result = await ref.read(deleteProfileUseCaseProvider)(password);

    if (!mounted) return;
    setState(() => _loading = false);

    if (result.isSuccess) {
      await ref.read(secureStorageProvider).clearTokens();
      if (!mounted) return;
      context.go('/login');
      return;
    }

    final message = result.message.isNotEmpty
        ? result.message
        : 'Failed to delete account.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final qash = context.qash;
    final canDelete = _passwordController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
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
        title: const Text('Delete Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will permanently delete your account and data.',
              style: TextStyle(fontSize: 14, color: qash.textSecondary),
            ),
            const SizedBox(height: 24),
            Text(
              'Password',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: qash.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            AuthPasswordField(
              controller: _passwordController,
              hintText: 'Enter your password',
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your password to confirm account deletion.',
              style: TextStyle(fontSize: 12, color: qash.textSecondary),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: canDelete ? qash.danger : qash.danger.withValues(alpha: 0.4),
                  foregroundColor: qash.onPrimaryButton,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: _loading || !canDelete ? null : _confirmDelete,
                child: Text(_loading ? 'Deleting...' : 'Delete Account'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: _loading ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
