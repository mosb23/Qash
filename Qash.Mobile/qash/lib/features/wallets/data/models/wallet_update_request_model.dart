import '../../domain/entities/wallet_update.dart';

class WalletUpdateRequestModel {
  final String name;
  final String currency;
  final double balance;

  const WalletUpdateRequestModel({
    required this.name,
    required this.currency,
    required this.balance,
  });

  factory WalletUpdateRequestModel.fromDomain(WalletUpdateData data) {
    return WalletUpdateRequestModel(
      name: data.name,
      currency: data.currency,
      balance: data.balance,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'currency': currency,
      'balance': balance,
    };
  }
}
