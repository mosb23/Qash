import '../../../../core/network/api_response.dart';
import '../models/saving_goal_model.dart';

abstract class SavingGoalsRemoteDataSource {
  Future<ApiResponse<List<SavingGoalModel>>> getSavingGoals();
}
