import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../config/providers.dart';
import '../../transactions/domain/entities/transaction.dart';
import '../../transactions/providers/transactions_providers.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/utils/result.dart';
import '../data/analytics_api.dart';
import '../data/datasources/analytics_remote_data_source.dart';
import '../data/repositories/analytics_repository_impl.dart';
import '../domain/entities/category_breakdown.dart';
import '../domain/entities/date_range_summary.dart';
import '../domain/entities/income_vs_expense.dart';
import '../domain/entities/monthly_summary.dart';
import '../domain/entities/spending_trend.dart';
import '../domain/repositories/analytics_repository.dart';
import '../domain/usecases/get_category_breakdown_use_case.dart';
import '../domain/usecases/get_date_range_summary_use_case.dart';
import '../domain/usecases/get_income_vs_expense_use_case.dart';
import '../domain/usecases/get_monthly_summary_use_case.dart';
import '../domain/usecases/get_spending_trend_use_case.dart';

enum AnalyticsPeriod { week, month, year }

class AnalyticsSummary {
  final double totalIncome;
  final double totalExpenses;
  final double netBalance;

  const AnalyticsSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.netBalance,
  });
}

class PeriodComparisonPoint {
  final String label;
  final double income;
  final double expenses;

  const PeriodComparisonPoint({
    required this.label,
    required this.income,
    required this.expenses,
  });
}

class AnalyticsPeriodConfig {
  final int year;
  final int month;
  final int days;
  final DateTime fromUtc;
  final DateTime toUtcExclusive;

  const AnalyticsPeriodConfig({
    required this.year,
    required this.month,
    required this.days,
    required this.fromUtc,
    required this.toUtcExclusive,
  });
}

final analyticsPeriodProvider = StateProvider<AnalyticsPeriod>((ref) {
  return AnalyticsPeriod.month;
});

final analyticsPeriodConfigProvider = Provider<AnalyticsPeriodConfig>((ref) {
  final period = ref.watch(analyticsPeriodProvider);
  final now = DateTime.now();

  DateTime startOfDay(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  if (period == AnalyticsPeriod.week) {
    final end = startOfDay(now).add(const Duration(days: 1));
    final start = end.subtract(const Duration(days: 7));
    return AnalyticsPeriodConfig(
      year: now.year,
      month: now.month,
      days: 7,
      fromUtc: start,
      toUtcExclusive: end,
    );
  }

  if (period == AnalyticsPeriod.year) {
    final start = DateTime(now.year, 1, 1);
    final end = DateTime(now.year + 1, 1, 1);
    final days = end.difference(start).inDays;
    return AnalyticsPeriodConfig(
      year: now.year,
      month: now.month,
      days: days,
      fromUtc: start,
      toUtcExclusive: end,
    );
  }

  final start = DateTime(now.year, now.month, 1);
  final end = DateTime(now.year, now.month + 1, 1);
  final days = end.difference(start).inDays;
  return AnalyticsPeriodConfig(
    year: now.year,
    month: now.month,
    days: days,
    fromUtc: start,
    toUtcExclusive: end,
  );
});

final analyticsRemoteDataSourceProvider = Provider<AnalyticsRemoteDataSource>((
  ref,
) {
  return AnalyticsApi(ref.read(dioProvider));
});

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepositoryImpl(ref.read(analyticsRemoteDataSourceProvider));
});

final getMonthlySummaryUseCaseProvider = Provider<GetMonthlySummaryUseCase>((
  ref,
) {
  return GetMonthlySummaryUseCase(ref.read(analyticsRepositoryProvider));
});

final getCategoryBreakdownUseCaseProvider =
    Provider<GetCategoryBreakdownUseCase>((ref) {
      return GetCategoryBreakdownUseCase(ref.read(analyticsRepositoryProvider));
    });

final getIncomeVsExpenseUseCaseProvider = Provider<GetIncomeVsExpenseUseCase>((
  ref,
) {
  return GetIncomeVsExpenseUseCase(ref.read(analyticsRepositoryProvider));
});

final getSpendingTrendUseCaseProvider = Provider<GetSpendingTrendUseCase>((
  ref,
) {
  return GetSpendingTrendUseCase(ref.read(analyticsRepositoryProvider));
});

final getDateRangeSummaryUseCaseProvider = Provider<GetDateRangeSummaryUseCase>(
  (ref) {
    return GetDateRangeSummaryUseCase(ref.read(analyticsRepositoryProvider));
  },
);

final monthlySummaryProvider = FutureProvider<Result<MonthlySummaryEntity>>((
  ref,
) async {
  final config = ref.watch(analyticsPeriodConfigProvider);
  final useCase = ref.read(getMonthlySummaryUseCaseProvider);
  return useCase(config.year, config.month);
});

final categoryBreakdownProvider =
    FutureProvider<Result<List<CategoryBreakdownEntity>>>((ref) async {
      final config = ref.watch(analyticsPeriodConfigProvider);
      final useCase = ref.read(getCategoryBreakdownUseCaseProvider);
      return useCase(config.year, config.month);
    });

final incomeVsExpenseProvider =
    FutureProvider<Result<List<IncomeVsExpenseEntity>>>((ref) async {
      final config = ref.watch(analyticsPeriodConfigProvider);
      final useCase = ref.read(getIncomeVsExpenseUseCaseProvider);
      return useCase(config.year);
    });

final spendingTrendProvider = FutureProvider<Result<List<SpendingTrendEntity>>>(
  (ref) async {
    final config = ref.watch(analyticsPeriodConfigProvider);
    final useCase = ref.read(getSpendingTrendUseCaseProvider);
    return useCase(config.days);
  },
);

final dateRangeSummaryProvider = FutureProvider<Result<DateRangeSummaryEntity>>(
  (ref) async {
    final config = ref.watch(analyticsPeriodConfigProvider);
    final useCase = ref.read(getDateRangeSummaryUseCaseProvider);
    return useCase(config.fromUtc, config.toUtcExclusive);
  },
);

bool _isInRange(DateTime date, DateTime from, DateTime toExclusive) {
  final day = DateTime(date.year, date.month, date.day);
  return !day.isBefore(from) && day.isBefore(toExclusive);
}

List<CategoryBreakdownEntity> _breakdownFromTransactions(
  List<TransactionEntity> transactions,
  DateTime from,
  DateTime toExclusive,
) {
  final totals = <String, double>{};
  for (final tx in transactions) {
    if (!tx.isExpense || tx.isTransfer) continue;
    final date = tx.transactionDate;
    if (!_isInRange(date, from, toExclusive)) continue;
    final key = tx.categoryId.isNotEmpty ? tx.categoryId : tx.categoryName;
    if (key.isEmpty) continue;
    totals[key] = (totals[key] ?? 0) + tx.amount;
  }

  final items = totals.entries
      .map(
        (entry) => CategoryBreakdownEntity(
          categoryId: entry.key,
          totalAmount: entry.value,
        ),
      )
      .toList();
  items.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
  return items;
}

List<PeriodComparisonPoint> _comparisonFromTransactions(
  List<TransactionEntity> transactions,
  DateTime from,
  DateTime toExclusive,
) {
  final incomeByDay = <DateTime, double>{};
  final expenseByDay = <DateTime, double>{};

  for (final tx in transactions) {
    if (tx.isTransfer) continue;
    final day = DateTime(
      tx.transactionDate.year,
      tx.transactionDate.month,
      tx.transactionDate.day,
    );
    if (!_isInRange(day, from, toExclusive)) continue;

    if (tx.isIncome) {
      incomeByDay[day] = (incomeByDay[day] ?? 0) + tx.amount;
    } else if (tx.isExpense) {
      expenseByDay[day] = (expenseByDay[day] ?? 0) + tx.amount;
    }
  }

  final points = <PeriodComparisonPoint>[];
  for (
    var day = from;
    day.isBefore(toExclusive);
    day = day.add(const Duration(days: 1))
  ) {
    points.add(
      PeriodComparisonPoint(
        label: DateFormat('EEE').format(day),
        income: incomeByDay[day] ?? 0,
        expenses: expenseByDay[day] ?? 0,
      ),
    );
  }
  return points;
}

final periodCategoryBreakdownProvider =
    FutureProvider<Result<List<CategoryBreakdownEntity>>>((ref) async {
      final period = ref.watch(analyticsPeriodProvider);
      final config = ref.watch(analyticsPeriodConfigProvider);

      if (period == AnalyticsPeriod.month) {
        return ref.watch(categoryBreakdownProvider.future);
      }

      final transactionsResult = await ref.watch(transactionsProvider.future);
      if (transactionsResult.isFailure) {
        return Result.failure(
          transactionsResult.failure ??
              const AppFailure(message: 'Failed to load transactions.'),
        );
      }

      final transactions = transactionsResult.data ?? const [];
      final from = DateTime(
        config.fromUtc.year,
        config.fromUtc.month,
        config.fromUtc.day,
      );
      final toExclusive = DateTime(
        config.toUtcExclusive.year,
        config.toUtcExclusive.month,
        config.toUtcExclusive.day,
      );

      return Result.success(
        _breakdownFromTransactions(transactions, from, toExclusive),
      );
    });

final periodComparisonProvider =
    FutureProvider<Result<List<PeriodComparisonPoint>>>((ref) async {
      final period = ref.watch(analyticsPeriodProvider);
      final config = ref.watch(analyticsPeriodConfigProvider);

      if (period == AnalyticsPeriod.year) {
        final result = await ref.watch(incomeVsExpenseProvider.future);
        if (result.isFailure) {
          return Result.failure(
            result.failure ??
                const AppFailure(message: 'Failed to load comparison.'),
          );
        }
        final items = result.data ?? const [];
        return Result.success(
          items
              .map(
                (item) => PeriodComparisonPoint(
                  label: DateFormat('MMM').format(
                    DateTime(config.year, item.month),
                  ),
                  income: item.income,
                  expenses: item.expenses,
                ),
              )
              .toList(),
        );
      }

      if (period == AnalyticsPeriod.week) {
        final transactionsResult = await ref.watch(transactionsProvider.future);
        if (transactionsResult.isFailure) {
          return Result.failure(
            transactionsResult.failure ??
                const AppFailure(message: 'Failed to load transactions.'),
          );
        }
        final transactions = transactionsResult.data ?? const [];
        final from = DateTime(
          config.fromUtc.year,
          config.fromUtc.month,
          config.fromUtc.day,
        );
        final toExclusive = DateTime(
          config.toUtcExclusive.year,
          config.toUtcExclusive.month,
          config.toUtcExclusive.day,
        );
        return Result.success(
          _comparisonFromTransactions(transactions, from, toExclusive),
        );
      }

      return Result.success([]);
    });

final analyticsSummaryProvider = Provider<AsyncValue<AnalyticsSummary>>((ref) {
  final period = ref.watch(analyticsPeriodProvider);

  if (period == AnalyticsPeriod.month) {
    final monthly = ref.watch(monthlySummaryProvider);
    return monthly.whenData((result) {
      if (result.isFailure) {
        throw result.failure ??
            const AppFailure(message: 'Failed to load summary.');
      }
      final data =
          result.data ??
          const MonthlySummaryEntity(
            totalIncome: 0,
            totalExpenses: 0,
            netBalance: 0,
            transactionCount: 0,
          );
      return AnalyticsSummary(
        totalIncome: data.totalIncome,
        totalExpenses: data.totalExpenses,
        netBalance: data.netBalance,
      );
    });
  }

  final range = ref.watch(dateRangeSummaryProvider);
  return range.whenData((result) {
    if (result.isFailure) {
      throw result.failure ??
          const AppFailure(message: 'Failed to load summary.');
    }
    final data =
        result.data ??
        DateRangeSummaryEntity(
          fromUtc: DateTime.now(),
          toUtcExclusive: DateTime.now(),
          totalIncome: 0,
          totalExpenses: 0,
          net: 0,
          transactionCount: 0,
        );
    return AnalyticsSummary(
      totalIncome: data.totalIncome,
      totalExpenses: data.totalExpenses,
      netBalance: data.net,
    );
  });
});
