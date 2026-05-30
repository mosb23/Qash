import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/app_navigation.dart';
import '../../../core/currency/currency_aggregation.dart';
import '../../../core/currency/currency_conversion_service.dart';
import '../../../core/currency/currency_format.dart';
import '../../../core/currency/currency_providers.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/widgets/currency_flag.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../domain/entities/wallet.dart';
import '../../transactions/domain/entities/transaction.dart';
import '../../transactions/providers/transactions_providers.dart';
import '../providers/wallets_providers.dart';
import '../utils/wallet_balance_utils.dart';

class WalletsScreen extends ConsumerWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallets = ref.watch(walletsProvider);
    final transactionsAsync = ref.watch(transactionsProvider);
    final conversion = ref.watch(currencyConversionServiceProvider);
    final activeCurrency = ref.watch(effectiveDisplayCurrencyProvider);

    final typedTransactions = transactionsAsync.maybeWhen(
      data: (result) => result.isFailure
          ? const <TransactionEntity>[]
          : (result.data ?? const []),
      orElse: () => const <TransactionEntity>[],
    );
    final exchangeRates = conversion.rates;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F6F3),
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
              onPressed: () => popOrGo(context, '/home'),
            ),
          ),
        ),
        title: const Text(
          'Wallets',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF4D93A),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => context.push('/wallets/create'),
                icon: const Icon(Icons.add, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: wallets.when(
            data: (result) {
              if (result.isFailure) {
                return Text(
                  result.message,
                  style: const TextStyle(
                    color: Color(0xFF8B8B8B),
                    fontSize: 12,
                  ),
                );
              }
              final items = result.data ?? const [];
              final availableCurrencies = _dropdownCurrencies(
                items,
                activeCurrency,
              );
              final walletsById = walletsByIdMap(items);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _summaryCard(
                    ref,
                    items,
                    availableCurrencies,
                    activeCurrency,
                    typedTransactions,
                    conversion,
                  ),
                  const SizedBox(height: 20),
                  if (items.isEmpty)
                    const Text(
                      'No wallets yet.',
                      style: TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
                    )
                  else
                    for (final wallet in items) ...[
                      _walletCard(
                        context,
                        wallet,
                        typedTransactions,
                        walletsById,
                        exchangeRates,
                      ),
                      const SizedBox(height: 12),
                    ],
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/wallets/create'),
                      icon: const Icon(Icons.add, color: Colors.black),
                      label: const Text(
                        'Add New Wallet',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF4D93A),
                        foregroundColor: Colors.black,
                        elevation: 3,
                        shadowColor: const Color(0x22000000),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => Text(
              _errorText(error),
              style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentTab: AppTab.home,
        onSelected: (tab) => _onTabSelected(context, tab),
      ),
    );
  }

  Widget _summaryCard(
    WidgetRef ref,
    List<WalletEntity> wallets,
    List<String> currencies,
    String activeCurrency,
    List<TransactionEntity> transactions,
    CurrencyConversionService conversion,
  ) {
    final total = sumWalletBalancesInCurrency(
      wallets: wallets,
      transactions: transactions,
      targetCurrency: activeCurrency,
      conversion: conversion,
    );
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Assets',
                style: TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
              ),
              _currencyDropdown(ref, currencies, activeCurrency),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formatMoney(total, activeCurrency),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${wallets.length} wallets',
            style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _walletCard(
    BuildContext context,
    WalletEntity wallet,
    List<TransactionEntity> transactions,
    Map<String, WalletEntity> walletsById,
    Map<String, double> exchangeRates,
  ) {
    final balance = displayWalletBalance(
      wallet: wallet,
      allTransactions: transactions,
      walletsById: walletsById,
      exchangeRates: exchangeRates,
    );

    return GestureDetector(
      onTap: () => context.push('/wallets/${wallet.walletId}', extra: wallet),
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
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: CurrencyFlag(
                  currencyCode: wallet.currency.trim().toUpperCase(),
                  width: 28,
                  height: 18,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wallet.name,
                    style: const TextStyle(
                      color: Color(0xFF111111),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const SizedBox(height: 2),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatMoney(
                    balance,
                    wallet.currency.trim().toUpperCase(),
                  ),
                  style: const TextStyle(
                    color: Color(0xFF111111),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF), size: 20),
          ],
        ),
      ),
    );
  }

  void _onTabSelected(BuildContext context, AppTab tab) {
    switch (tab) {
      case AppTab.home:
        context.go('/home');
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

  List<String> _dropdownCurrencies(
    List<WalletEntity> wallets,
    String activeCurrency,
  ) {
    final currencies = collectWalletCurrencies(wallets);
    if (!currencies.contains(activeCurrency)) {
      return [...currencies, activeCurrency]..sort();
    }
    return currencies;
  }

  Widget _currencyDropdown(
    WidgetRef ref,
    List<String> items,
    String value,
  ) {
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
                      fontWeight: FontWeight.w600,
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

  String _errorText(Object error) {
    if (error is AppFailure) {
      return error.message;
    }
    return 'Failed to load wallets.';
  }
}
