import '../../domain/entities/profile_update.dart';

class ProfileUpdateRequestModel {
  final String firstName;
  final String lastName;
  final String email;

  const ProfileUpdateRequestModel({
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory ProfileUpdateRequestModel.fromDomain(ProfileUpdateData data) {
    return ProfileUpdateRequestModel(
      firstName: data.firstName,
      lastName: data.lastName,
      email: data.email,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
    };
  }
}
