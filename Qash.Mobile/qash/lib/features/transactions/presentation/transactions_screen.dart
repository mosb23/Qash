import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/bottom_nav_bar.dart';
import '../../../core/errors/app_failure.dart';
import '../domain/entities/transaction.dart';
import '../providers/transactions_providers.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(transactionsSummaryProvider);
    final filter = ref.watch(transactionsFilterProvider);
    final transactions = ref.watch(filteredTransactionsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F3),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(transactionsProvider);
                  await ref.read(transactionsProvider.future);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Transactions',
                              style: TextStyle(
                                color: Color(0xFF111111),
                                fontSize: 24,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Row(
                              children: [
                                _iconButton(Icons.search),
                                const SizedBox(width: 8),
                                _iconButton(Icons.tune),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _summaryRow(summary),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _filterTab(
                                label: 'All',
                                isActive: filter == TransactionFilter.all,
                                onTap: () =>
                                    _updateFilter(ref, TransactionFilter.all),
                              ),
                              const SizedBox(width: 8),
                              _filterTab(
                                label: 'Income',
                                isActive: filter == TransactionFilter.income,
                                onTap: () => _updateFilter(
                                  ref,
                                  TransactionFilter.income,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _filterTab(
                                label: 'Expense',
                                isActive: filter == TransactionFilter.expense,
                                onTap: () => _updateFilter(
                                  ref,
                                  TransactionFilter.expense,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _filterTab(
                                label: 'Transfer',
                                isActive: filter == TransactionFilter.transfer,
                                onTap: () => _updateFilter(
                                  ref,
                                  TransactionFilter.transfer,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4D93A),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Text(
                              '+ Add Transaction',
                              style: TextStyle(
                                color: Color(0xFF111111),
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        transactions.when(
                          data: (items) => _transactionsList(items),
                          loading: () => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (error, stack) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              error is AppFailure
                                  ? error.message
                                  : 'Failed to load transactions.',
                              style: const TextStyle(
                                color: Color(0xFF8B8B8B),
                                fontSize: 12,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            AppBottomNavBar(
              currentTab: AppTab.transactions,
              onSelected: (tab) => _onTabSelected(context, tab),
            ),
          ],
        ),
      ),
    );
  }

  void _updateFilter(WidgetRef ref, TransactionFilter filter) {
    ref.read(transactionsFilterProvider.notifier).state = filter;
  }

  void _onTabSelected(BuildContext context, AppTab tab) {
    switch (tab) {
      case AppTab.home:
        context.go('/home');
      case AppTab.transactions:
        return;
      case AppTab.analytics:
      case AppTab.goals:
      case AppTab.profile:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Coming soon.')));
    }
  }

  Widget _summaryRow(AsyncValue<TransactionsSummary> summary) {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            label: 'Income',
            color: const Color(0xFFD9F0C8),
            summary: summary,
            selector: (value) => value.incomeTotal,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _summaryCard(
            label: 'Expenses',
            color: const Color(0xFFFFE3E3),
            summary: summary,
            selector: (value) => value.expenseTotal,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String label,
    required Color color,
    required AsyncValue<TransactionsSummary> summary,
    required double Function(TransactionsSummary summary) selector,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0x99111111), fontSize: 12),
          ),
          const SizedBox(height: 4),
          summary.when(
            data: (value) => Text(
              _formatCurrency(selector(value)),
              style: const TextStyle(color: Color(0xFF111111), fontSize: 14),
            ),
            loading: () => const Text(
              '--',
              style: TextStyle(color: Color(0xFF111111), fontSize: 14),
            ),
            error: (_, __) => const Text(
              '--',
              style: TextStyle(color: Color(0xFF111111), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionsList(List<TransactionEntity> items) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'No transactions yet.',
          style: TextStyle(
            color: Color(0xFF8B8B8B),
            fontSize: 12,
            fontFamily: 'Inter',
          ),
        ),
      );
    }

    final sorted = [...items]
      ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    final grouped = <String, List<TransactionEntity>>{};
    for (final item in sorted) {
      final label = _formatSectionLabel(item.transactionDate);
      grouped.putIfAbsent(label, () => []).add(item);
    }

    final sections = grouped.entries.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in sections) ...[
          _sectionLabel(entry.key),
          const SizedBox(height: 8),
          for (final item in entry.value) ...[
            _transactionItem(item),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  String _formatSectionLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final difference = today.difference(target).inDays;

    if (difference == 0) {
      return 'Today';
    }
    if (difference == 1) {
      return 'Yesterday';
    }

    return DateFormat('MMM d').format(date);
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(symbol: '\$').format(value);
  }

  Widget _iconButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
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
      child: Icon(icon, size: 20, color: const Color(0xFF111111)),
    );
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
              : [
                  const BoxShadow(
                    color: Color(0x19000000),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                    spreadRadius: -1,
                  ),
                  const BoxShadow(
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

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF8B8B8B),
        fontSize: 12,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _transactionItem(TransactionEntity item) {
    final isTransfer = item.isTransfer;
    final amountColor = isTransfer
        ? const Color(0xFF2B7FFF)
        : item.isIncome
        ? const Color(0xFF00A63E)
        : const Color(0xFFFF0000);
    final amountSign = isTransfer
        ? ''
        : item.isIncome
        ? '+'
        : '-';
    final iconBg = isTransfer
        ? const Color(0xFFE1EBFF)
        : item.isIncome
        ? const Color(0xFFD9F0C8)
        : const Color(0xFFFFD3D4);
    final iconText = item.categoryName.isNotEmpty
        ? item.categoryName.substring(0, 1).toUpperCase()
        : '?';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(iconText, style: const TextStyle(fontSize: 16)),
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
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${item.categoryName} · ${item.walletName}',
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
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
