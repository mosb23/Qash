import 'package:flutter/material.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: const Color(0xFFF3F4F6), width: 1.4),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 6,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(
            label: 'Home',
            icon: Icons.home_rounded,
            isActive: currentTab == AppTab.home,
            onTap: () => onSelected(AppTab.home),
          ),
          _navItem(
            label: 'Transactions',
            icon: Icons.swap_horiz_rounded,
            isActive: currentTab == AppTab.transactions,
            onTap: () => onSelected(AppTab.transactions),
          ),
          _navItem(
            label: 'Analytics',
            icon: Icons.bar_chart_rounded,
            isActive: currentTab == AppTab.analytics,
            onTap: () => onSelected(AppTab.analytics),
          ),
          _navItem(
            label: 'Goals',
            icon: Icons.flag_rounded,
            isActive: currentTab == AppTab.goals,
            onTap: () => onSelected(AppTab.goals),
          ),
          _navItem(
            label: 'Profile',
            icon: Icons.person_rounded,
            isActive: currentTab == AppTab.profile,
            onTap: () => onSelected(AppTab.profile),
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 40,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFF4D93A) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: isActive
                  ? const Color(0xFF111111)
                  : const Color(0xFF8B8B8B),
              size: 20,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isActive
                  ? const Color(0xFF111111)
                  : const Color(0xFF8B8B8B),
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
