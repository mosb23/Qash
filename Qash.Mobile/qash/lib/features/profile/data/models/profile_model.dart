import '../../domain/entities/profile.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.userId,
    required super.firstName,
    required super.lastName,
    required super.fullName,
    required super.email,
    required super.phoneNumber,
    super.preferredCurrency,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: json['userId']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      preferredCurrency: json['preferredCurrency']?.toString() ?? 'USD',
    );
  }
}
