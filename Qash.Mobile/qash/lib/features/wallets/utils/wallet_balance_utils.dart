import '../../../core/currency/exchange_rates.dart';
import '../../transactions/domain/entities/transaction.dart';
import '../../transactions/providers/transactions_providers.dart';
import '../../transactions/utils/transaction_wallet_display.dart';
import '../../transactions/utils/transfer_amount_utils.dart';
import '../domain/entities/wallet.dart';

double adjustWalletBalanceForTransfers({
  required WalletEntity wallet,
  required List<TransactionEntity> walletTransactions,
  required Map<String, WalletEntity> walletsById,
  required Map<String, double> exchangeRates,
}) {
  var balance = wallet.balance;

  for (final item in walletTransactions) {
    if (!isIncomingTransferToWallet(item, wallet.walletId)) {
      continue;
    }

    if (!isCrossCurrencyTransferForWallets(item, walletsById)) {
      continue;
    }

    final expectedCredit = resolveTransferCreditAmount(
      item,
      walletsById: walletsById,
      exchangeRates: exchangeRates,
    );
    final recordedCredit = item.toAmount ?? item.amount;
    final delta = expectedCredit - recordedCredit;
    if (delta.abs() >= 0.01) {
      balance += delta;
    }
  }

  return balance;
}

double displayWalletBalance({
  required WalletEntity wallet,
  required List<TransactionEntity> allTransactions,
  required Map<String, WalletEntity> walletsById,
  required Map<String, double> exchangeRates,
}) {
  final walletTransactions = allTransactions
      .where((item) => transactionInvolvesWallet(item, wallet.walletId))
      .toList();

  return adjustWalletBalanceForTransfers(
    wallet: wallet,
    walletTransactions: walletTransactions,
    walletsById: walletsById,
    exchangeRates: exchangeRates,
  );
}

Map<String, WalletEntity> walletsByIdMap(List<WalletEntity> wallets) {
  return {
    for (final wallet in wallets)
      normalizeTransactionId(wallet.walletId): wallet,
  };
}

WalletEntity? findWalletById(
  List<WalletEntity> wallets,
  String walletId,
) {
  final target = normalizeTransactionId(walletId);
  for (final wallet in wallets) {
    if (normalizeTransactionId(wallet.walletId) == target) {
      return wallet;
    }
  }
  return null;
}

WalletEntity resolveLiveWallet({
  required WalletEntity fallback,
  required List<WalletEntity> wallets,
}) {
  return findWalletById(wallets, fallback.walletId) ?? fallback;
}

Map<String, double> defaultRatesOr(Map<String, double>? rates) {
  return rates ?? defaultExchangeRates;
}
