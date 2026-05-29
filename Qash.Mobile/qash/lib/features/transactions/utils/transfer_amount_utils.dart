import '../../../../core/currency/exchange_rates.dart';
import '../../wallets/domain/entities/wallet.dart';
import '../domain/entities/transaction.dart';
import '../providers/transactions_providers.dart';

String resolveWalletCurrency({
  required String walletId,
  String? transactionCurrency,
  required Map<String, WalletEntity> walletsById,
  String fallback = 'USD',
}) {
  if (transactionCurrency != null && transactionCurrency.trim().isNotEmpty) {
    return transactionCurrency.trim().toUpperCase();
  }

  final wallet = walletsById[normalizeTransactionId(walletId)];
  if (wallet != null && wallet.currency.trim().isNotEmpty) {
    return wallet.currency.trim().toUpperCase();
  }

  return fallback.toUpperCase();
}

bool isCrossCurrencyTransferForWallets(
  TransactionEntity item,
  Map<String, WalletEntity> walletsById,
) {
  if (!item.isTransfer || item.toWalletId == null) {
    return false;
  }

  final sourceCurrency = resolveWalletCurrency(
    walletId: item.walletId,
    transactionCurrency:
        item.walletCurrency.isNotEmpty ? item.walletCurrency : null,
    walletsById: walletsById,
  );
  final targetCurrency = resolveWalletCurrency(
    walletId: item.toWalletId!,
    transactionCurrency: item.toWalletCurrency,
    walletsById: walletsById,
  );

  return sourceCurrency != targetCurrency;
}

double resolveTransferCreditAmount(
  TransactionEntity item, {
  required Map<String, WalletEntity> walletsById,
  Map<String, double>? exchangeRates,
}) {
  final destinationId = item.toWalletId;
  if (destinationId == null || destinationId.isEmpty) {
    return item.toAmount ?? item.amount;
  }

  final sourceCurrency = resolveWalletCurrency(
    walletId: item.walletId,
    transactionCurrency:
        item.walletCurrency.isNotEmpty ? item.walletCurrency : null,
    walletsById: walletsById,
  );
  final targetCurrency = resolveWalletCurrency(
    walletId: destinationId,
    transactionCurrency: item.toWalletCurrency,
    walletsById: walletsById,
  );

  if (sourceCurrency == targetCurrency) {
    return item.toAmount ?? item.amount;
  }

  final converted = convertCurrencyAmount(
    amount: item.amount,
    fromCurrency: sourceCurrency,
    toCurrency: targetCurrency,
    rates: exchangeRates ?? defaultExchangeRates,
  );

  if (item.toAmount != null &&
      (item.toAmount! - item.amount).abs() >= 0.01) {
    return item.toAmount!;
  }

  return converted;
}

double resolveTransferDebitAmount(
  TransactionEntity item, {
  required Map<String, WalletEntity> walletsById,
}) {
  return item.amount;
}
