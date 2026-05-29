import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/utils/result.dart';
import '../../transactions/domain/entities/transaction.dart';
import '../../transactions/providers/transactions_providers.dart';
import '../domain/entities/budget_status.dart';
import '../providers/budgets_providers.dart';

class BudgetDetailScreen extends ConsumerWidget {
  final BudgetStatusEntity budget;

  const BudgetDetailScreen({super.key, required this.budget});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);

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
        title: Text(
          budget.categoryName,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _summaryCard(budget),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _miniStat(
                    label: 'Budget',
                    value: _formatCurrency(budget.budgetAmount),
                    valueColor: const Color(0xFF111111),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _miniStat(
                    label: 'Spent',
                    value: _formatCurrency(budget.spentAmount),
                    valueColor: const Color(0xFF111111),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _miniStat(
                    label: 'Left',
                    value: _formatCurrency(budget.remainingAmount.abs()),
                    valueColor: budget.remainingAmount >= 0
                        ? const Color(0xFF10B981)
                        : const Color(0xFFFB2C36),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Related Transactions',
              style: TextStyle(
                color: Color(0xFF111111),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            transactions.when(
              data: (result) => _transactionsList(result, budget),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  error is AppFailure
                      ? error.message
                      : 'Failed to load transactions.',
                  style: const TextStyle(
                    color: Color(0xFF8B8B8B),
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () => _deleteBudget(context, ref, budget),
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
                  side: const BorderSide(color: Color(0xFFFECACA)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(BudgetStatusEntity budget) {
    final progress = budget.progress;
    final remaining = budget.remainingAmount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFDDF4C9),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.55),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                budget.categoryName.isNotEmpty
                    ? budget.categoryName.substring(0, 1).toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _periodLabel(budget),
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _formatCurrency(budget.spentAmount),
            style: const TextStyle(
              color: Color(0xFF111111),
              fontSize: 32,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'of ${_formatCurrency(budget.budgetAmount)} budget',
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white70,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF10B981)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            remaining >= 0
                ? '${_formatCurrency(remaining)} remaining'
                : '${_formatCurrency(remaining.abs())} over budget',
            style: TextStyle(
              color: remaining >= 0
                  ? const Color(0xFF10B981)
                  : const Color(0xFFFB2C36),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8B8B8B),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionsList(
    Result<List<TransactionEntity>> result,
    BudgetStatusEntity budget,
  ) {
    if (result.isFailure) {
      return Text(
        result.message,
        style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
      );
    }

    final items = _budgetTransactions(result.data ?? const [], budget);
    if (items.isEmpty) {
      return const Text(
        'No transactions yet.',
        style: TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
      );
    }

    return Column(
      children: [
        for (final item in items) ...[
          _transactionCard(item),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  List<TransactionEntity> _budgetTransactions(
    List<TransactionEntity> items,
    BudgetStatusEntity budget,
  ) {
    final filtered = items.where((item) {
      if (item.categoryId != budget.categoryId) {
        return false;
      }
      return item.transactionDate.year == budget.year &&
          item.transactionDate.month == budget.month;
    }).toList()..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    return filtered;
  }

  Widget _transactionCard(TransactionEntity item) {
    final amountSign = item.isIncome ? '+' : '-';
    final amountColor = item.isIncome
        ? const Color(0xFF10B981)
        : const Color(0xFFFB2C36);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1E6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    item.categoryName.isNotEmpty
                        ? item.categoryName.substring(0, 1).toUpperCase()
                        : '?',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.description.isNotEmpty
                        ? item.description
                        : item.categoryName,
                    style: const TextStyle(
                      color: Color(0xFF111111),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(item.transactionDate),
                    style: const TextStyle(
                      color: Color(0xFF8B8B8B),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            '$amountSign${_formatCurrency(item.amount)}',
            style: TextStyle(
              color: amountColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _periodLabel(BudgetStatusEntity budget) {
    final date = DateTime(budget.year, budget.month);
    return DateFormat('MMMM yyyy').format(date);
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(symbol: '\$').format(value);
  }

  String _formatDate(DateTime value) {
    return DateFormat('yyyy-MM-dd').format(value);
  }

  Future<void> _deleteBudget(
    BuildContext context,
    WidgetRef ref,
    BudgetStatusEntity budget,
  ) async {
    final result = await ref.read(deleteBudgetUseCaseProvider)(budget.budgetId);
    if (!context.mounted) {
      return;
    }

    if (result.isSuccess) {
      ref.invalidate(budgetStatusesProvider);
      context.go('/budgets');
      return;
    }

    final message = result.message.isNotEmpty
        ? result.message
        : 'Failed to delete budget.';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
