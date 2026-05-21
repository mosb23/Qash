import '../../../../core/network/api_response.dart';
import '../models/auth_response_model.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';
import '../models/verify_phone_request_model.dart';

abstract class AuthRemoteDataSource {
  Future<ApiResponse<AuthResponseModel>> register(RegisterRequestModel request);

  Future<ApiResponse<String>> verifyPhone(VerifyPhoneRequestModel request);

  Future<ApiResponse<AuthResponseModel>> login(LoginRequestModel request);
}
