import '../../domain/entities/wallet_create.dart';

class WalletCreateRequestModel {
  final String name;
  final String currency;
  final double initialBalance;

  const WalletCreateRequestModel({
    required this.name,
    required this.currency,
    required this.initialBalance,
  });

  factory WalletCreateRequestModel.fromDomain(WalletCreateData data) {
    return WalletCreateRequestModel(
      name: data.name,
      currency: data.currency,
      initialBalance: data.initialBalance,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'currency': currency,
      'initialBalance': initialBalance,
    };
  }
}
