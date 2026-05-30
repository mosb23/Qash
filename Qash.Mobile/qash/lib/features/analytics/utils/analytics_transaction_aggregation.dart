import 'package:intl/intl.dart';

import '../../../core/currency/currency_aggregation.dart';
import '../../../core/currency/currency_conversion_service.dart';
import '../../dashboard/domain/entities/dashboard.dart';
import '../../transactions/domain/entities/transaction.dart';
import '../../wallets/domain/entities/wallet.dart';
import '../providers/analytics_providers.dart';
import 'analytics_chart_data.dart';

DateTime transactionLocalDate(TransactionEntity transaction) {
  final local = transaction.transactionDate.isUtc
      ? transaction.transactionDate.toLocal()
      : transaction.transactionDate;
  return DateTime(local.year, local.month, local.day);
}

bool transactionInRange(
  TransactionEntity transaction,
  DateTime from,
  DateTime toExclusive,
) {
  final date = transactionLocalDate(transaction);
  return !date.isBefore(from) && date.isBefore(toExclusive);
}

List<YearlyComparison> computeYearlyComparisonFromTransactions({
  required List<TransactionEntity> transactions,
  required String displayCurrency,
  required CurrencyConversionService conversion,
  Map<String, WalletEntity> walletsById = const {},
}) {
  final now = DateTime.now();
  final years = [now.year - 2, now.year - 1, now.year];

  return years.map((year) {
    final from = DateTime(year, 1, 1);
    final toExclusive = DateTime(year + 1, 1, 1);
    var income = 0.0;
    var expenses = 0.0;

    for (final item in transactions) {
      if (item.excludeFromGlobalTotals) {
        continue;
      }
      if (!transactionInRange(item, from, toExclusive)) {
        continue;
      }

      final converted = convertTransactionAmount(
        transaction: item,
        targetCurrency: displayCurrency,
        conversion: conversion,
        walletsById: walletsById,
      );

      if (item.isIncome) {
        income += converted;
      } else if (item.isExpense) {
        expenses += converted;
      }
    }

    return YearlyComparison(
      year: year,
      income: income,
      expenses: expenses,
    );
  }).toList();
}

List<AnalyticsChartBar> computeSpendingTrendBars({
  required List<TransactionEntity> transactions,
  required AnalyticsPeriod period,
  required AnalyticsPeriodConfig config,
  required String displayCurrency,
  required CurrencyConversionService conversion,
  Map<String, WalletEntity> walletsById = const {},
}) {
  switch (period) {
    case AnalyticsPeriod.week:
      return _dailyExpenseBars(
        transactions: transactions,
        from: config.fromUtc,
        toExclusive: config.toUtcExclusive,
        displayCurrency: displayCurrency,
        conversion: conversion,
        walletsById: walletsById,
      );
    case AnalyticsPeriod.month:
      return _monthlyWeekExpenseBars(
        transactions: transactions,
        config: config,
        displayCurrency: displayCurrency,
        conversion: conversion,
        walletsById: walletsById,
      );
    case AnalyticsPeriod.year:
      final yearly = computeYearlyComparisonFromTransactions(
        transactions: transactions,
        displayCurrency: displayCurrency,
        conversion: conversion,
        walletsById: walletsById,
      );
      return yearly
          .map(
            (item) => AnalyticsChartBar(
              label: item.year.toString(),
              value: item.expenses,
            ),
          )
          .toList();
  }
}

List<AnalyticsChartBar> _dailyExpenseBars({
  required List<TransactionEntity> transactions,
  required DateTime from,
  required DateTime toExclusive,
  required String displayCurrency,
  required CurrencyConversionService conversion,
  Map<String, WalletEntity> walletsById = const {},
}) {
  final dayCount = toExclusive.difference(from).inDays.clamp(1, 31);
  final totals = List<double>.filled(dayCount, 0);

  for (final item in transactions) {
    if (!item.isExpense) {
      continue;
    }
    if (!transactionInRange(item, from, toExclusive)) {
      continue;
    }

    final dayIndex = transactionLocalDate(item).difference(from).inDays;
    if (dayIndex < 0 || dayIndex >= dayCount) {
      continue;
    }

    totals[dayIndex] += convertTransactionAmount(
      transaction: item,
      targetCurrency: displayCurrency,
      conversion: conversion,
      walletsById: walletsById,
    );
  }

  return List.generate(dayCount, (index) {
    final day = from.add(Duration(days: index));
    return AnalyticsChartBar(
      label: DateFormat('E').format(day),
      value: totals[index],
    );
  });
}

List<AnalyticsChartBar> _monthlyWeekExpenseBars({
  required List<TransactionEntity> transactions,
  required AnalyticsPeriodConfig config,
  required String displayCurrency,
  required CurrencyConversionService conversion,
  Map<String, WalletEntity> walletsById = const {},
}) {
  final daysInMonth = DateTime(config.year, config.month + 1, 0).day;
  final weekCount = ((daysInMonth - 1) ~/ 7) + 1;
  final totals = List<double>.filled(weekCount, 0);

  for (final item in transactions) {
    if (!item.isExpense) {
      continue;
    }
    if (!transactionInRange(item, config.fromUtc, config.toUtcExclusive)) {
      continue;
    }

    final local = transactionLocalDate(item);
    final weekIndex = ((local.day - 1) ~/ 7).clamp(0, weekCount - 1);
    totals[weekIndex] += convertTransactionAmount(
      transaction: item,
      targetCurrency: displayCurrency,
      conversion: conversion,
      walletsById: walletsById,
    );
  }

  return List.generate(
    weekCount,
    (index) => AnalyticsChartBar(
      label: 'W${index + 1}',
      value: totals[index],
    ),
  );
}

List<TopCategoryEntity> computeTopCategoriesFromTransactions({
  required List<TransactionEntity> transactions,
  required String displayCurrency,
  required CurrencyConversionService conversion,
  Map<String, WalletEntity> walletsById = const {},
  DateTime? referenceDate,
  int limit = 5,
}) {
  final now = referenceDate ?? DateTime.now();
  final monthStart = DateTime(now.year, now.month, 1);
  final monthEnd = DateTime(now.year, now.month + 1, 1);

  final totalsByCategory = <String, _CategoryAccumulator>{};
  var totalExpenses = 0.0;

  for (final item in transactions) {
    if (!item.isExpense) {
      continue;
    }
    if (!transactionInRange(item, monthStart, monthEnd)) {
      continue;
    }

    final converted = convertTransactionAmount(
      transaction: item,
      targetCurrency: displayCurrency,
      conversion: conversion,
      walletsById: walletsById,
    );

    totalExpenses += converted;
    final key = item.categoryId;
    final existing = totalsByCategory[key];
    if (existing == null) {
      totalsByCategory[key] = _CategoryAccumulator(
        categoryId: key,
        categoryName: item.categoryName.isNotEmpty ? item.categoryName : 'Other',
        total: converted,
      );
    } else {
      existing.total += converted;
    }
  }

  final sorted = totalsByCategory.values.toList()
    ..sort((a, b) => b.total.compareTo(a.total));

  return sorted.take(limit).map((item) {
    final percentage = totalExpenses <= 0
        ? 0.0
        : (item.total / totalExpenses * 100);
    return TopCategoryEntity(
      categoryId: item.categoryId,
      categoryName: item.categoryName,
      totalAmount: item.total,
      percentage: double.parse(percentage.toStringAsFixed(2)),
    );
  }).toList();
}

class _CategoryAccumulator {
  final String categoryId;
  final String categoryName;
  double total;

  _CategoryAccumulator({
    required this.categoryId,
    required this.categoryName,
    required this.total,
  });
}
