import '../../../../core/network/api_response.dart';
import '../models/delete_profile_request_model.dart';
import '../models/profile_model.dart';
import '../models/profile_update_request_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ApiResponse<ProfileModel>> getProfile();

  Future<ApiResponse<ProfileModel>> updateProfile(
    ProfileUpdateRequestModel request,
  );

  Future<ApiResponse<String>> deleteProfile(DeleteProfileRequestModel request);
}
