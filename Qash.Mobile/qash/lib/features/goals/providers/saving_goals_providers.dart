import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/providers.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/utils/result.dart';
import '../data/datasources/saving_goals_remote_data_source.dart';
import '../data/repositories/saving_goals_repository_impl.dart';
import '../data/saving_goals_api.dart';
import '../domain/entities/saving_goal.dart';
import '../domain/repositories/saving_goals_repository.dart';
import '../domain/usecases/contribute_to_saving_goal_use_case.dart';
import '../domain/usecases/create_saving_goal_use_case.dart';
import '../domain/usecases/delete_saving_goal_use_case.dart';
import '../domain/usecases/get_saving_goals_use_case.dart';

final savingGoalsRemoteDataSourceProvider =
    Provider<SavingGoalsRemoteDataSource>((ref) {
      return SavingGoalsApi(ref.read(dioProvider));
    });

final savingGoalsRepositoryProvider = Provider<SavingGoalsRepository>((ref) {
  return SavingGoalsRepositoryImpl(
    ref.read(savingGoalsRemoteDataSourceProvider),
  );
});

final getSavingGoalsUseCaseProvider = Provider<GetSavingGoalsUseCase>((ref) {
  return GetSavingGoalsUseCase(ref.read(savingGoalsRepositoryProvider));
});

final createSavingGoalUseCaseProvider = Provider<CreateSavingGoalUseCase>((
  ref,
) {
  return CreateSavingGoalUseCase(ref.read(savingGoalsRepositoryProvider));
});

final contributeToSavingGoalUseCaseProvider =
    Provider<ContributeToSavingGoalUseCase>((ref) {
      return ContributeToSavingGoalUseCase(
        ref.read(savingGoalsRepositoryProvider),
      );
    });

final deleteSavingGoalUseCaseProvider = Provider<DeleteSavingGoalUseCase>((
  ref,
) {
  return DeleteSavingGoalUseCase(ref.read(savingGoalsRepositoryProvider));
});

final savingGoalsProvider = FutureProvider<Result<List<SavingGoalEntity>>>((
  ref,
) async {
  final useCase = ref.read(getSavingGoalsUseCaseProvider);
  return useCase();
});

enum GoalFilter { all, current, expired }

DateTime goalLocalDate(DateTime date) {
  final local = date.isUtc ? date.toLocal() : date;
  return DateTime(local.year, local.month, local.day);
}

bool isGoalExpired(SavingGoalEntity goal) {
  final today = goalLocalDate(DateTime.now());
  return goalLocalDate(goal.deadline).isBefore(today);
}

final goalsFilterProvider = StateProvider<GoalFilter>((ref) {
  return GoalFilter.all;
});

final hasExpiredGoalsProvider = Provider<bool>((ref) {
  final goalsAsync = ref.watch(savingGoalsProvider);

  return goalsAsync.maybeWhen(
    data: (result) {
      if (result.isFailure) {
        return false;
      }
      return (result.data ?? const []).any(isGoalExpired);
    },
    orElse: () => false,
  );
});

final filteredSavingGoalsProvider =
    Provider<AsyncValue<List<SavingGoalEntity>>>((ref) {
      final goalsAsync = ref.watch(savingGoalsProvider);
      final filter = ref.watch(goalsFilterProvider);

      return goalsAsync.when(
        data: (result) {
          if (result.isFailure) {
            return AsyncValue.error(
              result.failure ??
                  const AppFailure(message: 'Failed to load goals.'),
              StackTrace.current,
            );
          }

          var items = List<SavingGoalEntity>.from(result.data ?? const []);
          switch (filter) {
            case GoalFilter.current:
              items = items.where((goal) => !isGoalExpired(goal)).toList();
            case GoalFilter.expired:
              items = items.where(isGoalExpired).toList();
            case GoalFilter.all:
              break;
          }

          return AsyncValue.data(items);
        },
        loading: () => const AsyncValue.loading(),
        error: (error, stack) => AsyncValue.error(error, stack),
      );
    });
