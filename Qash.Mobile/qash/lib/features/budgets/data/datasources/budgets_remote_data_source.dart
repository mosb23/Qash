import '../../../../core/network/api_response.dart';
import '../models/budget_create_request_model.dart';
import '../models/budget_status_model.dart';
import '../models/budget_update_request_model.dart';

abstract class BudgetsRemoteDataSource {
  Future<ApiResponse<List<BudgetStatusModel>>> getBudgetStatuses(
    int year,
    int month,
  );

  Future<ApiResponse<BudgetStatusModel>> getBudgetById(String budgetId);

  Future<ApiResponse<String>> createBudget(BudgetCreateRequestModel request);

  Future<ApiResponse<String>> updateBudget(
    String budgetId,
    BudgetUpdateRequestModel request,
  );

  Future<ApiResponse<String>> deleteBudget(String budgetId);
}
