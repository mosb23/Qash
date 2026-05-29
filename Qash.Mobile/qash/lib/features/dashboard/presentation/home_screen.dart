import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/currency/currency_format.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/widgets/currency_flag.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../../budgets/domain/entities/budget_status.dart';
import '../../budgets/providers/budgets_providers.dart';
import '../../goals/domain/entities/saving_goal.dart';
import '../../goals/providers/saving_goals_providers.dart';
import '../../profile/domain/entities/profile.dart';
import '../../profile/providers/profile_providers.dart';
import '../../transactions/domain/entities/transaction.dart';
import '../../transactions/providers/transactions_providers.dart';
import '../../wallets/domain/entities/wallet.dart';
import '../../wallets/providers/wallets_providers.dart';
import '../../wallets/utils/wallet_balance_utils.dart';
import '../domain/entities/dashboard.dart';
import '../providers/dashboard_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _hideBalances = false;
  String? _selectedCurrency;

  @override
  Widget build(BuildContext context) {
    final profile = _resolveResult<ProfileEntity>(ref.watch(profileProvider));
    final dashboard = _resolveResult<DashboardEntity>(
      ref.watch(dashboardProvider),
    );
    final wallets = _resolveResultList<WalletEntity>(
      ref.watch(walletsProvider),
    );
    final transactions = _resolveResultList<TransactionEntity>(
      ref.watch(transactionsProvider),
    );
    final availableCurrencies = _walletCurrencies(wallets);
    final activeCurrency = _resolveActiveCurrency(availableCurrencies);
    final currencyTotals = _transactionsTotalsForCurrency(
      transactions,
      wallets,
      activeCurrency,
    );
    final budgets = _resolveResultList<BudgetStatusEntity>(
      ref.watch(budgetStatusesProvider),
    );
    final goals = _resolveResultList<SavingGoalEntity>(
      ref.watch(savingGoalsProvider),
    );
    final recents = _resolveRecentTransactions(ref.watch(transactionsProvider));
    final exchangeRates = ref
        .watch(exchangeRatesProvider)
        .maybeWhen(
          data: (rates) => defaultRatesOr(rates),
          orElse: () => defaultRatesOr(null),
        );

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
                                        : _formatCurrencyWithSymbol(
                                            _walletsTotalForCurrency(
                                              wallets,
                                              transactions,
                                              activeCurrency,
                                              exchangeRates,
                                            ),
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
                                      setState(() {
                                        _hideBalances = !_hideBalances;
                                      });
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
                                                : _formatCurrencyWithSymbol(
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
                                                : _formatCurrencyWithSymbol(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _quickAction(
                                  'Income',
                                  '\u2199',
                                  const Color(0xFFD9F0C8),
                                  onTap: () =>
                                      context.push('/transactions/add?type=1'),
                                ),
                                _quickAction(
                                  'Expense',
                                  '\u2197',
                                  const Color(0xFFFEE2E2),
                                  onTap: () =>
                                      context.push('/transactions/add?type=2'),
                                ),
                                _quickAction(
                                  'Transfer',
                                  '\u21c4',
                                  const Color(0xFFEFF6FF),
                                  onTap: () =>
                                      context.push('/transactions/add?type=3'),
                                ),
                                _quickAction(
                                  'Wallets',
                                  '\u25a4',
                                  const Color(0xFFF3F4F6),
                                  onTap: () => context.push('/wallets'),
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
                            _topCategoriesSection(dashboard),
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
                            _recentSection(context, recents),
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

  String _resolveActiveCurrency(List<String> currencies) {
    if (_selectedCurrency == null || !currencies.contains(_selectedCurrency)) {
      final nextCurrency = currencies.isNotEmpty ? currencies.first : 'USD';
      if (_selectedCurrency != nextCurrency) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          setState(() {
            _selectedCurrency = nextCurrency;
          });
        });
      }
      return nextCurrency;
    }
    return _selectedCurrency!;
  }

  List<String> _walletCurrencies(AsyncValue<List<WalletEntity>> wallets) {
    return wallets.maybeWhen(
      data: (items) {
        final values = <String>{};
        for (final wallet in items) {
          final currency = wallet.currency.trim();
          if (currency.isNotEmpty) {
            values.add(currency.toUpperCase());
          }
        }
        final list = values.toList()..sort();
        return list.isEmpty ? ['USD'] : list;
      },
      orElse: () => ['USD'],
    );
  }

  double _walletsTotalForCurrency(
    AsyncValue<List<WalletEntity>> wallets,
    AsyncValue<List<TransactionEntity>> transactions,
    String currency,
    Map<String, double> exchangeRates,
  ) {
    return wallets.maybeWhen(
      data: (items) {
        final walletTransactions = transactions.maybeWhen(
          data: (txItems) => txItems,
          orElse: () => const <TransactionEntity>[],
        );
        final walletsById = walletsByIdMap(items);
        final target = currency.toUpperCase();
        return items
            .where((item) => item.currency.toUpperCase() == target)
            .fold<double>(
              0,
              (sum, item) =>
                  sum +
                  displayWalletBalance(
                    wallet: item,
                    allTransactions: walletTransactions,
                    walletsById: walletsById,
                    exchangeRates: exchangeRates,
                  ),
            );
      },
      orElse: () => 0,
    );
  }

  Map<String, String> _walletCurrencyById(
    AsyncValue<List<WalletEntity>> wallets,
  ) {
    return wallets.maybeWhen(
      data: (items) => {
        for (final wallet in items) wallet.walletId: wallet.currency,
      },
      orElse: () => const {},
    );
  }

  _CurrencyTotals _transactionsTotalsForCurrency(
    AsyncValue<List<TransactionEntity>> transactions,
    AsyncValue<List<WalletEntity>> wallets,
    String currency,
  ) {
    final walletCurrencies = _walletCurrencyById(wallets);
    final now = DateTime.now();
    return transactions.maybeWhen(
      data: (items) {
        final target = currency.toUpperCase();
        var income = 0.0;
        var expenses = 0.0;
        for (final item in items) {
          if (item.isTransfer) {
            continue;
          }
          if (item.transactionDate.year != now.year ||
              item.transactionDate.month != now.month) {
            continue;
          }
          final walletCurrency = walletCurrencies[item.walletId];
          if (walletCurrency == null ||
              walletCurrency.toUpperCase() != target) {
            continue;
          }
          if (item.isIncome) {
            income += item.amount;
          } else if (item.isExpense) {
            expenses += item.amount;
          }
        }
        return _CurrencyTotals(income: income, expenses: expenses);
      },
      orElse: () => const _CurrencyTotals(income: 0, expenses: 0),
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
        gradient: const LinearGradient(
          colors: [Color(0xFF05DF72), Color(0xFF00BC7D)],
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Center(
        child: Text(
          alias,
          style: const TextStyle(color: Colors.white, fontSize: 14),
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

  Widget _topCategoriesSection(AsyncValue<DashboardEntity> dashboard) {
    return dashboard.when(
      data: (value) {
        if (value.topCategories.isEmpty) {
          return const Text(
            'No category spendings yet.',
            style: TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
          );
        }
        return Column(
          children: [
            for (final category in value.topCategories) ...[
              _topCategoryRow(category),
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
  ) {
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
              _transactionCard(context, item),
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
                : _formatCurrencyWithSymbol(balance, currencyCode),
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
          Text(
            budget.categoryName,
            style: const TextStyle(
              color: Color(0xFF111111),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_formatCurrency(budget.spentAmount)} / ${_formatCurrency(budget.budgetAmount)}',
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
              'Over by ${_formatCurrency((budget.spentAmount - budget.budgetAmount).abs())}',
              style: const TextStyle(color: Color(0xFFFB2C36), fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _topCategoryRow(TopCategoryEntity category) {
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
              Text(
                category.categoryName,
                style: const TextStyle(
                  color: Color(0xFF111111),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _formatCurrency(category.totalAmount),
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
                  const Text('G', style: TextStyle(fontSize: 20)),
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
                _formatCurrency(goal.currentAmount),
                style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
              ),
              Text(
                _formatCurrency(goal.targetAmount),
                style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _transactionCard(BuildContext context, TransactionEntity item) {
    final isTransfer = item.isTransfer;
    final amountColor = isTransfer
        ? const Color(0xFF2B7FFF)
        : item.isIncome
        ? const Color(0xFF00A63E)
        : const Color(0xFFFF0004);
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
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(iconText, style: const TextStyle(fontSize: 18)),
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
              '$amountSign${_formatTransactionAmount(item)}',
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

  String _formatTransactionAmount(TransactionEntity item) {
    final code = item.walletCurrency.isNotEmpty ? item.walletCurrency : 'USD';
    return formatMoney(item.amount, code);
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(symbol: '\$').format(value);
  }

  String _formatCurrencyWithSymbol(double value, String code) {
    final symbol = _currencySymbol(code.toUpperCase());
    return NumberFormat.currency(symbol: symbol).format(value);
  }

  String _currencySymbol(String currencyCode) {
    switch (currencyCode) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '\u20ac';
      case 'GBP':
        return '\u00a3';
      case 'EGP':
        return 'E£';
      case 'JPY':
        return '\u00a5';
      default:
        return currencyCode.isNotEmpty ? currencyCode.substring(0, 1) : '\$';
    }
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
            setState(() {
              _selectedCurrency = next;
            });
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
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _CurrencyTotals {
  final double income;
  final double expenses;

  const _CurrencyTotals({required this.income, required this.expenses});
}
