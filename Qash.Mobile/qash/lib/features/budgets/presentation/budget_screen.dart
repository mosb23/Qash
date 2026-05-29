import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/entities/budget_status.dart';
import '../providers/budgets_providers.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetStatusesProvider);
    final period = ref.watch(budgetPeriodProvider);

    return Scaffold(
      appBar: AppBar(
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
          'Budget',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: const Color(0xFFF4D93A),
              child: IconButton(
                onPressed: () => context.push('/budgets/create'),
                icon: const Icon(Icons.add, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: budgets.when(
          data: (result) {
            if (result.isFailure) {
              return Text(
                result.message,
                style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
              );
            }
            final items = result.data ?? const <BudgetStatusEntity>[];
            final totalBudget = items.fold<double>(
              0,
              (sum, item) => sum + item.budgetAmount,
            );
            final totalSpent = items.fold<double>(
              0,
              (sum, item) => sum + item.spentAmount,
            );
            final overBudgetCount = items
                .where((item) => item.isOverBudget)
                .length;

            return Column(
              children: [
                BudgetSummaryCard(
                  period: period,
                  totalBudget: totalBudget,
                  totalSpent: totalSpent,
                ),
                const SizedBox(height: 20),
                if (overBudgetCount > 0) ...[
                  _OverBudgetAlert(count: overBudgetCount),
                  const SizedBox(height: 20),
                ],
                if (items.isEmpty)
                  const Text(
                    'No budgets for this month.',
                    style: TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
                  )
                else
                  ...items.map(
                    (budget) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: BudgetCard(budget: budget),
                    ),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/budgets/create'),
                    icon: const Icon(Icons.add, color: Colors.grey),
                    label: const Text(
                      'Add Budget Category',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text(
            'Failed to load budgets.',
            style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
          ),
        ),
      ),
    );
  }
}

class BudgetSummaryCard extends StatelessWidget {
  final BudgetPeriod period;
  final double totalBudget;
  final double totalSpent;

  const BudgetSummaryCard({
    super.key,
    required this.period,
    required this.totalBudget,
    required this.totalSpent,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalBudget > 0
        ? (totalSpent / totalBudget).clamp(0, 1).toDouble()
        : 0.0;
    final percentage = (progress * 100).toInt();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _periodLabel(period),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatCurrency(totalSpent),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'of ${_formatCurrency(totalBudget)} budgeted',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFF4D93A), width: 3),
                ),
                child: Center(
                  child: Text(
                    '$percentage%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Color(0xFFF4D93A)),
            ),
          ),
        ],
      ),
    );
  }
}

class BudgetCard extends StatelessWidget {
  final BudgetStatusEntity budget;

  const BudgetCard({super.key, required this.budget});

  @override
  Widget build(BuildContext context) {
    final progress = budget.progress;
    final isOverBudget = budget.isOverBudget;
    final indicatorColor = isOverBudget
        ? const Color(0xFFFB2C36)
        : const Color(0xFF10B981);
    final iconBg = isOverBudget
        ? const Color(0xFFFEF2F2)
        : const Color(0xFFEFF6FF);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    budget.categoryName.isNotEmpty
                        ? budget.categoryName.substring(0, 1).toUpperCase()
                        : '?',
                    style: const TextStyle(color: Colors.black, fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      budget.categoryName,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isOverBudget
                          ? 'Over by ${_formatCurrency(budget.spentAmount - budget.budgetAmount)}'
                          : '${_formatCurrency(budget.remainingAmount)} left',
                      style: TextStyle(
                        color: isOverBudget
                            ? const Color(0xFFFB2C36)
                            : Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatCurrency(budget.spentAmount),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'of ${_formatCurrency(budget.budgetAmount)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: AlwaysStoppedAnimation(indicatorColor),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '0%',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: isOverBudget ? const Color(0xFFFB2C36) : Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverBudgetAlert extends StatelessWidget {
  final int count;

  const _OverBudgetAlert({required this.count});

  @override
  Widget build(BuildContext context) {
    final message = count == 1
        ? 'One category exceeded this month'
        : '$count categories exceeded this month';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFFB2C36)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Over budget alert',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _periodLabel(BudgetPeriod period) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final safeMonth = period.month >= 1 && period.month <= 12
      ? period.month
      : DateTime.now().month;
  final monthName = months[safeMonth - 1];
  return '$monthName ${period.year} Budget';
}

String _formatCurrency(double value) {
  return '\$${value.toStringAsFixed(2)}';
}
