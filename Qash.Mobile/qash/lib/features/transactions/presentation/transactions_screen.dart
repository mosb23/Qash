import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qash/core/theme/qash_theme_extension.dart';
import 'package:qash/core/utils/currency_formatter.dart';

import '../../../core/widgets/bottom_nav_bar.dart';
import '../../dashboard/providers/home_preferences_provider.dart';
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
    final qash = context.qash;
    final summary = ref.watch(transactionsSummaryProvider);
    final filter = ref.watch(transactionsFilterProvider);
    final searchQuery = ref.watch(transactionsSearchQueryProvider);
    final transactions = ref.watch(filteredTransactionsProvider);
    final categories = ref.watch(categoriesProvider);
    final displayCurrency = ref.watch(displayCurrencyProvider);

    return Scaffold(
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
                            Text(
                              'Transactions',
                              style: TextStyle(
                                color: qash.textPrimary,
                                fontSize: 24,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Row(
                              children: [
                                _iconButton(
                                  context,
                                  Icons.search,
                                  onTap: () => _openSearch(context, ref, searchQuery),
                                ),
                                const SizedBox(width: 8),
                                _iconButton(
                                  context,
                                  Icons.tune,
                                  onTap: () => _openFilters(context, ref),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (searchQuery.trim().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Search: "${searchQuery.trim()}"',
                                  style: TextStyle(
                                    color: qash.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => ref
                                    .read(transactionsSearchQueryProvider.notifier)
                                    .state = '',
                                child: Text(
                                  'Clear',
                                  style: TextStyle(
                                    color: qash.textPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 16),
                        _summaryRow(context, summary, displayCurrency),
                        const SizedBox(height: 8),
                        Text(
                          'Totals in $displayCurrency (no currency conversion).',
                          style: TextStyle(
                            color: qash.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _filterTab(
                                context,
                                label: 'All',
                                isActive: filter == TransactionFilter.all,
                                onTap: () =>
                                    _updateFilter(ref, TransactionFilter.all),
                              ),
                              const SizedBox(width: 8),
                              _filterTab(
                                context,
                                label: 'Income',
                                isActive: filter == TransactionFilter.income,
                                onTap: () => _updateFilter(
                                  ref,
                                  TransactionFilter.income,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _filterTab(
                                context,
                                label: 'Expense',
                                isActive: filter == TransactionFilter.expense,
                                onTap: () => _updateFilter(
                                  ref,
                                  TransactionFilter.expense,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _filterTab(
                                context,
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
                              color: qash.accent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                '+ Add Transaction',
                                style: TextStyle(
                                  color: qash.onAccent,
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
                          data: (items) =>
                              _transactionsList(
                                context,
                                items,
                                categories,
                                displayCurrency,
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
                              style: TextStyle(
                                color: qash.textSecondary,
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

  Future<void> _openSearch(
    BuildContext context,
    WidgetRef ref,
    String currentQuery,
  ) async {
    final controller = TextEditingController(text: currentQuery);
    final query = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search transactions'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Description, category, wallet, amount...',
            ),
            onSubmitted: (value) => Navigator.pop(context, value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, ''),
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Search'),
            ),
          ],
        );
      },
    );

    if (query != null) {
      ref.read(transactionsSearchQueryProvider.notifier).state = query;
    }
    controller.dispose();
  }

  Future<void> _openFilters(BuildContext context, WidgetRef ref) async {
    final walletsResult = await ref.read(walletsProvider.future);
    final wallets = walletsResult.data ?? const <WalletEntity>[];
    final selectedWalletId = ref.read(transactionsWalletFilterProvider);

    if (!context.mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter by wallet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text('All wallets'),
                  trailing: selectedWalletId == null
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () {
                    ref.read(transactionsWalletFilterProvider.notifier).state =
                        null;
                    Navigator.pop(context);
                  },
                ),
                for (final wallet in wallets)
                  ListTile(
                    title: Text(wallet.name),
                    trailing: selectedWalletId == wallet.walletId
                        ? const Icon(Icons.check)
                        : null,
                    onTap: () {
                      ref.read(transactionsWalletFilterProvider.notifier).state =
                          wallet.walletId;
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
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

  Widget _summaryRow(
    BuildContext context,
    AsyncValue<TransactionsSummary> summary,
    String displayCurrency,
  ) {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            context: context,
            label: 'Income',
            color: const Color(0xFFD9F0C8),
            summary: summary,
            displayCurrency: displayCurrency,
            selector: (value) => value.incomeTotal,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _summaryCard(
            context: context,
            label: 'Expenses',
            color: const Color(0xFFFFE3E3),
            summary: summary,
            displayCurrency: displayCurrency,
            selector: (value) => value.expenseTotal,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required BuildContext context,
    required String label,
    required Color color,
    required AsyncValue<TransactionsSummary> summary,
    required String displayCurrency,
    required double Function(TransactionsSummary summary) selector,
  }) {
    final qash = context.qash;
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
            style: TextStyle(
              color: qash.textPrimary.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          summary.when(
            data: (value) => Text(
              _formatCurrency(selector(value), displayCurrency),
              style: TextStyle(color: qash.textPrimary, fontSize: 14),
            ),
            loading: () => Text(
              '--',
              style: TextStyle(color: qash.textPrimary, fontSize: 14),
            ),
            error: (_, _) => Text(
              '--',
              style: TextStyle(color: qash.textPrimary, fontSize: 14),
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
    String displayCurrency,
  ) {
    final qash = context.qash;
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'No transactions yet.',
          style: TextStyle(
            color: qash.textSecondary,
            fontSize: 12,
            fontFamily: 'Inter',
          ),
        ),
      );
    }

    final categoryMap = _buildCategoryMap(categories);
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
          _sectionLabel(context, entry.key),
          const SizedBox(height: 8),
          for (final item in entry.value) ...[
            _transactionItem(context, item, categoryMap, displayCurrency),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 16),
        ],
      ],
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

  String _formatCurrency(double value, String currencyCode) {
    return CurrencyFormatter.format(value, currencyCode);
  }

  Widget _iconButton(
    BuildContext context,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    final qash = context.qash;
    return GestureDetector(
      onTap: onTap,
      child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: qash.surface,
        borderRadius: BorderRadius.circular(999),
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
      child: Icon(icon, size: 20, color: qash.textPrimary),
      ),
    );
  }

  Widget _filterTab(
    BuildContext context, {
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final qash = context.qash;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? qash.primaryButton : qash.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isActive
              ? null
              : [
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
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? qash.onPrimaryButton : qash.textSecondary,
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String label) {
    final qash = context.qash;
    return Text(
      label,
      style: TextStyle(
        color: qash.textSecondary,
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
    String displayCurrency,
  ) {
    final qash = context.qash;
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
    if (isTransfer && item.toWalletName.isNotEmpty) {
      subtitleParts.add('${item.walletName} → ${item.toWalletName}');
    } else if (item.walletName.isNotEmpty) {
      subtitleParts.add(item.walletName);
    }
    final subtitle = subtitleParts.join(' · ');

    return GestureDetector(
      onTap: () => context.push('/transactions/${item.id}'),
      child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
                    style: TextStyle(
                      color: qash.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: qash.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ],
          ),
          Text(
            '$amountSign${_formatCurrency(item.amount, displayCurrency)}',
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
