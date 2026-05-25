import 'package:flutter/material.dart';

class BudgetDetailScreen extends StatelessWidget {
  const BudgetDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = [
      BudgetTransaction(
        title: 'Lunch at Sushi Place',
        date: '2026-05-14',
        amount: 45.5,
      ),
      BudgetTransaction(
        title: 'Dinner with Friends',
        date: '2026-05-10',
        amount: 30,
      ),
      BudgetTransaction(title: 'Groceries', date: '2026-05-06', amount: 65),
      BudgetTransaction(
        title: 'Restaurant dinner',
        date: '2026-04-10',
        amount: 95,
      ),
    ];

    const budget = 500.0;
    const spent = 140.5;
    final remaining = budget - spent;
    final progress = spent / budget;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F6F3),
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Food & Drinks',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Transfers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag_outlined),
            label: 'Goals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFD9F0C8),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Text('🍔', style: TextStyle(fontSize: 36)),
                  const SizedBox(height: 10),
                  const Text(
                    'May 2026',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '\$140.5',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'of \$500 budget',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 18),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: Colors.white70,
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFF10B981),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '\$${remaining.toStringAsFixed(2)} remaining',
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _StatCard(title: 'Budget', value: '\$500'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(title: 'Spent', value: '\$140.5'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    title: 'Left',
                    value: '\$360',
                    valueColor: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Related Transactions',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),

            const SizedBox(height: 12),

            ...transactions.map(
              (transaction) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: BudgetTransactionCard(transaction: transaction),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFFB2C36),
                ),
                label: const Text(
                  'Delete Budget',
                  style: TextStyle(
                    color: Color(0xFFFB2C36),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFFC9C9)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;

  const _StatCard({required this.title, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class BudgetTransactionCard extends StatelessWidget {
  final BudgetTransaction transaction;

  const BudgetTransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text('🍔', style: TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.date,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '-\$${transaction.amount}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class BudgetTransaction {
  final String title;
  final String date;
  final double amount;

  BudgetTransaction({
    required this.title,
    required this.date,
    required this.amount,
  });
}
