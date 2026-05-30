import 'package:flutter/material.dart';
import 'package:qash/core/theme/qash_theme_extension.dart';


class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  static const List<Map<String, String>> _sections = [
    {
      'title': '1. Acceptance of Terms',
      'body':
          'By accessing and using Qash, you accept and agree to be bound by these Terms and Conditions. If you do not agree to these terms, please do not use our services.',
    },
    {
      'title': '2. Use of the App',
      'body':
          'Qash is a personal finance management application. You agree to use it only for lawful purposes and in a way that does not infringe the rights of others. You must be at least 18 years old to use this service.',
    },
    {
      'title': '3. Account Responsibility',
      'body':
          'You are responsible for maintaining the confidentiality of your account credentials. You agree to notify us immediately of any unauthorized access to your account. Qash is not liable for any loss arising from unauthorized use of your account.',
    },
    {
      'title': '4. Data Accuracy',
      'body':
          'Qash relies on data you provide. We are not responsible for financial decisions made based on information entered into the app. Always verify important financial figures with your bank or financial institution.',
    },
    {
      'title': '5. Intellectual Property',
      'body':
          'All content, branding, and features within Qash are the intellectual property of Qash Inc. You may not copy, modify, distribute, or create derivative works without express written permission.',
    },
    {
      'title': '6. Limitation of Liability',
      'body':
          'Qash is provided "as is" without warranties of any kind. We are not liable for any indirect, incidental, or consequential damages arising from your use of the application.',
    },
    {
      'title': '7. Modifications',
      'body':
          'We reserve the right to modify these terms at any time. Changes will be communicated through the app. Continued use after changes constitutes acceptance of the updated terms.',
    },
    {
      'title': '8. Governing Law',
      'body':
          'These Terms are governed by the laws of the applicable jurisdiction. Any disputes will be resolved through binding arbitration.',
    },
    {
      'title': '9. Contact',
      'body':
          'For questions about these Terms, contact us at legal@qash.app or through the app support channels.',
    },
  ];

  @override
  Widget build(BuildContext context) {
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
          'Terms & Conditions',
          style: TextStyle(
            color: qash.textPrimary,
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
                        color: qash.accent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('📋', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Last updated: May 2026',
                                  style: TextStyle(
                                    color: qash.onAccent,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Please read these terms carefully before using Qash.',
                                  style: TextStyle(
                                    color: qash.onAccent.withValues(alpha: 0.6),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ..._sections.map(
                      (section) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _sectionCard(
                          context,
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
                          backgroundColor: qash.primaryButton,
                          foregroundColor: qash.onPrimaryButton,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'I Understand & Accept',
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

  Widget _sectionCard(BuildContext context, String title, String body) {
    final qash = context.qash;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: qash.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: qash.cardShadow,
            blurRadius: 2,
            offset: const Offset(0, 1),
            spreadRadius: -1,
          ),
          BoxShadow(
            color: qash.cardShadow,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: qash.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              color: qash.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
