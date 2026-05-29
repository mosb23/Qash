import 'package:flutter/material.dart';


class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const List<Map<String, String>> _sections = [
    {
      'title': '1. Information We Collect',
      'body':
          'Qash collects information you provide directly, including your name, email address, and financial data you enter (wallets, transactions, budgets, goals). We do not connect to your bank accounts or collect banking credentials.',
    },
    {
      'title': '2. How We Use Your Data',
      'body':
          'Your data is used solely to power the Qash app experience — displaying your financial overview, calculating budgets, and tracking goals. We do not sell, rent, or share your personal data with third parties for marketing purposes.',
    },
    {
      'title': '3. Data Storage & Security',
      'body':
          'All data is encrypted in transit using TLS and at rest using AES-256 encryption. We store your data on secure servers with strict access controls. You can enable biometric authentication for additional device-level security.',
    },
    {
      'title': '4. Data Retention',
      'body':
          'Your data is retained as long as your account is active. If you delete your account, all associated data is permanently removed from our servers within 30 days. Some anonymized aggregate data may be retained for analytics.',
    },
    {
      'title': '5. Cookies & Analytics',
      'body':
          'Qash uses minimal analytics to understand app usage patterns and improve performance. This data is aggregated and anonymous. No personally identifiable information is used for analytics.',
    },
    {
      'title': '6. Third-Party Services',
      'body':
          'Qash may use trusted third-party services for cloud infrastructure and crash reporting. These services are bound by strict data processing agreements and are not permitted to use your data for their own purposes.',
    },
    {
      'title': '7. Your Rights',
      'body':
          'You have the right to access, correct, export, or delete your personal data at any time from within the app settings. You may also request data deletion by contacting our support team.',
    },
    {
      'title': '8. Children\'s Privacy',
      'body':
          'Qash is not intended for children under 18. We do not knowingly collect data from minors. If you believe a minor has created an account, contact us and we will remove the data promptly.',
    },
    {
      'title': '9. Changes to This Policy',
      'body':
          'We may update this Privacy Policy from time to time. We will notify you of significant changes through in-app notifications. Your continued use of Qash after changes indicates acceptance.',
    },
    {
      'title': '10. Contact Us',
      'body':
          'For privacy-related questions or requests, contact our Data Protection team at privacy@qash.app or through the app support channels.',
    },
  ];

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
          'Privacy Policy',
          style: TextStyle(
            color: Color(0xFF111111),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE9FE),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('🛡️', style: TextStyle(fontSize: 20)),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Last updated: May 2026',
                                  style: TextStyle(
                                    color: Color(0xFF111111),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Your privacy matters. Here\'s how we handle your data.',
                                  style: TextStyle(
                                    color: Color(0x99111111),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: const [
                        Expanded(child: _TrustBadge('🔒', 'End-to-end\nencrypted')),
                        SizedBox(width: 12),
                        Expanded(child: _TrustBadge('🚫', 'Never sold to\n3rd parties')),
                        SizedBox(width: 12),
                        Expanded(child: _TrustBadge('🗑️', 'Delete\nanytime')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ..._sections.map(
                      (section) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _sectionCard(
                          section['title']!,
                          section['body']!,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF111111),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Got It',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard(String title, String body) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 2,
            offset: Offset(0, 1),
            spreadRadius: -1,
          ),
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF111111),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              color: Color(0xFF8B8B8B),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  final String emoji;
  final String label;

  const _TrustBadge(this.emoji, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 2,
            offset: Offset(0, 1),
            spreadRadius: -1,
          ),
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Color(0xFF8B8B8B)),
          ),
        ],
      ),
    );
  }
}
