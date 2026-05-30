import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qash/core/theme/qash_theme_extension.dart';

import '../../../core/assets/qash_icons.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../../../core/widgets/qash_icon.dart';
import '../../../core/utils/result.dart';
import '../../goals/providers/saving_goals_providers.dart';
import '../../transactions/providers/transactions_providers.dart';
import '../../wallets/providers/wallets_providers.dart';
import '../providers/profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qash = context.qash;
    final profileAsync = ref.watch(profileProvider);
    final walletsAsync = ref.watch(walletsProvider);
    final transactionsAsync = ref.watch(transactionsProvider);
    final goalsAsync = ref.watch(savingGoalsProvider);

    final walletCount = _countResult(walletsAsync);
    final transactionCount = _countResult(transactionsAsync);
    final goalCount = _countResult(goalsAsync);

    return Scaffold(
      bottomNavigationBar: AppBottomNavBar(
        currentTab: AppTab.profile,
        onSelected: (tab) => _onTabSelected(context, tab),
      ),
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
              child: Row(
                children: [
                  Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: qash.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
              children: [
                profileAsync.when(
                  data: (result) {
                    final profile = result.data;
                    final name = profile?.resolvedName ?? 'User';
                    final email = profile?.email ?? '';
                    final phone = profile?.phoneNumber ?? '';
                    final initials = profile?.alias ?? 'UN';

                    return InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => context.push('/profile/edit'),
                      child: Container(
                        padding: const EdgeInsets.all(18),
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
                        child: Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFF4D93A),
                              ),
                              child: Center(
                                child: Text(
                                  initials,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: qash.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    email,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: qash.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    phone,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: qash.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: qash.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, stack) => Text(
                    'Failed to load profile.',
                    style: TextStyle(color: qash.textSecondary, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _StatCard(
                      label: 'Wallets',
                      value: walletCount.toString(),
                      iconAsset: QashIcons.iconWallet,
                      icon: Icons.account_balance_wallet_outlined,
                      color: const Color(0xFFD9F0C8),
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'Transactions',
                      value: transactionCount.toString(),
                      iconAsset: QashIcons.navTransactions,
                      icon: Icons.swap_horiz,
                      color: const Color(0xFFFEF3C7),
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'Goals',
                      value: goalCount.toString(),
                      iconAsset: QashIcons.navGoals,
                      icon: Icons.flag_outlined,
                      color: const Color(0xFFEDE9FE),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _SectionCard(
                  title: 'Account',
                  items: [
                    _MenuItem(
                      icon: Icons.person_outline,
                      label: 'Edit Profile',
                      sublabel: 'Update your info',
                      onTap: () => context.push('/profile/edit'),
                    ),
                    _MenuItem(
                      icon: Icons.shield_outlined,
                      label: 'Change Password',
                      sublabel: 'Keep your account secure',
                      onTap: () => context.push('/profile/change-password'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  title: 'Preferences',
                  items: [
                    _MenuItem(
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      sublabel: 'App preferences',
                      onTap: () => context.push('/profile/settings'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  title: 'Support',
                  items: [
                    _MenuItem(
                      icon: Icons.help_outline,
                      label: 'Help and FAQ',
                      sublabel: 'Get help',
                      onTap: () => context.push('/profile/help'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  title: '',
                  items: [
                    _MenuItem(
                      iconAsset: QashIcons.profileLogout,
                      icon: Icons.logout,
                      label: 'Sign Out',
                      onTap: () => context.push('/profile/logout'),
                      danger: true,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Qash v1.0.0 - Made with love',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: qash.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _countResult(AsyncValue<dynamic> asyncValue) {
    return asyncValue.maybeWhen(
      data: (result) {
        if (result is Result) {
          return (result.data as List?)?.length ?? 0;
        }
        return (result as List?)?.length ?? 0;
      },
      orElse: () => 0,
    );
  }

  void _onTabSelected(BuildContext context, AppTab tab) {
    switch (tab) {
      case AppTab.home:
        context.go('/home');
        return;
      case AppTab.transactions:
        context.go('/transactions');
        return;
      case AppTab.analytics:
        context.go('/analytics');
        return;
      case AppTab.goals:
        context.go('/goals');
        return;
      case AppTab.profile:
        return;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? iconAsset;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    this.iconAsset,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final qash = context.qash;
    final iconColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
            ? Colors.white
            : const Color(0xFF111111);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: qash.surface,
          borderRadius: BorderRadius.circular(20),
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
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: QashIcon(
                assetPath: iconAsset,
                fallback: icon,
                size: 20,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: qash.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: qash.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _SectionCard({required this.title, required this.items});

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
          if (title.isNotEmpty)
            Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                color: qash.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
          if (title.isNotEmpty) const SizedBox(height: 6),
          ...items.map((item) => item),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String? iconAsset;
  final IconData icon;
  final String label;
  final String? sublabel;
  final VoidCallback? onTap;
  final bool danger;

  const _MenuItem({
    this.iconAsset,
    required this.icon,
    required this.label,
    this.sublabel,
    this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final qash = context.qash;
    final labelColor = danger ? qash.danger : qash.textPrimary;
    final subtitleColor = danger ? qash.danger : qash.textSecondary;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: danger
                    ? qash.danger.withValues(alpha: 0.15)
                    : qash.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: QashIcon(
                assetPath: iconAsset,
                fallback: icon,
                size: 22,
                color: labelColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: labelColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (sublabel != null)
                    Text(
                      sublabel!,
                      style: TextStyle(fontSize: 12, color: subtitleColor),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: qash.textSecondary),
          ],
        ),
      ),
    );
  }
}
