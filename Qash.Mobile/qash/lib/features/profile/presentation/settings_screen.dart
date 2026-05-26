import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _biometrics = true;
  bool _autoBackup = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F6F3),
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: [
          _SectionCard(
            title: 'Appearance',
            children: [
              _ToggleRow(
                icon: Icons.nightlight_round,
                iconBg: const Color(0xFFEDE9FE),
                iconColor: const Color(0xFF8B5CF6),
                label: 'Dark Mode',
                sublabel: 'Switch to dark theme',
                value: _darkMode,
                onChanged: (value) => setState(() => _darkMode = value),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Security',
            children: [
              _ToggleRow(
                icon: Icons.shield_outlined,
                iconBg: const Color(0xFFD9F0C8),
                iconColor: const Color(0xFF10B981),
                label: 'Biometric Login',
                sublabel: 'Face ID or Fingerprint',
                value: _biometrics,
                onChanged: (value) => setState(() => _biometrics = value),
              ),
              _ToggleRow(
                icon: Icons.public,
                iconBg: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF3B82F6),
                label: 'Auto Backup',
                sublabel: 'Backup data to cloud',
                value: _autoBackup,
                onChanged: (value) => setState(() => _autoBackup = value),
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
                icon: Icons.lock_outline,
                iconBg: const Color(0xFFEDE9FE),
                iconColor: const Color(0xFF8B5CF6),
                label: 'Privacy Policy',
                onTap: () => context.push('/profile/privacy'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Danger Zone',
            children: [
              _LinkRow(
                icon: Icons.delete_outline,
                iconBg: const Color(0xFFFEE2E2),
                iconColor: const Color(0xFFEF4444),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF8B8B8B),
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
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF111111),
                  ),
                ),
                Text(
                  sublabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8B8B8B),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: const Color(0xFF111111),
            onChanged: onChanged,
          ),
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
    final labelColor = danger ? const Color(0xFFEF4444) : const Color(0xFF111111);

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
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8B8B8B),
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF8B8B8B)),
          ],
        ),
      ),
    );
  }
}
