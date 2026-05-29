import 'package:flutter/material.dart';
import 'package:qash/core/theme/qash_theme_extension.dart';

class HelpFaqScreen extends StatelessWidget {
  const HelpFaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final qash = context.qash;
    return Scaffold(
      backgroundColor: qash.scaffoldBackground,
      body: Column(
        children: [
          const _PageHeader(title: 'Help and FAQ'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              children: [
                ..._faqSections.map((section) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color: qash.textSecondary,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...section.items.map(
                          (item) => _FaqItem(
                            question: item.question,
                            answer: item.answer,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: qash.primaryButton,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Still need help?',
                        style: TextStyle(fontSize: 16, color: qash.onPrimaryButton),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Our support team is available Mon-Fri, 9am-6pm.',
                        style: TextStyle(
                          fontSize: 12,
                          color: qash.onPrimaryButton.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: qash.accent,
                            foregroundColor: qash.onAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {},
                          icon: const Icon(Icons.mail_outline),
                          label: const Text('Email Support'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: qash.onPrimaryButton.withValues(alpha: 0.12),
                            foregroundColor: qash.onPrimaryButton,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {},
                          icon: const Icon(Icons.chat_bubble_outline),
                          label: const Text('Live Chat'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final qash = context.qash;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: qash.textPrimary,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: qash.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  const _FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final qash = context.qash;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => setState(() => _open = !_open),
        child: Container(
          decoration: BoxDecoration(
            color: qash.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: qash.cardShadow,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.question,
                        style: TextStyle(
                          fontSize: 14,
                          color: qash.textPrimary,
                        ),
                      ),
                    ),
                    Icon(
                      _open
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: qash.textSecondary,
                    ),
                  ],
                ),
              ),
              if (_open)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: qash.border)),
                  ),
                  child: Text(
                    widget.answer,
                    style: TextStyle(
                      fontSize: 13,
                      color: qash.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqSection {
  const _FaqSection({required this.category, required this.items});

  final String category;
  final List<_FaqItemData> items;
}

class _FaqItemData {
  const _FaqItemData({required this.question, required this.answer});

  final String question;
  final String answer;
}

const List<_FaqSection> _faqSections = [
  _FaqSection(
    category: 'Getting Started',
    items: [
      _FaqItemData(
        question: 'How do I add a wallet?',
        answer:
            'Go to the Wallets tab or tap "See all" on the Home screen. Press the + button in the top right corner to create a new wallet. Choose the wallet type (Bank, Cash, or Savings), give it a name, and set a currency.',
      ),
      _FaqItemData(
        question: 'What wallet types does Qash support?',
        answer:
            'Qash supports three wallet types: Bank Account (debit or credit cards), Cash (physical money), and Savings (savings accounts and deposits). Each wallet tracks its balance independently.',
      ),
      _FaqItemData(
        question: 'Can I have multiple currencies?',
        answer:
            'Yes. Each wallet can have its own currency. Your home total only includes wallets that match your selected display currency—Qash does not convert amounts between currencies.',
      ),
    ],
  ),
  _FaqSection(
    category: 'Transactions',
    items: [
      _FaqItemData(
        question: 'How do I add a transaction?',
        answer:
            'Tap the Transactions tab and press "Add Transaction". Choose between Income, Expense, or Transfer. Select a category, enter the amount, pick a wallet and date, add a note, then save.',
      ),
      _FaqItemData(
        question: 'Can I edit or delete a transaction?',
        answer:
            'Yes. Open any transaction from the list, tap the edit icon to update it, or scroll down to tap "Delete". Deletion is permanent and cannot be undone.',
      ),
      _FaqItemData(
        question: 'How do I search transactions?',
        answer:
            'On the Transactions screen, tap the search icon in the top right. You can also use the filter chips (All, Income, Expense, Transfer) to narrow down the list.',
      ),
    ],
  ),
  _FaqSection(
    category: 'Budgets and Goals',
    items: [
      _FaqItemData(
        question: 'How do I set a monthly budget?',
        answer:
            'Go to the Budgets section (accessible from the Home screen or navigation). Tap the + button and choose a spending category and a monthly limit.',
      ),
      _FaqItemData(
        question: 'What happens when I exceed a budget?',
        answer:
            'Qash will show a warning on the budget card and send you a notification. The budget progress bar turns red when you are over the limit.',
      ),
      _FaqItemData(
        question: 'How do I add funds to a savings goal?',
        answer:
            'Open a goal from the Goals tab and tap "Add Funds". Enter the amount you want to add. Your progress percentage will update automatically.',
      ),
    ],
  ),
  _FaqSection(
    category: 'Account and Security',
    items: [
      _FaqItemData(
        question: 'How do I reset my password?',
        answer:
            'On the Login screen, tap "Forgot password?". Enter your phone number, use the demo verification code, then create a new password.',
      ),
      _FaqItemData(
        question: 'Is my financial data secure?',
        answer:
            'Qash protects your session token with secure storage on supported devices and does not connect to or store raw banking credentials.',
      ),
      _FaqItemData(
        question: 'How do I delete my account?',
        answer:
            'Go to Profile > Settings > Delete Account. You will need to type "DELETE" to confirm. This action is permanent and removes all your data.',
      ),
    ],
  ),
];
