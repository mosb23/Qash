import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/currency/currency_format.dart';
import '../../../core/currency/currency_conversion_service.dart';
import '../../../core/currency/currency_providers.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/utils/result.dart';
import '../../../core/widgets/transaction_category_icon.dart';
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
    final budgets = ref.watch(adjustedBudgetStatusesProvider);
    final conversion = ref.watch(currencyConversionServiceProvider);

    final liveBudget = budgets.maybeWhen(
      data: (items) {
        for (final item in items) {
          if (item.budgetId == budget.budgetId) {
            return item;
          }
        }
        return budget;
      },
      orElse: () => budget,
    );

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
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/budgets');
                }
              },
            ),
          ),
        ),
        title: Text(
          liveBudget.categoryName,
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
            _summaryCard(liveBudget),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _miniStat(
                    label: 'Budget',
                    value: formatMoney(liveBudget.budgetAmount, liveBudget.currency),
                    valueColor: const Color(0xFF111111),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _miniStat(
                    label: 'Spent',
                    value: formatMoney(liveBudget.spentAmount, liveBudget.currency),
                    valueColor: const Color(0xFF111111),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _miniStat(
                    label: 'Left',
                    value: formatMoney(
                      liveBudget.remainingAmount.abs(),
                      liveBudget.currency,
                    ),
                    valueColor: liveBudget.remainingAmount >= 0
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
              data: (result) => _transactionsList(result, liveBudget, conversion),
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
                onPressed: () => _deleteBudget(context, ref, liveBudget),
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
            formatMoney(budget.spentAmount, budget.currency),
            style: const TextStyle(
              color: Color(0xFF111111),
              fontSize: 32,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'of ${formatMoney(budget.budgetAmount, budget.currency)} budget',
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
                ? '${formatMoney(remaining, budget.currency)} remaining'
                : '${formatMoney(remaining.abs(), budget.currency)} over budget',
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
    CurrencyConversionService conversion,
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
          _transactionCard(item, budget, conversion),
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
      if (!item.isExpense) {
        return false;
      }
      if (item.categoryId != budget.categoryId) {
        return false;
      }
      return item.transactionDate.year == budget.year &&
          item.transactionDate.month == budget.month;
    }).toList()..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    return filtered;
  }

  Widget _transactionCard(
    TransactionEntity item,
    BudgetStatusEntity budget,
    CurrencyConversionService conversion,
  ) {
    final amountSign = '-';
    const amountColor = Color(0xFFFF0000);
    final walletCurrency = item.walletCurrency.isNotEmpty
        ? item.walletCurrency
        : budget.currency;
    final amountInBudgetCurrency = conversion.convert(
      amount: item.amount,
      fromCurrency: walletCurrency,
      toCurrency: budget.currency,
    );

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
              TransactionCategoryIcon(
                categoryName: item.categoryName,
                categoryIcon: item.categoryName,
                isTransfer: item.isTransfer,
                backgroundColor: const Color(0xFFFFF1E6),
                size: 46,
                iconSize: 24,
                borderRadius: 16,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (item.description?.isNotEmpty == true)
                        ? item.description!
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
            walletCurrency.toUpperCase() == budget.currency.toUpperCase()
                ? '$amountSign${formatMoney(item.amount, walletCurrency)}'
                : '$amountSign${formatMoney(amountInBudgetCurrency, budget.currency)} (${formatMoney(item.amount, walletCurrency)})',
            style: const TextStyle(
              color: amountColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
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
