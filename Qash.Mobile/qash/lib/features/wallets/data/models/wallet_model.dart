import '../../domain/entities/wallet.dart';

class WalletModel extends WalletEntity {
  const WalletModel({
    required super.walletId,
    required super.name,
    required super.currency,
    required super.balance,
    required super.userId,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      walletId: json['walletId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      currency: json['currency']?.toString() ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      userId: json['userId']?.toString() ?? '',
    );
  }
}
