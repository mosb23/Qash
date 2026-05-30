import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/analytics/providers/analytics_providers.dart';
import '../../features/budgets/providers/budgets_providers.dart';
import '../../features/categories/providers/categories_providers.dart';
import '../../features/dashboard/providers/dashboard_providers.dart';
import '../../features/goals/providers/saving_goals_providers.dart';
import '../../features/profile/providers/profile_providers.dart';
import '../../features/transactions/providers/transactions_providers.dart';
import '../../features/wallets/providers/wallets_providers.dart';

void invalidateTransactionRelatedData(WidgetRef ref, {String? transactionId}) {
  ref.invalidate(transactionsProvider);
  ref.invalidate(walletsProvider);
  ref.invalidate(dashboardProvider);
  ref.invalidate(budgetStatusesProvider);
  ref.invalidate(monthlySummaryProvider);
  ref.invalidate(categoryBreakdownProvider);
  ref.invalidate(incomeVsExpenseProvider);
  ref.invalidate(spendingTrendProvider);
  ref.invalidate(dateRangeSummaryProvider);
  ref.invalidate(yearlyComparisonProvider);

  if (transactionId != null && transactionId.isNotEmpty) {
    ref.invalidate(transactionDetailProvider(transactionId));
  }
}

void invalidateUserSessionData(WidgetRef ref) {
  ref.invalidate(profileProvider);
  ref.invalidate(dashboardProvider);
  ref.invalidate(walletsProvider);
  ref.invalidate(budgetStatusesProvider);
  ref.invalidate(savingGoalsProvider);
  ref.invalidate(transactionsProvider);
  ref.invalidate(transactionDetailProvider);
  ref.invalidate(categoriesProvider);
  ref.invalidate(exchangeRatesProvider);

  ref.invalidate(monthlySummaryProvider);
  ref.invalidate(categoryBreakdownProvider);
  ref.invalidate(incomeVsExpenseProvider);
  ref.invalidate(spendingTrendProvider);
  ref.invalidate(dateRangeSummaryProvider);
  ref.invalidate(yearlyComparisonProvider);

  ref.invalidate(transactionsFilterProvider);
  ref.invalidate(transactionListOptionsProvider);
  ref.invalidate(goalsFilterProvider);
  ref.invalidate(budgetsFilterProvider);
  ref.invalidate(analyticsPeriodProvider);
}
