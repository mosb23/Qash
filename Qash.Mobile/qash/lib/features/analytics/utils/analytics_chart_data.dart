import 'package:intl/intl.dart';

import '../../transactions/domain/entities/transaction.dart';
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
      return _weeklyBars(items, now);
    case AnalyticsPeriod.month:
      return _monthlyBars(items, now);
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

List<AnalyticsChartBar> _weeklyBars(
  List<SpendingTrendEntity> items,
  DateTime now,
) {
  final totals = List<double>.filled(4, 0);
  for (final item in items) {
    final local = _toLocal(item.date);
    if (local.year != now.year || local.month != now.month) {
      continue;
    }
    final weekIndex = ((local.day - 1) ~/ 7).clamp(0, 3);
    totals[weekIndex] += item.totalExpenses;
  }

  return List.generate(
    4,
    (index) => AnalyticsChartBar(
      label: 'Week ${index + 1}',
      value: totals[index],
    ),
  );
}

List<AnalyticsChartBar> _monthlyBars(
  List<SpendingTrendEntity> items,
  DateTime now,
) {
  final totals = List<double>.filled(12, 0);
  for (final item in items) {
    final local = _toLocal(item.date);
    if (local.year != now.year) {
      continue;
    }
    totals[local.month - 1] += item.totalExpenses;
  }

  return List.generate(12, (index) {
    final monthDate = DateTime(now.year, index + 1);
    return AnalyticsChartBar(
      label: DateFormat('MMM').format(monthDate),
      value: totals[index],
    );
  });
}

List<AnalyticsComparisonBar> weeklyIncomeExpenseFromTransactions(
  List<TransactionEntity> transactions,
  DateTime now,
) {
  final incomeTotals = List<double>.filled(4, 0);
  final expenseTotals = List<double>.filled(4, 0);

  for (final transaction in transactions) {
    final local = _toLocal(transaction.transactionDate);
    if (local.year != now.year || local.month != now.month) {
      continue;
    }

    final weekIndex = ((local.day - 1) ~/ 7).clamp(0, 3);
    if (transaction.isIncome) {
      incomeTotals[weekIndex] += transaction.amount;
    } else if (transaction.isExpense) {
      expenseTotals[weekIndex] += transaction.amount;
    }
  }

  return List.generate(
    4,
    (index) => AnalyticsComparisonBar(
      label: 'Week ${index + 1}',
      income: incomeTotals[index],
      expenses: expenseTotals[index],
    ),
  );
}

List<AnalyticsComparisonBar> incomeVsExpenseBarsForPeriod({
  required List<IncomeVsExpenseEntity> monthlyItems,
  required List<YearlyComparison> yearlyItems,
  required List<TransactionEntity> weeklyTransactions,
  required AnalyticsPeriod period,
  required DateTime now,
}) {
  switch (period) {
    case AnalyticsPeriod.week:
      return weeklyIncomeExpenseFromTransactions(weeklyTransactions, now);
    case AnalyticsPeriod.month:
      return monthlyItems
          .map(
            (item) => AnalyticsComparisonBar(
              label: DateFormat('MMM').format(DateTime(now.year, item.month)),
              income: item.income,
              expenses: item.expenses,
            ),
          )
          .toList();
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

DateTime _toLocal(DateTime date) => date.isUtc ? date.toLocal() : date;
