import '../../../core/currency/currency_conversion_service.dart';
import '../domain/entities/saving_goal.dart';

/// Canonical storage currency for goal amounts.
const String goalBaseCurrency = kBaseCurrency;

/// Goals are stored and displayed in USD only.
String goalDisplayCurrency(SavingGoalEntity goal, {String fallback = kBaseCurrency}) {
  return goalBaseCurrency;
}

/// Converts a user-entered deposit amount into USD before persisting.
double goalAmountToUsd({
  required double amount,
  required String inputCurrency,
  required CurrencyConversionService conversion,
}) {
  return conversion.convertToBase(amount, inputCurrency);
}

double sumGoalsSavedUsd(Iterable<SavingGoalEntity> goals) {
  return goals.fold<double>(0, (sum, g) => sum + g.currentAmount);
}

double sumGoalsTargetUsd(Iterable<SavingGoalEntity> goals) {
  return goals.fold<double>(0, (sum, g) => sum + g.targetAmount);
}
