import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qash/core/theme/qash_theme_extension.dart';
import 'package:qash/core/utils/currency_formatter.dart';

import '../../dashboard/providers/home_preferences_provider.dart';
import '../domain/entities/budget_status.dart';
import '../providers/budgets_providers.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetStatusesProvider);
    final period = ref.watch(budgetPeriodProvider);
    final displayCurrency = ref.watch(displayCurrencyProvider);
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
              boxShadow: [
                BoxShadow(
                  color: qash.cardShadow,
                  blurRadius: 6,
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: qash.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          'Budget',
          style: TextStyle(
            color: qash.textPrimary,
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
                  displayCurrency: displayCurrency,
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
                      child: BudgetCard(
                        budget: budget,
                        displayCurrency: displayCurrency,
                        onEdit: () => context.push(
                          '/budgets/${budget.budgetId}/edit',
                          extra: budget,
                        ),
                        onDelete: () => _confirmDelete(context, ref, budget),
                      ),
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

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    BudgetStatusEntity budget,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete budget?'),
        content: Text(
          'Remove the ${budget.categoryName} budget for this month?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFFB2C36)),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final result = await ref.read(deleteBudgetUseCaseProvider)(budget.budgetId);
    if (!context.mounted) {
      return;
    }

    if (result.isSuccess) {
      ref.invalidate(budgetStatusesProvider);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.message.isNotEmpty
              ? result.message
              : 'Failed to delete budget.',
        ),
      ),
    );
  }
}

class BudgetSummaryCard extends StatelessWidget {
  final BudgetPeriod period;
  final double totalBudget;
  final double totalSpent;
  final String displayCurrency;

  const BudgetSummaryCard({
    super.key,
    required this.period,
    required this.totalBudget,
    required this.totalSpent,
    required this.displayCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final qash = context.qash;
    final progress = totalBudget > 0
        ? (totalSpent / totalBudget).clamp(0, 1).toDouble()
        : 0.0;
    final percentage = (progress * 100).toInt();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: qash.primaryButton,
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
                    style: TextStyle(color: qash.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatCurrency(totalSpent, displayCurrency),
                    style: TextStyle(
                      color: qash.onPrimaryButton,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'of ${_formatCurrency(totalBudget, displayCurrency)} budgeted',
                    style: TextStyle(color: qash.textSecondary, fontSize: 12),
                  ),
                ],
              ),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: qash.accent, width: 3),
                ),
                child: Center(
                  child: Text(
                    '$percentage%',
                    style: TextStyle(
                      color: qash.onPrimaryButton,
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
              backgroundColor: qash.onPrimaryButton.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation(qash.accent),
            ),
          ),
        ],
      ),
    );
  }
}

class BudgetCard extends StatelessWidget {
  final BudgetStatusEntity budget;
  final String displayCurrency;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BudgetCard({
    super.key,
    required this.budget,
    required this.displayCurrency,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final qash = context.qash;
    final progress = budget.progress;
    final isOverBudget = budget.isOverBudget;
    final indicatorColor = isOverBudget ? qash.danger : const Color(0xFF10B981);
    final iconBg = isOverBudget
        ? qash.danger.withValues(alpha: 0.12)
        : qash.accent.withValues(alpha: 0.2);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: qash.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: qash.cardShadow, blurRadius: 8),
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
                    style: TextStyle(color: qash.textPrimary, fontSize: 20),
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
                      style: TextStyle(
                        color: qash.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isOverBudget
                          ? 'Over by ${_formatCurrency(budget.spentAmount - budget.budgetAmount, displayCurrency)}'
                          : '${_formatCurrency(budget.remainingAmount, displayCurrency)} left',
                      style: TextStyle(
                        color: isOverBudget ? qash.danger : qash.textSecondary,
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
                    _formatCurrency(budget.spentAmount, displayCurrency),
                    style: TextStyle(
                      color: qash.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'of ${_formatCurrency(budget.budgetAmount, displayCurrency)}',
                    style: TextStyle(color: qash.textSecondary, fontSize: 12),
                  ),
                ],
              ),
              if (onEdit != null || onDelete != null) ...[
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: qash.iconMuted),
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit?.call();
                    } else if (value == 'delete') {
                      onDelete?.call();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Delete',
                        style: TextStyle(color: qash.danger),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: qash.border,
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

String _formatCurrency(double value, String currencyCode) {
  return CurrencyFormatter.format(value, currencyCode);
}
