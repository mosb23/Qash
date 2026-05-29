import '../../../../core/network/api_response.dart';
import '../models/auth_response_model.dart';
import '../models/change_password_request_model.dart';
import '../models/forgot_password_code_request_model.dart';
import '../models/forgot_password_code_response_model.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';
import '../models/reset_forgot_password_request_model.dart';
import '../models/verify_phone_request_model.dart';

abstract class AuthRemoteDataSource {
  Future<ApiResponse<AuthResponseModel>> register(RegisterRequestModel request);

  Future<ApiResponse<AuthResponseModel>> verifyPhone(
    VerifyPhoneRequestModel request,
  );

  Future<ApiResponse<AuthResponseModel>> login(LoginRequestModel request);

  Future<ApiResponse<ForgotPasswordCodeResponseModel>>
  requestForgotPasswordCode(ForgotPasswordCodeRequestModel request);

  Future<ApiResponse<String>> resetForgotPassword(
    ResetForgotPasswordRequestModel request,
  );

  Future<ApiResponse<String>> changePassword(
    ChangePasswordRequestModel request,
  );
}
