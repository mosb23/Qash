import 'package:flutter/material.dart';

import '../assets/qash_icons.dart';
import '../theme/qash_theme_extension.dart';
import 'qash_icon.dart';

enum AppTab { home, transactions, analytics, goals, profile }

class AppBottomNavBar extends StatelessWidget {
  final AppTab currentTab;
  final ValueChanged<AppTab> onSelected;

  const AppBottomNavBar({
    super.key,
    required this.currentTab,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final qash = context.qash;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: qash.navBarBackground,
        border: Border(top: BorderSide(color: qash.navBarBorder, width: 1.4)),
        boxShadow: [
          BoxShadow(
            color: qash.cardShadow,
            blurRadius: 6,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(
            context: context,
            label: 'Home',
            assetPath: QashIcons.navHome,
            fallback: Icons.home_rounded,
            isActive: currentTab == AppTab.home,
            onTap: () => onSelected(AppTab.home),
          ),
          _navItem(
            context: context,
            label: 'Transactions',
            assetPath: QashIcons.navTransactions,
            fallback: Icons.swap_horiz_rounded,
            isActive: currentTab == AppTab.transactions,
            onTap: () => onSelected(AppTab.transactions),
          ),
          _navItem(
            context: context,
            label: 'Analytics',
            assetPath: QashIcons.navAnalytics,
            fallback: Icons.bar_chart_rounded,
            isActive: currentTab == AppTab.analytics,
            onTap: () => onSelected(AppTab.analytics),
          ),
          _navItem(
            context: context,
            label: 'Goals',
            assetPath: QashIcons.navGoals,
            fallback: Icons.flag_rounded,
            isActive: currentTab == AppTab.goals,
            onTap: () => onSelected(AppTab.goals),
          ),
          _navItem(
            context: context,
            label: 'Profile',
            assetPath: QashIcons.navProfile,
            fallback: Icons.person_rounded,
            isActive: currentTab == AppTab.profile,
            onTap: () => onSelected(AppTab.profile),
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required BuildContext context,
    required String label,
    String? assetPath,
    required IconData fallback,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final qash = context.qash;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 40,
            decoration: BoxDecoration(
              color: isActive ? qash.accent : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: QashIcon(
                assetPath: assetPath,
                fallback: fallback,
                size: 22,
                color: isActive ? qash.onAccent : qash.iconMuted,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isActive ? qash.onAccent : qash.iconMuted,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
