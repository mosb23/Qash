import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qash/core/theme/qash_theme_extension.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../../../core/widgets/currency_badge.dart';
import '../providers/home_preferences_provider.dart';
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
import '../domain/entities/dashboard.dart';
import '../providers/dashboard_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qash = context.qash;
    final profile = _resolveResult<ProfileEntity>(ref.watch(profileProvider));
    final dashboard = _resolveResult<DashboardEntity>(
      ref.watch(dashboardProvider),
    );
    final wallets = _resolveResultList<WalletEntity>(
      ref.watch(walletsProvider),
    );
    final budgets = _resolveResultList<BudgetStatusEntity>(
      ref.watch(budgetStatusesProvider),
    );
    final goals = _resolveResultList<SavingGoalEntity>(
      ref.watch(savingGoalsProvider),
    );
    final recents = _resolveRecentTransactions(ref.watch(transactionsProvider));
    final hideBalance = ref.watch(balanceHiddenProvider);
    final displayCurrency = ref.watch(displayCurrencyProvider);

    ref.listen(walletsProvider, (_, next) {
      next.whenData((result) {
        if (result.isFailure) {
          return;
        }
        final items = result.data ?? const <WalletEntity>[];
        ref
            .read(displayCurrencyProvider.notifier)
            .applyDefaultFromWallets(items);
      });
    });

    return Scaffold(
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
                                _profileAvatar(context, profile),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome back,',
                                      style: TextStyle(
                                        color: qash.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      _profileName(profile),
                                      style: TextStyle(
                                        color: qash.textPrimary,
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
                            color: qash.primaryButton,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Balance',
                                    style: TextStyle(
                                      color: qash.onPrimaryButton
                                          .withValues(alpha: 0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _pickDisplayCurrency(
                                      context,
                                      ref,
                                      displayCurrency,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          displayCurrency,
                                          style: TextStyle(
                                            color: qash.onPrimaryButton
                                                .withValues(alpha: 0.7),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Icon(
                                          Icons.keyboard_arrow_down,
                                          color: qash.onPrimaryButton
                                              .withValues(alpha: 0.7),
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      hideBalance
                                          ? CurrencyFormatter.formatHidden()
                                          : _formatCurrency(
                                              _walletsTotal(
                                                wallets,
                                                displayCurrency,
                                              ),
                                              displayCurrency,
                                            ),
                                      style: TextStyle(
                                        color: qash.onPrimaryButton,
                                        fontSize: 30,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () => ref
                                        .read(balanceHiddenProvider.notifier)
                                        .toggle(),
                                    icon: Icon(
                                      hideBalance
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: qash.onPrimaryButton
                                          .withValues(alpha: 0.7),
                                      size: 22,
                                    ),
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
                                          Text(
                                            'Income',
                                            style: TextStyle(
                                              color: qash.onPrimaryButton
                                                  .withValues(alpha: 0.7),
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            hideBalance
                                                ? CurrencyFormatter.formatHidden()
                                                : _formatCurrency(
                                                    _dashboardValue(
                                                      dashboard,
                                                      (value) =>
                                                          value.monthlyIncome,
                                                    ),
                                                    displayCurrency,
                                                  ),
                                            style: TextStyle(
                                              color: qash.onPrimaryButton,
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
                                          Text(
                                            'Expenses',
                                            style: TextStyle(
                                              color: qash.onPrimaryButton
                                                  .withValues(alpha: 0.7),
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            hideBalance
                                                ? CurrencyFormatter.formatHidden()
                                                : _formatCurrency(
                                                    _dashboardValue(
                                                      dashboard,
                                                      (value) =>
                                                          value.monthlyExpenses,
                                                    ),
                                                    displayCurrency,
                                                  ),
                                            style: TextStyle(
                                              color: qash.onPrimaryButton,
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
                            Text(
                              'Wallets',
                              style: TextStyle(
                                color: qash.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.push('/wallets'),
                              child: Text(
                                'See all >',
                                style: TextStyle(
                                  color: qash.textSecondary,
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
                        displayCurrency,
                        hideBalance,
                      ),
                      const SizedBox(height: 24),
                      // -- Quick Actions --
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quick Actions',
                              style: TextStyle(
                                color: qash.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _quickAction(
                                  context,
                                  'Income',
                                  '\u2199',
                                  const Color(0xFFD9F0C8),
                                  onTap: () =>
                                      context.push('/transactions/add?type=1'),
                                ),
                                _quickAction(
                                  context,
                                  'Expense',
                                  '\u2197',
                                  const Color(0xFFFEE2E2),
                                  onTap: () =>
                                      context.push('/transactions/add?type=2'),
                                ),
                                _quickAction(
                                  context,
                                  'Transfer',
                                  '\u21c4',
                                  const Color(0xFFEFF6FF),
                                  onTap: () =>
                                      context.push('/transactions/add?type=3'),
                                ),
                                _quickAction(
                                  context,
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
                                Text(
                                  'Budget',
                                  style: TextStyle(
                                    color: qash.textPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => context.push('/budgets'),
                                  child: Text(
                                    'See all >',
                                    style: TextStyle(
                                      color: qash.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _budgetSection(
                              context,
                              budgets,
                              displayCurrency,
                              hideBalance,
                            ),
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
                            Text(
                              'Top Categories',
                              style: TextStyle(
                                color: qash.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _topCategoriesSection(
                              context,
                              dashboard,
                              displayCurrency,
                              hideBalance,
                            ),
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
                                Text(
                                  'Goals',
                                  style: TextStyle(
                                    color: qash.textPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => context.push('/goals'),
                                  child: Text(
                                    'See all >',
                                    style: TextStyle(
                                      color: qash.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _goalsSection(
                              context,
                              goals,
                              displayCurrency,
                              hideBalance,
                            ),
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
                                Text(
                                  'Recent Transactions',
                                  style: TextStyle(
                                    color: qash.textPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => context.push('/transactions'),
                                  child: Text(
                                    'See all >',
                                    style: TextStyle(
                                      color: qash.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _recentSection(
                              context,
                              recents,
                              displayCurrency,
                              hideBalance,
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

  double _dashboardValue(
    AsyncValue<DashboardEntity> dashboard,
    double Function(DashboardEntity) selector,
  ) {
    return dashboard.maybeWhen(data: selector, orElse: () => 0);
  }

  double _walletsTotal(
    AsyncValue<List<WalletEntity>> wallets,
    String displayCurrency,
  ) {
    return wallets.maybeWhen(
      data: (items) {
        if (items.isEmpty) {
          return 0;
        }
        final code = displayCurrency.toUpperCase();
        return items
            .where((item) => item.currency.toUpperCase() == code)
            .fold(0, (sum, item) => sum + item.balance);
      },
      orElse: () => 0,
    );
  }

  Future<void> _pickDisplayCurrency(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Display currency',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              for (final currency in supportedCurrencies)
                ListTile(
                  leading: CurrencyBadge(currencyCode: currency, size: 36),
                  title: Text(currency),
                  subtitle: Text(CurrencyFormatter.symbolFor(currency)),
                  trailing: current == currency
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => Navigator.pop(context, currency),
                ),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      await ref.read(displayCurrencyProvider.notifier).setCurrency(selected);
    }
  }

  String _profileName(AsyncValue<ProfileEntity> profile) {
    return profile.maybeWhen(
      data: (value) => value.resolvedName,
      orElse: () => 'User',
    );
  }

  Widget _profileAvatar(
    BuildContext context,
    AsyncValue<ProfileEntity> profile,
  ) {
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
    String displayCurrency,
    bool hideBalance,
  ) {
    return wallets.when(
      data: (items) {
        if (items.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'No wallets yet.',
              style: TextStyle(
                color: context.qash.textSecondary,
                fontSize: 12,
              ),
            ),
          );
        }

        return SizedBox(
          height: 148,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 24),
            children: [
              for (final wallet in items) ...[
                _walletCard(context, wallet, hideBalance),
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
          style: TextStyle(color: context.qash.textSecondary, fontSize: 12),
        ),
      ),
    );
  }

  Widget _budgetSection(
    BuildContext context,
    AsyncValue<List<BudgetStatusEntity>> budgets,
    String displayCurrency,
    bool hideBalance,
  ) {
    final qash = context.qash;
    return budgets.when(
      data: (items) {
        if (items.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'No budgets for this month.',
              style: TextStyle(color: qash.textSecondary, fontSize: 12),
            ),
          );
        }

        final cards = items.take(2).toList();
        return Row(
          children: [
            Expanded(
              child: _budgetStatusCard(
                context,
                cards.first,
                displayCurrency,
                hideBalance,
              ),
            ),
            if (cards.length > 1) ...[
              const SizedBox(width: 12),
              Expanded(
                child: _budgetStatusCard(
                  context,
                  cards.last,
                  displayCurrency,
                  hideBalance,
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
        style: TextStyle(color: qash.textSecondary, fontSize: 12),
      ),
    );
  }

  Widget _topCategoriesSection(
    BuildContext context,
    AsyncValue<DashboardEntity> dashboard,
    String displayCurrency,
    bool hideBalance,
  ) {
    final qash = context.qash;
    return dashboard.when(
      data: (value) {
        if (value.topCategories.isEmpty) {
          return Text(
            'No category spendings yet.',
            style: TextStyle(color: qash.textSecondary, fontSize: 12),
          );
        }
        return Column(
          children: [
            for (final category in value.topCategories) ...[
              _topCategoryRow(
                context,
                category,
                displayCurrency,
                hideBalance,
              ),
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
        style: TextStyle(color: qash.textSecondary, fontSize: 12),
      ),
    );
  }

  Widget _goalsSection(
    BuildContext context,
    AsyncValue<List<SavingGoalEntity>> goals,
    String displayCurrency,
    bool hideBalance,
  ) {
    final qash = context.qash;
    return goals.when(
      data: (items) {
        if (items.isEmpty) {
          return Text(
            'No goals yet.',
            style: TextStyle(color: qash.textSecondary, fontSize: 12),
          );
        }
        final list = items.take(2).toList();
        return Column(
          children: [
            for (final goal in list) ...[
              _goalCardFromData(
                context,
                goal,
                displayCurrency,
                hideBalance,
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
        style: TextStyle(color: qash.textSecondary, fontSize: 12),
      ),
    );
  }

  Widget _recentSection(
    BuildContext context,
    AsyncValue<List<TransactionEntity>> transactions,
    String displayCurrency,
    bool hideBalance,
  ) {
    final qash = context.qash;
    return transactions.when(
      data: (items) {
        if (items.isEmpty) {
          return Text(
            'No recent transactions.',
            style: TextStyle(color: qash.textSecondary, fontSize: 12),
          );
        }
        return Column(
          children: [
            for (final item in items) ...[
              _transactionCard(
                context,
                item,
                displayCurrency,
                hideBalance,
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
        style: TextStyle(color: qash.textSecondary, fontSize: 12),
      ),
    );
  }

  String _errorText(Object error) {
    if (error is AppFailure) {
      return error.message;
    }
    return 'Failed to load data.';
  }

  Widget _walletCard(
    BuildContext context,
    WalletEntity wallet,
    bool hideBalance,
  ) {
    final qash = context.qash;
    return GestureDetector(
      onTap: () => context.push('/wallets/${wallet.walletId}/edit', extra: wallet),
      child: Container(
      width: 240,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: qash.surface,
        borderRadius: BorderRadius.circular(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CurrencyBadge(currencyCode: wallet.currency),
                  const SizedBox(width: 8),
                  Text(
                    wallet.name,
                    style: TextStyle(
                      color: qash.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: qash.border,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  wallet.currency,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: qash.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            hideBalance
                ? CurrencyFormatter.formatHidden()
                : _formatCurrency(wallet.balance, wallet.currency),
            style: TextStyle(
              color: qash.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            wallet.currency,
            style: TextStyle(color: qash.textSecondary, fontSize: 12),
          ),
        ],
      ),
    ),
    );
  }

  Widget _addWalletCard(BuildContext context) {
    final qash = context.qash;
    return GestureDetector(
      onTap: () => context.push('/wallets/create'),
      child: Container(
        width: 80,
        decoration: BoxDecoration(
          border: Border.all(color: qash.border, width: 1.4),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: qash.textSecondary),
            const SizedBox(height: 8),
            Text(
              'Add',
              style: TextStyle(
                color: qash.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _budgetStatusCard(
    BuildContext context,
    BudgetStatusEntity budget,
    String displayCurrency,
    bool hideBalance,
  ) {
    final qash = context.qash;
    return GestureDetector(
      onTap: () => context.push(
        '/budgets/${budget.budgetId}/edit',
        extra: budget,
      ),
      child: Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            budget.categoryName,
            style: TextStyle(
              color: qash.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hideBalance
                ? CurrencyFormatter.formatHidden()
                : '${_formatCurrency(budget.spentAmount, displayCurrency)} / ${_formatCurrency(budget.budgetAmount, displayCurrency)}',
            style: TextStyle(color: qash.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: budget.progress,
            backgroundColor: qash.border,
            color: budget.isOverBudget
                ? qash.danger
                : const Color(0xFF10B981),
            minHeight: 6,
            borderRadius: BorderRadius.circular(999),
          ),
          if (budget.isOverBudget) ...[
            const SizedBox(height: 4),
            Text(
              hideBalance
                  ? 'Over budget'
                  : 'Over by ${_formatCurrency((budget.spentAmount - budget.budgetAmount).abs(), displayCurrency)}',
              style: const TextStyle(color: Color(0xFFFB2C36), fontSize: 12),
            ),
          ],
        ],
      ),
    ),
    );
  }

  Widget _topCategoryRow(
    BuildContext context,
    TopCategoryEntity category,
    String displayCurrency,
    bool hideBalance,
  ) {
    final qash = context.qash;
    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category.categoryName,
                style: TextStyle(
                  color: qash.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                hideBalance
                    ? CurrencyFormatter.formatHidden()
                    : _formatCurrency(category.totalAmount, displayCurrency),
                style: TextStyle(
                  color: qash.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (category.percentage / 100).clamp(0, 1),
            backgroundColor: qash.border,
            color: qash.textPrimary,
            minHeight: 6,
            borderRadius: BorderRadius.circular(999),
          ),
        ],
      ),
    );
  }

  Widget _goalCardFromData(
    BuildContext context,
    SavingGoalEntity goal,
    String displayCurrency,
    bool hideBalance,
  ) {
    final qash = context.qash;
    return Container(
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('G',
                      style: TextStyle(fontSize: 20, color: qash.textPrimary)),
                  const SizedBox(width: 8),
                  Text(
                    goal.name,
                    style: TextStyle(
                      color: qash.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                '${goal.progressPercent.toStringAsFixed(0)}%',
                style: TextStyle(color: qash.textSecondary, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: goal.progress,
            backgroundColor: qash.border,
            color: qash.textPrimary,
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                hideBalance
                    ? CurrencyFormatter.formatHidden()
                    : _formatCurrency(goal.currentAmount, displayCurrency),
                style: TextStyle(color: qash.textSecondary, fontSize: 12),
              ),
              Text(
                hideBalance
                    ? CurrencyFormatter.formatHidden()
                    : _formatCurrency(goal.targetAmount, displayCurrency),
                style: TextStyle(color: qash.textSecondary, fontSize: 12),
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
    String displayCurrency,
    bool hideBalance,
  ) {
    final qash = context.qash;
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

    return Container(
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
                    style: TextStyle(
                      color: qash.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _formatDate(item.transactionDate),
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
            hideBalance
                ? CurrencyFormatter.formatHidden()
                : '$amountSign${_formatCurrency(item.amount, displayCurrency)}',
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

  String _formatCurrency(double value, String currencyCode) {
    return CurrencyFormatter.format(value, currencyCode);
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
    BuildContext context,
    String label,
    String icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    final qash = context.qash;
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
            style: TextStyle(color: qash.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
