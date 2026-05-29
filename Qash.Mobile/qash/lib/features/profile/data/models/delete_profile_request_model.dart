class DeleteProfileRequestModel {
  final String password;

  const DeleteProfileRequestModel({required this.password});

  Map<String, dynamic> toJson() => {'password': password};
}
