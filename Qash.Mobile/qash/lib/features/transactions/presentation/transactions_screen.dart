import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/bottom_nav_bar.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/utils/result.dart';
import '../../categories/domain/entities/category.dart';
import '../../categories/providers/categories_providers.dart';
import '../../wallets/domain/entities/wallet.dart';
import '../../wallets/providers/wallets_providers.dart';
import '../domain/entities/transaction.dart';
import '../providers/transactions_providers.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(transactionsSummaryProvider);
    final filter = ref.watch(transactionsFilterProvider);
    final listOptions = ref.watch(transactionListOptionsProvider);
    final transactions = ref.watch(filteredTransactionsProvider);
    final categories = ref.watch(categoriesProvider);

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
                            _filterButton(
                              context,
                              ref,
                              listOptions.hasActiveFilters,
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
                        GestureDetector(
                          onTap: () {
                            final type = _initialTypeFromFilter(filter);
                            context.push('/transactions/add?type=$type');
                          },
                          child: Container(
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
                        ),
                        const SizedBox(height: 24),
                        transactions.when(
                          data: (items) => _transactionsList(
                            context,
                            items,
                            categories,
                            listOptions.sort,
                            listOptions.walletId,
                          ),
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

  int _initialTypeFromFilter(TransactionFilter filter) {
    switch (filter) {
      case TransactionFilter.income:
        return 1;
      case TransactionFilter.expense:
        return 2;
      case TransactionFilter.transfer:
        return 3;
      case TransactionFilter.all:
        return 2;
    }
  }

  void _onTabSelected(BuildContext context, AppTab tab) {
    switch (tab) {
      case AppTab.home:
        context.go('/home');
        return;
      case AppTab.transactions:
        return;
      case AppTab.analytics:
        context.go('/analytics');
        return;
      case AppTab.goals:
        context.go('/goals');
        return;
      case AppTab.profile:
        context.go('/profile');
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

  Widget _transactionsList(
    BuildContext context,
    List<TransactionEntity> items,
    AsyncValue<Result<List<CategoryEntity>>> categories,
    TransactionListSort sort,
    String? walletId,
  ) {
    if (items.isEmpty) {
      final message = walletId != null && walletId.isNotEmpty
          ? 'No transactions for this wallet.'
          : 'No transactions yet.';
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          message,
          style: const TextStyle(
            color: Color(0xFF8B8B8B),
            fontSize: 12,
            fontFamily: 'Inter',
          ),
        ),
      );
    }

    final categoryMap = _buildCategoryMap(categories);
    final groupByDate = sort == TransactionListSort.dateNewest ||
        sort == TransactionListSort.dateOldest;

    if (!groupByDate) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in items) ...[
            _transactionItem(context, item, categoryMap),
            const SizedBox(height: 8),
          ],
        ],
      );
    }

    final grouped = <DateTime, List<TransactionEntity>>{};
    for (final item in items) {
      final day = transactionLocalDate(item.transactionDate);
      grouped.putIfAbsent(day, () => []).add(item);
    }

    final sectionDays = grouped.keys.toList()
      ..sort(
        (a, b) => sort == TransactionListSort.dateOldest
            ? a.compareTo(b)
            : b.compareTo(a),
      );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final day in sectionDays) ...[
          _sectionLabel(_formatSectionLabel(day)),
          const SizedBox(height: 8),
          for (final item in grouped[day]!) ...[
            _transactionItem(context, item, categoryMap),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    final current = ref.read(transactionListOptionsProvider);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        var selectedSort = current.sort;
        String? selectedWalletId = current.walletId;

        return Consumer(
          builder: (context, ref, _) {
            final walletsAsync = ref.watch(walletsProvider);

            return StatefulBuilder(
              builder: (context, setSheetState) {
                final wallets = walletsAsync.maybeWhen(
                  data: (result) => result.data ?? const <WalletEntity>[],
                  orElse: () => const <WalletEntity>[],
                );

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E5E5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Filter & Sort',
                      style: TextStyle(
                        color: Color(0xFF111111),
                        fontSize: 18,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Sort by',
                      style: TextStyle(
                        color: Color(0xFF8B8B8B),
                        fontSize: 12,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 8),
                    _sortOption(
                      label: 'Date (newest first)',
                      selected: selectedSort == TransactionListSort.dateNewest,
                      onTap: () => setSheetState(
                        () => selectedSort = TransactionListSort.dateNewest,
                      ),
                    ),
                    _sortOption(
                      label: 'Date (oldest first)',
                      selected: selectedSort == TransactionListSort.dateOldest,
                      onTap: () => setSheetState(
                        () => selectedSort = TransactionListSort.dateOldest,
                      ),
                    ),
                    _sortOption(
                      label: 'Amount (low to high)',
                      selected:
                          selectedSort == TransactionListSort.amountLowToHigh,
                      onTap: () => setSheetState(
                        () => selectedSort = TransactionListSort.amountLowToHigh,
                      ),
                    ),
                    _sortOption(
                      label: 'Amount (high to low)',
                      selected:
                          selectedSort == TransactionListSort.amountHighToLow,
                      onTap: () => setSheetState(
                        () => selectedSort = TransactionListSort.amountHighToLow,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Wallet',
                      style: TextStyle(
                        color: Color(0xFF8B8B8B),
                        fontSize: 12,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 8),
                    _walletOption(
                      label: 'All wallets',
                      selected: selectedWalletId == null,
                      onTap: () =>
                          setSheetState(() => selectedWalletId = null),
                    ),
                    if (walletsAsync.isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    else if (wallets.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'No wallets yet.',
                          style: TextStyle(
                            color: Color(0xFF8B8B8B),
                            fontSize: 12,
                            fontFamily: 'Inter',
                          ),
                        ),
                      )
                    else
                      ...wallets.map(
                        (wallet) => _walletOption(
                          label: wallet.name,
                          selected:
                              normalizeTransactionId(selectedWalletId) ==
                              normalizeTransactionId(wallet.walletId),
                          onTap: () => setSheetState(
                            () => selectedWalletId = wallet.walletId,
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              ref
                                  .read(transactionListOptionsProvider.notifier)
                                  .state = const TransactionListOptions();
                              Navigator.pop(sheetContext);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF111111),
                              side: const BorderSide(color: Color(0xFFE5E5E5)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              'Reset',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              ref
                                  .read(transactionListOptionsProvider.notifier)
                                  .state = TransactionListOptions(
                                sort: selectedSort,
                                walletId:
                                    selectedWalletId != null &&
                                        selectedWalletId!.isNotEmpty
                                    ? selectedWalletId
                                    : null,
                              );
                              Navigator.pop(sheetContext);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF4D93A),
                              foregroundColor: const Color(0xFF111111),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              'Apply',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ],
                  ),
                ),
              ),
            );
              },
            );
          },
        );
      },
    );
  }

  Widget _sortOption({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return _filterSheetOption(label: label, selected: selected, onTap: onTap);
  }

  Widget _walletOption({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return _filterSheetOption(label: label, selected: selected, onTap: onTap);
  }

  Widget _filterSheetOption({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 20,
              color: selected
                  ? const Color(0xFF111111)
                  : const Color(0xFF8B8B8B),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: selected
                      ? const Color(0xFF111111)
                      : const Color(0xFF8B8B8B),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, CategoryEntity> _buildCategoryMap(
    AsyncValue<Result<List<CategoryEntity>>> categories,
  ) {
    return categories.maybeWhen(
      data: (result) {
        final items = result.data ?? const [];
        return {for (final item in items) item.id: item};
      },
      orElse: () => const {},
    );
  }

  String _formatSectionLabel(DateTime day) {
    final today = transactionLocalDate(DateTime.now());
    final difference = today.difference(day).inDays;

    if (difference == 0) {
      return 'Today';
    }
    if (difference == 1) {
      return 'Yesterday';
    }

    return DateFormat('MMM d, yyyy').format(day);
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(symbol: '\$').format(value);
  }

  Widget _filterButton(
    BuildContext context,
    WidgetRef ref,
    bool hasActiveFilters,
  ) {
    return GestureDetector(
      onTap: () => _showFilterSheet(context, ref),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: hasActiveFilters
              ? const Color(0xFFF4D93A)
              : Colors.white,
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
        child: const Icon(
          Icons.tune,
          size: 20,
          color: Color(0xFF111111),
        ),
      ),
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

  Widget _transactionItem(
    BuildContext context,
    TransactionEntity item,
    Map<String, CategoryEntity> categoryMap,
  ) {
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
    final resolvedCategoryName = item.categoryName.isNotEmpty
        ? item.categoryName
        : (categoryMap[item.categoryId]?.name ?? '');
    final iconText = resolvedCategoryName.isNotEmpty
        ? resolvedCategoryName.substring(0, 1).toUpperCase()
        : '?';
    final title = item.description.isNotEmpty
        ? item.description
        : resolvedCategoryName;
    final subtitleParts = <String>[];
    if (resolvedCategoryName.isNotEmpty && resolvedCategoryName != title) {
      subtitleParts.add(resolvedCategoryName);
    }
    if (item.walletName.isNotEmpty) {
      subtitleParts.add(item.walletName);
    }
    final subtitle = subtitleParts.join(' · ');

    return GestureDetector(
      onTap: () => context.push('/transactions/${item.id}'),
      child: Container(
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
                      title,
                      style: const TextStyle(
                        color: Color(0xFF111111),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
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
      ),
    );
  }
}
