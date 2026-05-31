import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/providers.dart';
import '../../../core/currency/currency_aggregation.dart';
import '../../../core/currency/currency_providers.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/utils/result.dart';
import '../../transactions/domain/entities/transaction.dart';
import '../../transactions/providers/transactions_providers.dart';
import '../../wallets/domain/entities/wallet.dart';
import '../../wallets/providers/wallets_providers.dart';
import '../../wallets/utils/wallet_balance_utils.dart';
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
import '../utils/analytics_chart_data.dart';
import '../utils/analytics_transaction_aggregation.dart';

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

class YearlyComparison {
  final int year;
  final double income;
  final double expenses;

  const YearlyComparison({
    required this.year,
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
    return AnalyticsPeriodConfig(
      year: now.year,
      month: now.month,
      days: end.difference(start).inDays,
      fromUtc: start,
      toUtcExclusive: end,
    );
  }

  final start = DateTime(now.year, now.month, 1);
  final end = DateTime(now.year, now.month + 1, 1);
  return AnalyticsPeriodConfig(
    year: now.year,
    month: now.month,
    days: end.difference(start).inDays,
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

final yearlyComparisonProvider =
    FutureProvider<Result<List<YearlyComparison>>>((ref) async {
      final now = DateTime.now();
      final useCase = ref.read(getDateRangeSummaryUseCaseProvider);
      final years = [now.year - 2, now.year - 1, now.year];
      final comparisons = <YearlyComparison>[];

      for (final year in years) {
        final from = DateTime(year, 1, 1);
        final to = DateTime(year + 1, 1, 1);
        final result = await useCase(from, to);
        if (result.isFailure) {
          return Result.failure(
            result.failure ??
                const AppFailure(message: 'Failed to load yearly comparison.'),
          );
        }

        final data = result.data;
        comparisons.add(
          YearlyComparison(
            year: year,
            income: data?.totalIncome ?? 0,
            expenses: data?.totalExpenses ?? 0,
          ),
        );
      }

      return Result.success(comparisons);
    });

final analyticsSummaryProvider = Provider<AsyncValue<AnalyticsSummary>>((ref) {
  final config = ref.watch(analyticsPeriodConfigProvider);
  final transactionsAsync = ref.watch(transactionsProvider);
  final walletsAsync = ref.watch(walletsProvider);
  final conversion = ref.watch(currencyConversionServiceProvider);
  final displayCurrency = ref.watch(effectiveDisplayCurrencyProvider);

  return transactionsAsync.whenData((result) {
    if (result.isFailure) {
      throw result.failure ??
          const AppFailure(message: 'Failed to load summary.');
    }

    final walletsById = walletsAsync.maybeWhen(
      data: (walletResult) {
        if (walletResult.isFailure) {
          return const <String, WalletEntity>{};
        }
        return walletsByIdMap(walletResult.data ?? const []);
      },
      orElse: () => const <String, WalletEntity>{},
    );

    var income = 0.0;
    var expenses = 0.0;

    for (final item in result.data ?? const <TransactionEntity>[]) {
      final local = item.transactionDate.isUtc
          ? item.transactionDate.toLocal()
          : item.transactionDate;
      final date = DateTime(local.year, local.month, local.day);
      if (date.isBefore(config.fromUtc) || !date.isBefore(config.toUtcExclusive)) {
        continue;
      }

      final converted = convertTransactionAmount(
        transaction: item,
        targetCurrency: displayCurrency,
        conversion: conversion,
        walletsById: walletsById,
      );

      if (item.isTransfer) {
        expenses += converted;
      } else if (item.isIncome) {
        income += converted;
      } else if (item.isExpense) {
        expenses += converted;
      }
    }

    return AnalyticsSummary(
      totalIncome: income,
      totalExpenses: expenses,
      netBalance: income - expenses,
    );
  });
});

final clientCategoryBreakdownProvider =
    Provider<AsyncValue<Result<List<CategoryBreakdownEntity>>>>((ref) {
      final period = ref.watch(analyticsPeriodProvider);
      if (period != AnalyticsPeriod.month) {
        return AsyncValue.data(Result.success(const []));
      }

      final config = ref.watch(analyticsPeriodConfigProvider);
      final transactionsAsync = ref.watch(transactionsProvider);
      final walletsAsync = ref.watch(walletsProvider);
      final conversion = ref.watch(currencyConversionServiceProvider);
      final displayCurrency = ref.watch(effectiveDisplayCurrencyProvider);

      return transactionsAsync.when(
        data: (result) {
          if (result.isFailure) {
            return AsyncValue.data(Result.failure(result.failure!));
          }

          final walletsById = walletsAsync.maybeWhen(
            data: (walletResult) {
              if (walletResult.isFailure) {
                return const <String, WalletEntity>{};
              }
              return walletsByIdMap(walletResult.data ?? const []);
            },
            orElse: () => const <String, WalletEntity>{},
          );

          final totals = <String, double>{};
          for (final item in result.data ?? const <TransactionEntity>[]) {
            if (!item.isExpense || item.isTransfer || item.isTransferLinked) {
              continue;
            }

            final local = item.transactionDate.isUtc
                ? item.transactionDate.toLocal()
                : item.transactionDate;
            final date = DateTime(local.year, local.month, local.day);
            if (date.isBefore(config.fromUtc) ||
                !date.isBefore(config.toUtcExclusive)) {
              continue;
            }

            final converted = convertTransactionAmount(
              transaction: item,
              targetCurrency: displayCurrency,
              conversion: conversion,
              walletsById: walletsById,
            );
            totals[item.categoryId] =
                (totals[item.categoryId] ?? 0) + converted;
          }

          final items = totals.entries
              .map(
                (entry) => CategoryBreakdownEntity(
                  categoryId: entry.key,
                  totalAmount: entry.value,
                ),
              )
              .toList()
            ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

          return AsyncValue.data(Result.success(items));
        },
        loading: () => const AsyncValue.loading(),
        error: (error, stack) => AsyncValue.error(error, stack),
      );
    });

/// Yearly income/expense from transactions with wallet-aware conversion.
final clientYearlyComparisonProvider =
    Provider<AsyncValue<List<YearlyComparison>>>((ref) {
      final transactionsAsync = ref.watch(transactionsProvider);
      final walletsAsync = ref.watch(walletsProvider);
      final conversion = ref.watch(currencyConversionServiceProvider);
      final displayCurrency = ref.watch(effectiveDisplayCurrencyProvider);

      return transactionsAsync.when(
        data: (result) {
          if (result.isFailure) {
            return AsyncValue.error(
              result.failure ??
                  const AppFailure(message: 'Failed to load transactions.'),
              StackTrace.current,
            );
          }

          final walletsById = walletsAsync.maybeWhen(
            data: (walletResult) {
              if (walletResult.isFailure) {
                return const <String, WalletEntity>{};
              }
              return walletsByIdMap(walletResult.data ?? const []);
            },
            orElse: () => const <String, WalletEntity>{},
          );

          return AsyncValue.data(
            computeYearlyComparisonFromTransactions(
              transactions: result.data ?? const [],
              displayCurrency: displayCurrency,
              conversion: conversion,
              walletsById: walletsById,
            ),
          );
        },
        loading: () => const AsyncValue.loading(),
        error: (error, stack) => AsyncValue.error(error, stack),
      );
    });

/// Spending trend bars computed client-side (week / month / year).
final clientSpendingTrendBarsProvider =
    Provider<AsyncValue<List<AnalyticsChartBar>>>((ref) {
      final period = ref.watch(analyticsPeriodProvider);
      final config = ref.watch(analyticsPeriodConfigProvider);
      final transactionsAsync = ref.watch(transactionsProvider);
      final walletsAsync = ref.watch(walletsProvider);
      final conversion = ref.watch(currencyConversionServiceProvider);
      final displayCurrency = ref.watch(effectiveDisplayCurrencyProvider);

      return transactionsAsync.when(
        data: (result) {
          if (result.isFailure) {
            return AsyncValue.error(
              result.failure ??
                  const AppFailure(message: 'Failed to load transactions.'),
              StackTrace.current,
            );
          }

          final walletsById = walletsAsync.maybeWhen(
            data: (walletResult) {
              if (walletResult.isFailure) {
                return const <String, WalletEntity>{};
              }
              return walletsByIdMap(walletResult.data ?? const []);
            },
            orElse: () => const <String, WalletEntity>{},
          );

          return AsyncValue.data(
            computeSpendingTrendBars(
              transactions: result.data ?? const [],
              period: period,
              config: config,
              displayCurrency: displayCurrency,
              conversion: conversion,
              walletsById: walletsById,
            ),
          );
        },
        loading: () => const AsyncValue.loading(),
        error: (error, stack) => AsyncValue.error(error, stack),
      );
    });
