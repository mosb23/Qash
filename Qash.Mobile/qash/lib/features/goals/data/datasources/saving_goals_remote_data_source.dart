import '../../../../core/network/api_response.dart';
import '../models/saving_goal_create_request_model.dart';
import '../models/saving_goal_contribution_request_model.dart';
import '../models/saving_goal_model.dart';

abstract class SavingGoalsRemoteDataSource {
  Future<ApiResponse<List<SavingGoalModel>>> getSavingGoals();

  Future<ApiResponse<SavingGoalModel>> createSavingGoal(
    SavingGoalCreateRequestModel request,
  );

  Future<ApiResponse<SavingGoalModel>> contributeToSavingGoal(
    String savingGoalId,
    SavingGoalContributionRequestModel request,
  );

  Future<ApiResponse<String>> deleteSavingGoal(String savingGoalId);
}
