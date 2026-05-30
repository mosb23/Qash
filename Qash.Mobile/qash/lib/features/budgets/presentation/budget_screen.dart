import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/currency/currency_format.dart';
import '../../../core/currency/currency_providers.dart';
import '../../goals/utils/saving_goal_currency.dart';
import '../../transactions/providers/transactions_providers.dart';
import '../../wallets/providers/wallets_providers.dart';
import '../domain/entities/budget_status.dart';
import '../providers/budgets_providers.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(filteredBudgetStatusesProvider);
    final filteredBudgets = ref.watch(filteredBudgetStatusesProvider);
    final filter = ref.watch(budgetsFilterProvider);
    final hasExpiredBudgets = ref.watch(hasExpiredBudgetsProvider);
    final period = ref.watch(budgetPeriodProvider);
    final conversion = ref.watch(currencyConversionServiceProvider);

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
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
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
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(budgetStatusesProvider);
                ref.invalidate(transactionsProvider);
                ref.invalidate(walletsProvider);
                await ref.read(budgetStatusesProvider.future);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: budgets.when(
                  data: (allItems) {
                    final totalBudget = allItems.fold<double>(
                      0,
                      (sum, item) =>
                          sum +
                          conversion.convertToBase(
                            item.budgetAmount,
                            item.currency,
                          ),
                    );
                    final totalSpent = allItems.fold<double>(
                      0,
                      (sum, item) =>
                          sum +
                          conversion.convertToBase(
                            item.spentAmount,
                            item.currency,
                          ),
                    );
                    final overBudgetCount = allItems
                        .where((item) => item.isAtOrOverLimit)
                        .length;

                    return Column(
                      children: [
                        BudgetSummaryCard(
                          period: period,
                          totalBudget: totalBudget,
                          totalSpent: totalSpent,
                          currency: goalBaseCurrency,
                        ),
                        const SizedBox(height: 20),
                        if (overBudgetCount > 0) ...[
                          _OverBudgetAlert(count: overBudgetCount),
                          const SizedBox(height: 20),
                        ],
                        if (hasExpiredBudgets) ...[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _filterTab(
                                    label: 'All',
                                    isActive: filter == BudgetFilter.all,
                                    onTap: () =>
                                        _updateFilter(ref, BudgetFilter.all),
                                  ),
                                  const SizedBox(width: 8),
                                  _filterTab(
                                    label: 'Current',
                                    isActive: filter == BudgetFilter.current,
                                    onTap: () => _updateFilter(
                                      ref,
                                      BudgetFilter.current,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _filterTab(
                                    label: 'Limit reached',
                                    isActive: filter == BudgetFilter.expired,
                                    onTap: () => _updateFilter(
                                      ref,
                                      BudgetFilter.expired,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        filteredBudgets.when(
                          data: (items) {
                            if (items.isEmpty) {
                              return Text(
                                _emptyMessage(filter, hasExpiredBudgets),
                                style: const TextStyle(
                                  color: Color(0xFF8B8B8B),
                                  fontSize: 12,
                                ),
                              );
                            }

                            return Column(
                              children: [
                                for (final budget in items)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: GestureDetector(
                                      onTap: () => context.push(
                                        '/budgets/${budget.budgetId}',
                                        extra: budget,
                                      ),
                                      child: BudgetCard(budget: budget),
                                    ),
                                  ),
                              ],
                            );
                          },
                          loading: () => const SizedBox(
                            height: 120,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (error, stack) => const Text(
                            'Failed to load budgets.',
                            style: TextStyle(
                              color: Color(0xFF8B8B8B),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const SizedBox(
                    height: 240,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stack) => const Text(
                    'Failed to load budgets.',
                    style: TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: _addBudgetButton(context),
          ),
        ],
      ),
    );
  }

  void _updateFilter(WidgetRef ref, BudgetFilter filter) {
    ref.read(budgetsFilterProvider.notifier).state = filter;
  }

  String _emptyMessage(BudgetFilter filter, bool hasExpiredBudgets) {
    if (!hasExpiredBudgets) {
      return 'No budgets for this month.';
    }

    return switch (filter) {
      BudgetFilter.current => 'No current budgets.',
      BudgetFilter.expired => 'No limit reached budgets.',
      BudgetFilter.all => 'No budgets for this month.',
    };
  }

  Widget _filterTab({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF111111) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isActive
              ? null
              : const [
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
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF8B8B8B),
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _addBudgetButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/budgets/create'),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFF4D93A),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, color: Color(0xFF111111), size: 22),
              SizedBox(width: 8),
              Text(
                'Add Budget Category',
                style: TextStyle(
                  color: Color(0xFF111111),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
  final String currency;

  const BudgetSummaryCard({
    super.key,
    required this.period,
    required this.totalBudget,
    required this.totalSpent,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalBudget > 0
        ? (totalSpent / totalBudget).clamp(0, 1).toDouble()
        : 0.0;
    final percentage = (progress * 100).toInt();
    final isAtOrOverLimit = totalBudget > 0 && totalSpent >= totalBudget;
    final progressColor = isAtOrOverLimit
        ? const Color(0xFFEF4444)
        : const Color(0xFFF4D93A);
    final ringColor = isAtOrOverLimit
        ? const Color(0xFFEF4444)
        : const Color(0xFFF4D93A);

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
                    formatMoney(totalSpent, currency),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'of ${formatMoney(totalBudget, currency)} budgeted',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: ringColor, width: 3),
                ),
                child: Center(
                  child: Text(
                    '$percentage%',
                    style: TextStyle(
                      color: isAtOrOverLimit
                          ? const Color(0xFFEF4444)
                          : Colors.white,
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
              valueColor: AlwaysStoppedAnimation(progressColor),
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
    final isAtOrOverLimit = budget.isAtOrOverLimit;
    final indicatorColor = isAtOrOverLimit
        ? const Color(0xFFEF4444)
        : const Color(0xFF10B981);
    final iconBg = isAtOrOverLimit
        ? const Color(0xFFFEE2E2)
        : const Color(0xFFEFF6FF);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isAtOrOverLimit
            ? Border.all(color: const Color(0xFFFECACA), width: 1.4)
            : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    style: TextStyle(
                      color: isAtOrOverLimit
                          ? const Color(0xFFEF4444)
                          : Colors.black,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            budget.categoryName,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isAtOrOverLimit) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Limit reached',
                              style: TextStyle(
                                color: Color(0xFFEF4444),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAtOrOverLimit
                          ? budget.isOverBudget
                                ? 'Over by ${formatMoney(budget.spentAmount - budget.budgetAmount, budget.currency)}'
                                : 'Budget limit reached'
                          : '${formatMoney(budget.remainingAmount, budget.currency)} left',
                      style: TextStyle(
                        color: isAtOrOverLimit
                            ? const Color(0xFFEF4444)
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
                    formatMoney(budget.spentAmount, budget.currency),
                    style: TextStyle(
                      color: isAtOrOverLimit
                          ? const Color(0xFFEF4444)
                          : Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'of ${formatMoney(budget.budgetAmount, budget.currency)}',
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
                  color: isAtOrOverLimit
                      ? const Color(0xFFEF4444)
                      : Colors.grey,
                  fontSize: 12,
                  fontWeight: isAtOrOverLimit
                      ? FontWeight.w600
                      : FontWeight.normal,
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
        ? 'One category reached its budget limit'
        : '$count categories reached their budget limit';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4E6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEF4444), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFEF4444),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_amber_rounded, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Budget limit reached',
                  style: TextStyle(
                    color: Color(0xFFB91C1C),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFF7F1D1D),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
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

