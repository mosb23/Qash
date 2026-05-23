import '../../../../core/network/api_response.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ApiResponse<ProfileModel>> getProfile();
}
