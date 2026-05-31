import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../config/providers.dart';
import '../../../core/currency/currency_aggregation.dart';
import '../../../core/currency/currency_conversion_service.dart';
import '../../../core/currency/currency_format.dart';
import '../../../core/currency/currency_providers.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/widgets/currency_flag.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../../../core/widgets/goal_logo.dart';
import '../../../core/widgets/transaction_category_icon.dart';
import '../../budgets/domain/entities/budget_status.dart';
import '../../budgets/providers/budgets_providers.dart';
import '../../goals/domain/entities/saving_goal.dart';
import '../../goals/providers/saving_goals_providers.dart';
import '../../goals/utils/saving_goal_currency.dart';
import '../../profile/domain/entities/profile.dart';
import '../../profile/providers/profile_providers.dart';
import '../../transactions/domain/entities/transaction.dart';
import '../../transactions/providers/transactions_providers.dart';
import '../../wallets/domain/entities/wallet.dart';
import '../../wallets/providers/wallets_providers.dart';
import '../../wallets/utils/wallet_balance_utils.dart';
import '../domain/entities/dashboard.dart';
import '../providers/dashboard_providers.dart';
import '../providers/dashboard_computed_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const String _hideBalancesStorageKey = 'home_hide_balances';
  static const String _firstWalletPromptStorageKey = 'home_first_wallet_prompt_seen';

  bool _hideBalances = false;
  bool _hideBalancesLoaded = false;
  bool _firstWalletPromptShown = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _restoreUiPreferences());
  }

  @override
  Widget build(BuildContext context) {
    final profile = _resolveResult<ProfileEntity>(ref.watch(profileProvider));
    final topCategories = ref.watch(clientTopCategoriesProvider);
    final wallets = _resolveResultList<WalletEntity>(
      ref.watch(walletsProvider),
    );
    final transactions = _resolveResultList<TransactionEntity>(
      ref.watch(transactionsProvider),
    );
    final conversion = ref.watch(currencyConversionServiceProvider);
    final activeCurrency = ref.watch(effectiveDisplayCurrencyProvider);
    final availableCurrencies = _dropdownCurrencies(wallets, activeCurrency);
    final currencyTotals = _monthlyTotals(
      transactions,
      wallets,
      activeCurrency,
      conversion,
    );
    final walletsTotal = _walletsTotal(wallets, transactions, activeCurrency, conversion);
    final budgets = ref.watch(adjustedBudgetStatusesProvider);
    final goals = _resolveResultList<SavingGoalEntity>(
      ref.watch(savingGoalsProvider),
    );
    final recents = _resolveRecentTransactions(ref.watch(transactionsProvider));
    final exchangeRates = conversion.rates;
    _maybeShowCreateWalletPrompt(wallets);

    if (!_hideBalancesLoaded) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7F6F3),
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F3),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(profileProvider);
                  ref.invalidate(dashboardProvider);
                  ref.invalidate(walletsProvider);
                  ref.invalidate(budgetStatusesProvider);
                  ref.invalidate(savingGoalsProvider);
                  ref.invalidate(transactionsProvider);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // -- Top Bar --
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                _profileAvatar(profile),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Welcome back,',
                                      style: TextStyle(
                                        color: Color(0xFF8B8B8B),
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      _profileName(profile),
                                      style: const TextStyle(
                                        color: Color(0xFF111111),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(width: 40),
                          ],
                        ),
                      ),
                      // -- Balance Card --
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111111),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total Balance',
                                    style: TextStyle(
                                      color: Color(0xFF8B8B8B),
                                      fontSize: 12,
                                    ),
                                  ),
                                  _currencyDropdown(
                                    availableCurrencies,
                                    activeCurrency,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  CurrencyFlag(
                                    currencyCode: activeCurrency,
                                    width: 28,
                                    height: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    _hideBalances
                                        ? '****'
                                        : formatMoney(
                                            walletsTotal,
                                            activeCurrency,
                                          ),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () {
                                      _toggleHideBalances();
                                    },
                                    icon: Icon(
                                      _hideBalances
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: const Color(0xFF8B8B8B),
                                      size: 20,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFD9F0C8),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.arrow_downward,
                                          size: 12,
                                          color: Color(0xFF10B981),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Income',
                                            style: TextStyle(
                                              color: Color(0xFF8B8B8B),
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            _hideBalances
                                                ? '****'
                                                : formatMoney(
                                                    currencyTotals.income,
                                                    activeCurrency,
                                                  ),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: const Color(0x4C82181A),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.arrow_upward,
                                          size: 12,
                                          color: Color(0xFFEF4444),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Expenses',
                                            style: TextStyle(
                                              color: Color(0xFF8B8B8B),
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            _hideBalances
                                                ? '****'
                                                : formatMoney(
                                                    currencyTotals.expenses,
                                                    activeCurrency,
                                                  ),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // -- Wallets --
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => context.push('/wallets'),
                              child: const Text(
                                'Wallets',
                                style: TextStyle(
                                  color: Color(0xFF111111),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.push('/wallets'),
                              child: const Text(
                                'See all >',
                                style: TextStyle(
                                  color: Color(0xFF8B8B8B),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _walletsSection(
                        context,
                        wallets,
                        transactions,
                        exchangeRates,
                        _hideBalances,
                      ),
                      const SizedBox(height: 24),
                      // -- Quick Actions --
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Quick Actions',
                              style: TextStyle(
                                color: Color(0xFF111111),
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _quickAction(
                                    'Income',
                                    'assets/icons/QuickActions/income.png',
                                    const Color(0xFFD9F0C8),
                                    onTap: () => context.push(
                                      '/transactions/add?type=1',
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: _quickAction(
                                    'Expense',
                                    'assets/icons/QuickActions/expense.png',
                                    const Color(0xFFFEE2E2),
                                    onTap: () => context.push(
                                      '/transactions/add?type=2',
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: _quickAction(
                                    'Transfer',
                                    'assets/icons/QuickActions/exchange.png',
                                    const Color.fromARGB(255, 214, 231, 252),
                                    onTap: () => context.push(
                                      '/transactions/add?type=3',
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: _quickAction(
                                    'Wallets',
                                    'assets/icons/QuickActions/wallet.png',
                                    const Color.fromARGB(255, 203, 205, 209),
                                    onTap: () => context.push('/wallets'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // -- Budget --
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () => context.push('/budgets'),
                                  child: const Text(
                                    'Budget',
                                    style: TextStyle(
                                      color: Color(0xFF111111),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => context.push('/budgets'),
                                  child: const Text(
                                    'See all >',
                                    style: TextStyle(
                                      color: Color(0xFF8B8B8B),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _budgetSection(budgets),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // -- Top Categories --
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Top Categories',
                              style: TextStyle(
                                color: Color(0xFF111111),
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _topCategoriesSection(topCategories, activeCurrency),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // -- Goals --
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () => context.push('/goals'),
                                  child: const Text(
                                    'Goals',
                                    style: TextStyle(
                                      color: Color(0xFF111111),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => context.push('/goals'),
                                  child: const Text(
                                    'See all >',
                                    style: TextStyle(
                                      color: Color(0xFF8B8B8B),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _goalsSection(goals),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // -- Recent Transactions --
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Recent Transactions',
                                  style: TextStyle(
                                    color: Color(0xFF111111),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => context.push('/transactions'),
                                  child: const Text(
                                    'See all >',
                                    style: TextStyle(
                                      color: Color(0xFF8B8B8B),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Recent transactions are converted to the selected display currency from Total Balance.',
                                style: TextStyle(
                                  color: Color(0xFF1D4ED8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _recentSection(
                              context,
                              recents,
                              wallets,
                              conversion,
                              activeCurrency,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            AppBottomNavBar(
              currentTab: AppTab.home,
              onSelected: (tab) => _onTabSelected(context, tab),
            ),
          ],
        ),
      ),
    );
  }

  AsyncValue<T> _resolveResult<T>(AsyncValue<dynamic> value) {
    return value.whenData((result) {
      if (result.isFailure) {
        throw result.failure ??
            const AppFailure(message: 'Failed to load data.');
      }
      return result.data as T;
    });
  }

  AsyncValue<List<T>> _resolveResultList<T>(AsyncValue<dynamic> value) {
    return value.whenData((result) {
      if (result.isFailure) {
        throw result.failure ??
            const AppFailure(message: 'Failed to load data.');
      }
      return (result.data as List<T>?) ?? const [];
    });
  }

  AsyncValue<List<TransactionEntity>> _resolveRecentTransactions(
    AsyncValue<dynamic> value,
  ) {
    return value.whenData((result) {
      if (result.isFailure) {
        throw result.failure ??
            const AppFailure(message: 'Failed to load transactions.');
      }
      final items = (result.data as List<TransactionEntity>?) ?? const [];
      final sorted = [...items]
        ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
      return sorted.take(5).toList();
    });
  }

  List<String> _dropdownCurrencies(
    AsyncValue<List<WalletEntity>> wallets,
    String activeCurrency,
  ) {
    final currencies = wallets.maybeWhen(
      data: collectWalletCurrencies,
      orElse: () => [kBaseCurrency],
    );
    if (!currencies.contains(activeCurrency)) {
      return [...currencies, activeCurrency]..sort();
    }
    return currencies;
  }

  double _walletsTotal(
    AsyncValue<List<WalletEntity>> wallets,
    AsyncValue<List<TransactionEntity>> transactions,
    String targetCurrency,
    CurrencyConversionService conversion,
  ) {
    return wallets.maybeWhen(
      data: (items) {
        final walletTransactions = transactions.maybeWhen(
          data: (txItems) => txItems,
          orElse: () => const <TransactionEntity>[],
        );
        return sumWalletBalancesInCurrency(
          wallets: items,
          transactions: walletTransactions,
          targetCurrency: targetCurrency,
          conversion: conversion,
        );
      },
      orElse: () => 0,
    );
  }

  MonthlyCurrencyTotals _monthlyTotals(
    AsyncValue<List<TransactionEntity>> transactions,
    AsyncValue<List<WalletEntity>> wallets,
    String targetCurrency,
    CurrencyConversionService conversion,
  ) {
    final walletsById = wallets.maybeWhen(
      data: (items) => walletsByIdMap(items),
      orElse: () => const <String, WalletEntity>{},
    );

    return transactions.maybeWhen(
      data: (items) => sumMonthlyIncomeExpenseInCurrency(
        transactions: items,
        targetCurrency: targetCurrency,
        conversion: conversion,
        walletsById: walletsById,
      ),
      orElse: () => const MonthlyCurrencyTotals(income: 0, expenses: 0),
    );
  }

  String _profileName(AsyncValue<ProfileEntity> profile) {
    return profile.maybeWhen(
      data: (value) => value.resolvedName,
      orElse: () => 'User',
    );
  }

  Widget _profileAvatar(AsyncValue<ProfileEntity> profile) {
    final alias = profile.maybeWhen(
      data: (value) => value.alias,
      orElse: () => 'UN',
    );

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF4D93A),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Center(
        child: Text(
          alias,
          style: const TextStyle(color: Colors.black, fontSize: 14),
        ),
      ),
    );
  }

  Widget _walletsSection(
    BuildContext context,
    AsyncValue<List<WalletEntity>> wallets,
    AsyncValue<List<TransactionEntity>> transactions,
    Map<String, double> exchangeRates,
    bool hideBalances,
  ) {
    return wallets.when(
      data: (items) {
        if (items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'No wallets yet.',
              style: TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
            ),
          );
        }

        final walletTransactions = transactions.maybeWhen(
          data: (txItems) => txItems,
          orElse: () => const <TransactionEntity>[],
        );
        final walletsById = walletsByIdMap(items);

        return SizedBox(
          height: 148,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 24),
            children: [
              for (final wallet in items) ...[
                GestureDetector(
                  onTap: () => context.push(
                    '/wallets/${wallet.walletId}',
                    extra: wallet,
                  ),
                  child: _walletCard(
                    wallet,
                    hideBalances,
                    displayWalletBalance(
                      wallet: wallet,
                      allTransactions: walletTransactions,
                      walletsById: walletsById,
                      exchangeRates: exchangeRates,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              _addWalletCard(context),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: SizedBox(
          height: 148,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          _errorText(error),
          style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
        ),
      ),
    );
  }

  Widget _budgetSection(AsyncValue<List<BudgetStatusEntity>> budgets) {
    return budgets.when(
      data: (items) {
        if (items.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'No budgets for this month.',
              style: TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
            ),
          );
        }

        final cards = items.take(2).toList();
        return Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => context.push(
                  '/budgets/${cards.first.budgetId}',
                  extra: cards.first,
                ),
                child: _budgetStatusCard(cards.first),
              ),
            ),
            if (cards.length > 1) ...[
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => context.push(
                    '/budgets/${cards.last.budgetId}',
                    extra: cards.last,
                  ),
                  child: _budgetStatusCard(cards.last),
                ),
              ),
            ],
          ],
        );
      },
      loading: () => const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Text(
        _errorText(error),
        style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
      ),
    );
  }

  Widget _topCategoriesSection(
    AsyncValue<List<TopCategoryEntity>> topCategories,
    String displayCurrency,
  ) {
    return topCategories.when(
      data: (categories) {
        if (categories.isEmpty) {
          return const Text(
            'No category spendings yet.',
            style: TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
          );
        }
        return Column(
          children: [
            for (final category in categories) ...[
              _topCategoryRow(category, displayCurrency),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
      loading: () => const SizedBox(
        height: 60,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Text(
        _errorText(error),
        style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
      ),
    );
  }

  Widget _goalsSection(AsyncValue<List<SavingGoalEntity>> goals) {
    return goals.when(
      data: (items) {
        if (items.isEmpty) {
          return const Text(
            'No goals yet.',
            style: TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
          );
        }
        final list = items.take(2).toList();
        return Column(
          children: [
            for (final goal in list) ...[
              GestureDetector(
                onTap: () =>
                    context.push('/goals/${goal.savingGoalId}', extra: goal),
                child: _goalCardFromData(goal),
              ),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
      loading: () => const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Text(
        _errorText(error),
        style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
      ),
    );
  }

  Widget _recentSection(
    BuildContext context,
    AsyncValue<List<TransactionEntity>> transactions,
    AsyncValue<List<WalletEntity>> wallets,
    CurrencyConversionService conversion,
    String displayCurrency,
  ) {
    final walletsById = wallets.maybeWhen(
      data: (items) => walletsByIdMap(items),
      orElse: () => const <String, WalletEntity>{},
    );

    return transactions.when(
      data: (items) {
        if (items.isEmpty) {
          return const Text(
            'No recent transactions.',
            style: TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
          );
        }
        return Column(
          children: [
            for (final item in items) ...[
              _transactionCard(
                context,
                item,
                conversion,
                displayCurrency,
                walletsById,
              ),
              const SizedBox(height: 8),
            ],
          ],
        );
      },
      loading: () => const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Text(
        _errorText(error),
        style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
      ),
    );
  }

  String _errorText(Object error) {
    if (error is AppFailure) {
      return error.message;
    }
    return 'Failed to load data.';
  }

  Widget _walletCard(WalletEntity wallet, bool hideBalances, double balance) {
    final currencyCode = wallet.currency.trim().toUpperCase();
    return Container(
      width: 240,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Center(
                      child: CurrencyFlag(
                        currencyCode: currencyCode,
                        width: 22,
                        height: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    wallet.name,
                    style: const TextStyle(
                      color: Color(0xFF111111),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFF2E2E2E)),
                ),
                child: Text(
                  currencyCode,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            hideBalances
                ? '****'
                : formatMoney(balance, currencyCode),
            style: const TextStyle(
              color: Color(0xFF111111),
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            wallet.currency,
            style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _addWalletCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/wallets/create'),
      child: Container(
        width: 80,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.4),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add, color: Color(0xFF8B8B8B)),
            SizedBox(height: 8),
            Text(
              'Add',
              style: TextStyle(
                color: Color(0xFF8B8B8B),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _budgetStatusCard(BudgetStatusEntity budget) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TransactionCategoryIcon(
                categoryName: budget.categoryName,
                categoryIcon: budget.categoryName,
                isTransfer: false,
                size: 36,
                iconSize: 18,
                backgroundColor: const Color(0xFFF3F4F6),
                borderRadius: 8,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  budget.categoryName,
                  style: const TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${formatMoney(budget.spentAmount, budget.currency)} / ${formatMoney(budget.budgetAmount, budget.currency)}',
            style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: budget.progress,
            backgroundColor: const Color(0xFFF3F4F6),
            color: budget.isOverBudget
                ? const Color(0xFFEF4444)
                : const Color(0xFF10B981),
            minHeight: 6,
            borderRadius: BorderRadius.circular(999),
          ),
          if (budget.isOverBudget) ...[
            const SizedBox(height: 4),
            Text(
              'Over by ${formatMoney((budget.spentAmount - budget.budgetAmount).abs(), budget.currency)}',
              style: const TextStyle(color: Color(0xFFFB2C36), fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _topCategoryRow(TopCategoryEntity category, String displayCurrency) {
    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  TransactionCategoryIcon(
                    categoryName: category.categoryName,
                    categoryIcon: category.categoryName,
                    isTransfer: false,
                    size: 36,
                    iconSize: 16,
                    backgroundColor: const Color(0xFFF3F4F6),
                    borderRadius: 8,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category.categoryName,
                    style: const TextStyle(
                      color: Color(0xFF111111),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                formatMoney(category.totalAmount, displayCurrency),
                style: const TextStyle(
                  color: Color(0xFF111111),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (category.percentage / 100).clamp(0, 1),
            backgroundColor: const Color(0xFFF3F4F6),
            color: const Color(0xFF111111),
            minHeight: 6,
            borderRadius: BorderRadius.circular(999),
          ),
        ],
      ),
    );
  }

  Widget _goalCardFromData(SavingGoalEntity goal) {
    final savedDisplay = goal.currentAmount;
    final targetDisplay = goal.targetAmount;
    return Container(
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const GoalLogo(size: 40, padding: 6),
                  const SizedBox(width: 8),
                  Text(
                    goal.name,
                    style: const TextStyle(
                      color: Color(0xFF111111),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                '${goal.progressPercent.toStringAsFixed(0)}%',
                style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: goal.progress,
            backgroundColor: const Color(0xFFF3F4F6),
            color: const Color(0xFF111111),
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatMoney(savedDisplay, goalBaseCurrency),
                style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
              ),
              Text(
                formatMoney(targetDisplay, goalBaseCurrency),
                style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _transactionCard(
    BuildContext context,
    TransactionEntity item,
    CurrencyConversionService conversion,
    String displayCurrency,
    Map<String, WalletEntity> walletsById,
  ) {
    final isTransfer = item.isTransfer || item.isTransferLinked;
    final amountSign = item.isIncome ? '+' : '-';
    final amountColor = amountSign == '-'
        ? const Color(0xFFFF0000)
        : const Color(0xFF00A63E);
    final convertedAmount = convertTransactionAmount(
      transaction: item,
      targetCurrency: displayCurrency,
      conversion: conversion,
      walletsById: walletsById,
    );
    final amountText =
        '$amountSign${formatMoney(convertedAmount, displayCurrency)}';
    final iconBg = isTransfer
        ? const Color(0xFFE1EBFF)
        : item.isIncome
        ? const Color(0xFFD9F0C8)
        : const Color(0xFFFFD3D4);
    return GestureDetector(
      onTap: () => context.push('/transactions/${item.id}'),
      child: Container(
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
                TransactionCategoryIcon(
                  categoryName: item.categoryName,
                  categoryIcon: item.categoryName,
                  isTransfer: isTransfer,
                  backgroundColor: iconBg,
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
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
              amountText,
              style: TextStyle(
                color: amountColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _currencyDropdown(List<String> items, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E2E2E)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xFF8B8B8B),
            size: 18,
          ),
          dropdownColor: const Color(0xFF1F1F1F),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          isDense: true,
          items: items
              .map(
                (currency) => DropdownMenuItem<String>(
                  value: currency,
                  child: Text(
                    currency,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
              .toList(),
          selectedItemBuilder: (context) => items
              .map(
                (currency) => Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    currency,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (next) {
            if (next == null) {
              return;
            }
            ref.read(selectedDisplayCurrencyProvider.notifier).state = next;
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    return DateFormat('yyyy-MM-dd').format(value);
  }

  void _onTabSelected(BuildContext context, AppTab tab) {
    switch (tab) {
      case AppTab.home:
        return;
      case AppTab.transactions:
        context.go('/transactions');
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

  Widget _quickAction(
    String label,
    String icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Image.asset(
                icon,
                width: 20,
                height: 20,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _restoreUiPreferences() async {
    final storage = ref.read(secureStorageProvider);
    final hideBalancesSaved = await storage.readBool(_hideBalancesStorageKey);
    final firstPromptSaved = await storage.readBool(_firstWalletPromptStorageKey);
    if (!mounted) {
      return;
    }
    setState(() {
      _hideBalances = hideBalancesSaved ?? false;
      _hideBalancesLoaded = true;
      _firstWalletPromptShown = firstPromptSaved ?? false;
    });
  }

  Future<void> _toggleHideBalances() async {
    final nextValue = !_hideBalances;
    setState(() {
      _hideBalances = nextValue;
    });
    await ref.read(secureStorageProvider).writeBool(
      _hideBalancesStorageKey,
      nextValue,
    );
  }

  void _maybeShowCreateWalletPrompt(AsyncValue<List<WalletEntity>> wallets) {
    if (!_hideBalancesLoaded || _firstWalletPromptShown) {
      return;
    }
    final hasNoWallets = wallets.maybeWhen(
      data: (items) => items.isEmpty,
      orElse: () => false,
    );
    if (!hasNoWallets) {
      return;
    }

    _firstWalletPromptShown = true;
    Future.microtask(() async {
      if (!mounted) {
        return;
      }
      await ref
          .read(secureStorageProvider)
          .writeBool(_firstWalletPromptStorageKey, true);
      if (!mounted) {
        return;
      }
      showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome to Qash',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Create your first wallet before adding transactions, so every record has a home.',
                  style: TextStyle(
                    color: Color(0xFFBDBDBD),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFF3A3A3A)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Later'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.push('/wallets/create');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF4D93A),
                          foregroundColor: const Color(0xFF111111),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Create Wallet',
                          style: TextStyle(fontWeight: FontWeight.w700),
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
    });
  }
}
