import '../../../../core/network/api_response.dart';
import '../models/budget_create_request_model.dart';
import '../models/budget_detail_model.dart';
import '../models/budget_status_model.dart';

abstract class BudgetsRemoteDataSource {
  Future<ApiResponse<List<BudgetStatusModel>>> getBudgetStatuses(
    int year,
    int month,
  );

  Future<ApiResponse<BudgetDetailModel>> createBudget(
    BudgetCreateRequestModel request,
  );

  Future<ApiResponse<String>> deleteBudget(String budgetId);
}
