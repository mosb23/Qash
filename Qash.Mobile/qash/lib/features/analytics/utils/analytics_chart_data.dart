import 'package:intl/intl.dart';

import '../../../core/currency/currency_aggregation.dart';
import '../../../core/currency/currency_conversion_service.dart';
import '../../transactions/domain/entities/transaction.dart';
import '../../wallets/domain/entities/wallet.dart';
import '../domain/entities/income_vs_expense.dart';
import '../domain/entities/spending_trend.dart';
import '../providers/analytics_providers.dart';

class AnalyticsChartBar {
  final String label;
  final double value;

  const AnalyticsChartBar({required this.label, required this.value});
}

class AnalyticsComparisonBar {
  final String label;
  final double income;
  final double expenses;

  const AnalyticsComparisonBar({
    required this.label,
    required this.income,
    required this.expenses,
  });
}

List<AnalyticsChartBar> spendingTrendBarsForPeriod({
  required List<SpendingTrendEntity> items,
  required AnalyticsPeriod period,
  required DateTime now,
  List<YearlyComparison> yearlyComparisons = const [],
}) {
  switch (period) {
    case AnalyticsPeriod.week:
      return _dailySpendingBars(items);
    case AnalyticsPeriod.month:
      return _monthWeekSpendingBars(items, now);
    case AnalyticsPeriod.year:
      return yearlyComparisons
          .map(
            (item) => AnalyticsChartBar(
              label: item.year.toString(),
              value: item.expenses,
            ),
          )
          .toList();
  }
}

List<AnalyticsChartBar> _dailySpendingBars(List<SpendingTrendEntity> items) {
  return items
      .map(
        (item) => AnalyticsChartBar(
          label: DateFormat('E').format(_toLocal(item.date)),
          value: item.totalExpenses,
        ),
      )
      .toList();
}

List<AnalyticsChartBar> _monthWeekSpendingBars(
  List<SpendingTrendEntity> items,
  DateTime now,
) {
  final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
  final weekCount = ((daysInMonth - 1) ~/ 7) + 1;
  final totals = List<double>.filled(weekCount, 0);

  for (final item in items) {
    final local = _toLocal(item.date);
    if (local.year != now.year || local.month != now.month) {
      continue;
    }
    final weekIndex = ((local.day - 1) ~/ 7).clamp(0, weekCount - 1);
    totals[weekIndex] += item.totalExpenses;
  }

  return List.generate(
    weekCount,
    (index) => AnalyticsChartBar(
      label: 'W${index + 1}',
      value: totals[index],
    ),
  );
}

List<AnalyticsComparisonBar> incomeVsExpenseBarsForPeriod({
  required List<IncomeVsExpenseEntity> monthlyItems,
  required List<YearlyComparison> yearlyItems,
  required List<TransactionEntity> periodTransactions,
  required AnalyticsPeriod period,
  required DateTime now,
  required DateTime from,
  required DateTime toExclusive,
  required CurrencyConversionService conversion,
  required String displayCurrency,
  Map<String, WalletEntity> walletsById = const {},
}) {
  switch (period) {
    case AnalyticsPeriod.week:
      return _dailyIncomeExpenseBars(
        periodTransactions,
        from: from,
        toExclusive: toExclusive,
        conversion: conversion,
        displayCurrency: displayCurrency,
        walletsById: walletsById,
      );
    case AnalyticsPeriod.month:
      return _monthWeekIncomeExpenseBars(
        periodTransactions,
        now: now,
        from: from,
        toExclusive: toExclusive,
        conversion: conversion,
        displayCurrency: displayCurrency,
        walletsById: walletsById,
      );
    case AnalyticsPeriod.year:
      return yearlyItems
          .map(
            (item) => AnalyticsComparisonBar(
              label: item.year.toString(),
              income: item.income,
              expenses: item.expenses,
            ),
          )
          .toList();
  }
}

List<AnalyticsComparisonBar> _dailyIncomeExpenseBars(
  List<TransactionEntity> transactions, {
  required DateTime from,
  required DateTime toExclusive,
  required CurrencyConversionService conversion,
  required String displayCurrency,
  Map<String, WalletEntity> walletsById = const {},
}) {
  final dayCount = toExclusive.difference(from).inDays.clamp(1, 31);
  final incomeTotals = List<double>.filled(dayCount, 0);
  final expenseTotals = List<double>.filled(dayCount, 0);

  for (final transaction in _transactionsInRange(
    transactions,
    from: from,
    toExclusive: toExclusive,
  )) {
    final local = _toLocal(transaction.transactionDate);
    final dayIndex = local.difference(from).inDays;
    if (dayIndex < 0 || dayIndex >= dayCount) {
      continue;
    }

    final converted = _convertedTransactionAmount(
      transaction,
      conversion: conversion,
      displayCurrency: displayCurrency,
      walletsById: walletsById,
    );

    if (transaction.isTransfer) {
      expenseTotals[dayIndex] += converted;
    } else if (transaction.isIncome) {
      incomeTotals[dayIndex] += converted;
    } else if (transaction.isExpense) {
      expenseTotals[dayIndex] += converted;
    }
  }

  return List.generate(
    dayCount,
    (index) {
      final day = from.add(Duration(days: index));
      return AnalyticsComparisonBar(
        label: DateFormat('E').format(day),
        income: incomeTotals[index],
        expenses: expenseTotals[index],
      );
    },
  );
}

List<AnalyticsComparisonBar> _monthWeekIncomeExpenseBars(
  List<TransactionEntity> transactions, {
  required DateTime now,
  required DateTime from,
  required DateTime toExclusive,
  required CurrencyConversionService conversion,
  required String displayCurrency,
  Map<String, WalletEntity> walletsById = const {},
}) {
  final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
  final weekCount = ((daysInMonth - 1) ~/ 7) + 1;
  final incomeTotals = List<double>.filled(weekCount, 0);
  final expenseTotals = List<double>.filled(weekCount, 0);

  for (final transaction in _transactionsInRange(
    transactions,
    from: from,
    toExclusive: toExclusive,
  )) {
    final local = _toLocal(transaction.transactionDate);
    if (local.year != now.year || local.month != now.month) {
      continue;
    }

    final weekIndex = ((local.day - 1) ~/ 7).clamp(0, weekCount - 1);
    final converted = _convertedTransactionAmount(
      transaction,
      conversion: conversion,
      displayCurrency: displayCurrency,
      walletsById: walletsById,
    );

    if (transaction.isTransfer) {
      expenseTotals[weekIndex] += converted;
    } else if (transaction.isIncome) {
      incomeTotals[weekIndex] += converted;
    } else if (transaction.isExpense) {
      expenseTotals[weekIndex] += converted;
    }
  }

  return List.generate(
    weekCount,
    (index) => AnalyticsComparisonBar(
      label: 'W${index + 1}',
      income: incomeTotals[index],
      expenses: expenseTotals[index],
    ),
  );
}

List<TransactionEntity> _transactionsInRange(
  List<TransactionEntity> transactions, {
  required DateTime from,
  required DateTime toExclusive,
}) {
  return transactions.where((transaction) {
    final local = _toLocal(transaction.transactionDate);
    return !local.isBefore(from) && local.isBefore(toExclusive);
  }).toList();
}

double _convertedTransactionAmount(
  TransactionEntity transaction, {
  required CurrencyConversionService conversion,
  required String displayCurrency,
  Map<String, WalletEntity> walletsById = const {},
}) {
  return convertTransactionAmount(
    transaction: transaction,
    targetCurrency: displayCurrency,
    conversion: conversion,
    walletsById: walletsById,
  );
}

DateTime _toLocal(DateTime date) => date.isUtc ? date.toLocal() : date;
