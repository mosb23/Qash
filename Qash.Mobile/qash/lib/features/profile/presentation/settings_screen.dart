import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/qash_theme_extension.dart';
import '../../../core/theme/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _appVersion = '1.0.0';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qash = context.qash;
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

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
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: [
          _SectionCard(
            title: 'Account',
            children: [
              _LinkRow(
                icon: Icons.person_outline,
                iconBg: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF3B82F6),
                label: 'Edit Profile',
                sublabel: 'Update your personal info',
                onTap: () => context.push('/profile/edit'),
              ),
              _LinkRow(
                icon: Icons.lock_outline,
                iconBg: const Color(0xFFEDE9FE),
                iconColor: const Color(0xFF8B5CF6),
                label: 'Change Password',
                sublabel: 'Update your password',
                onTap: () => context.push('/profile/change-verify'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Appearance',
            children: [
              _ToggleRow(
                icon: Icons.dark_mode_outlined,
                iconBg: const Color(0xFFEDE9FE),
                iconColor: const Color(0xFF8B5CF6),
                label: 'Dark Mode',
                sublabel: 'Use dark theme across the app',
                value: isDark,
                onChanged: (value) {
                  ref.read(themeModeProvider.notifier).setDarkMode(value);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Support',
            children: [
              _LinkRow(
                icon: Icons.help_outline,
                iconBg: const Color(0xFFD9F0C8),
                iconColor: const Color(0xFF10B981),
                label: 'Help and FAQ',
                sublabel: 'Answers to common questions',
                onTap: () => context.push('/profile/help'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Legal',
            children: [
              _LinkRow(
                icon: Icons.description_outlined,
                iconBg: const Color(0xFFFEF3C7),
                iconColor: const Color(0xFFF59E0B),
                label: 'Terms and Conditions',
                onTap: () => context.push('/profile/terms'),
              ),
              _LinkRow(
                icon: Icons.privacy_tip_outlined,
                iconBg: const Color(0xFFEDE9FE),
                iconColor: const Color(0xFF8B5CF6),
                label: 'Privacy Policy',
                onTap: () => context.push('/profile/privacy'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'About',
            children: [
              _InfoRow(
                icon: Icons.info_outline,
                iconBg: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF3B82F6),
                label: 'App Version',
                value: _appVersion,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Danger Zone',
            children: [
              _LinkRow(
                icon: Icons.logout,
                iconBg: const Color(0xFFFEE2E2),
                iconColor: qash.danger,
                label: 'Sign Out',
                sublabel: 'Log out of your account',
                onTap: () => context.push('/profile/logout'),
                danger: true,
              ),
              _LinkRow(
                icon: Icons.delete_outline,
                iconBg: const Color(0xFFFEE2E2),
                iconColor: qash.danger,
                label: 'Delete Account',
                sublabel: 'Permanently delete all data',
                onTap: () => context.push('/profile/delete'),
                danger: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final qash = context.qash;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: qash.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: qash.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              color: qash.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          ...children,
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.sublabel,
    required this.value,
    required this.onChanged,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  final String label;
  final String sublabel;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final qash = context.qash;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 14, color: qash.textPrimary),
                ),
                Text(
                  sublabel,
                  style: TextStyle(fontSize: 12, color: qash.textSecondary),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.label,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
    this.sublabel,
    this.danger = false,
  });

  final String label;
  final String? sublabel;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final qash = context.qash;
    final labelColor = danger ? qash.danger : qash.textPrimary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 14, color: labelColor),
                  ),
                  if (sublabel != null)
                    Text(
                      sublabel!,
                      style: TextStyle(fontSize: 12, color: qash.textSecondary),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: qash.iconMuted),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final qash = context.qash;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: qash.textPrimary),
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 14, color: qash.textSecondary),
          ),
        ],
      ),
    );
  }
}
