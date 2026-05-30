import '../domain/entities/saving_goal.dart';
import '../providers/saving_goals_providers.dart';

/// Calendar days from today (local) until [deadline], inclusive of deadline day.
/// Returns 0 when the deadline date is before today.
int goalDaysLeft(DateTime deadline) {
  final today = goalLocalDate(DateTime.now());
  final target = goalLocalDate(deadline);
  final diff = target.difference(today).inDays;
  return diff < 0 ? 0 : diff;
}

/// Calendar days since [deadline] when it is before today.
int goalDaysOverdue(DateTime deadline) {
  final today = goalLocalDate(DateTime.now());
  final target = goalLocalDate(deadline);
  final diff = today.difference(target).inDays;
  return diff < 0 ? 0 : diff;
}

String goalDeadlineLabel(SavingGoalEntity goal) {
  if (isGoalExpired(goal)) {
    final daysOverdue = goalDaysOverdue(goal.deadline);
    if (daysOverdue == 0) {
      return 'Expired today';
    }
    if (daysOverdue == 1) {
      return 'Expired 1 day ago';
    }
    return 'Expired $daysOverdue days ago';
  }

  final daysLeft = goalDaysLeft(goal.deadline);
  if (daysLeft == 0) {
    return 'Due today';
  }
  if (daysLeft == 1) {
    return '1 day left';
  }
  return '$daysLeft days left';
}
