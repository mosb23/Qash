import '../../features/budgets/domain/entities/budget_status.dart';
import '../../features/transactions/domain/entities/transaction.dart';
import '../../features/transactions/utils/transfer_amount_utils.dart';
import '../../features/wallets/domain/entities/wallet.dart';
import '../../features/wallets/utils/wallet_balance_utils.dart';
import 'currency_conversion_service.dart';

/// Resolves the currency an amount was recorded in (always the source wallet).
String resolveTransactionCurrency({
  required TransactionEntity transaction,
  Map<String, WalletEntity> walletsById = const {},
  String fallback = kBaseCurrency,
}) {
  return resolveWalletCurrency(
    walletId: transaction.walletId,
    transactionCurrency:
        transaction.walletCurrency.isNotEmpty ? transaction.walletCurrency : null,
    walletsById: walletsById,
    fallback: fallback,
  );
}

/// Converts a transaction amount into the target display/budget currency.
double convertTransactionAmount({
  required TransactionEntity transaction,
  required String targetCurrency,
  required CurrencyConversionService conversion,
  Map<String, WalletEntity> walletsById = const {},
}) {
  if (transaction.amount == 0) {
    return 0;
  }

  final fromCurrency = resolveTransactionCurrency(
    transaction: transaction,
    walletsById: walletsById,
  );
  final normalizedTarget = targetCurrency.trim().toUpperCase();

  if (fromCurrency == normalizedTarget) {
    return transaction.amount;
  }

  return conversion.convert(
    amount: transaction.amount,
    fromCurrency: fromCurrency,
    toCurrency: normalizedTarget,
  );
}

double resolveTransactionAmountInBase({
  required TransactionEntity transaction,
  required CurrencyConversionService conversion,
  Map<String, WalletEntity> walletsById = const {},
}) {
  if (transaction.amount == 0) {
    return 0;
  }

  final currency = resolveTransactionCurrency(
    transaction: transaction,
    walletsById: walletsById,
  );
  return conversion.convertToBase(transaction.amount, currency);
}

double sumWalletBalancesInCurrency({
  required List<WalletEntity> wallets,
  required List<TransactionEntity> transactions,
  required String targetCurrency,
  required CurrencyConversionService conversion,
}) {
  final walletsById = walletsByIdMap(wallets);
  var total = 0.0;

  for (final wallet in wallets) {
    final balance = displayWalletBalance(
      wallet: wallet,
      allTransactions: transactions,
      walletsById: walletsById,
      exchangeRates: conversion.rates,
    );
    total += conversion.convert(
      amount: balance,
      fromCurrency: wallet.currency,
      toCurrency: targetCurrency,
    );
  }

  return total;
}

MonthlyCurrencyTotals sumMonthlyIncomeExpenseInCurrency({
  required List<TransactionEntity> transactions,
  required String targetCurrency,
  required CurrencyConversionService conversion,
  Map<String, WalletEntity> walletsById = const {},
  DateTime? referenceDate,
}) {
  final now = referenceDate ?? DateTime.now();
  var income = 0.0;
  var expenses = 0.0;

  for (final item in transactions) {
    if (item.excludeFromGlobalTotals) {
      continue;
    }
    if (item.transactionDate.year != now.year ||
        item.transactionDate.month != now.month) {
      continue;
    }

    final converted = convertTransactionAmount(
      transaction: item,
      targetCurrency: targetCurrency,
      conversion: conversion,
      walletsById: walletsById,
    );

    if (item.isIncome) {
      income += converted;
    } else if (item.isExpense) {
      expenses += converted;
    }
  }

  return MonthlyCurrencyTotals(income: income, expenses: expenses);
}

List<BudgetStatusEntity> recomputeBudgetSpentAmounts({
  required List<BudgetStatusEntity> budgets,
  required List<TransactionEntity> transactions,
  required Map<String, WalletEntity> walletsById,
  required CurrencyConversionService conversion,
}) {
  return budgets.map((budget) {
    final spent = transactions
        .where(
          (item) =>
              item.isExpense &&
              item.categoryId == budget.categoryId &&
              item.transactionDate.year == budget.year &&
              item.transactionDate.month == budget.month,
        )
        .fold<double>(
          0,
          (sum, item) =>
              sum +
              convertTransactionAmount(
                transaction: item,
                targetCurrency: budget.currency,
                conversion: conversion,
                walletsById: walletsById,
              ),
        );

    final remaining = budget.budgetAmount - spent;
    return BudgetStatusEntity(
      budgetId: budget.budgetId,
      categoryId: budget.categoryId,
      categoryName: budget.categoryName,
      year: budget.year,
      month: budget.month,
      budgetAmount: budget.budgetAmount,
      spentAmount: spent,
      remainingAmount: remaining,
      currency: budget.currency,
    );
  }).toList();
}

class MonthlyCurrencyTotals {
  final double income;
  final double expenses;

  const MonthlyCurrencyTotals({
    required this.income,
    required this.expenses,
  });

  double get net => income - expenses;
}

List<String> collectWalletCurrencies(List<WalletEntity> wallets) {
  final values = <String>{};
  for (final wallet in wallets) {
    final currency = wallet.currency.trim();
    if (currency.isNotEmpty) {
      values.add(currency.toUpperCase());
    }
  }
  final list = values.toList()..sort();
  return list.isEmpty ? [kBaseCurrency] : list;
}
