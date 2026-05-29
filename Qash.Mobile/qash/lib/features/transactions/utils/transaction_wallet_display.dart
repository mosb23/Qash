import '../../wallets/domain/entities/wallet.dart';
import '../domain/entities/transaction.dart';
import '../providers/transactions_providers.dart';
import 'transfer_amount_utils.dart';

class WalletTransactionDisplay {
  const WalletTransactionDisplay({
    required this.amount,
    required this.sign,
    required this.currencyCode,
    required this.isIncomingTransfer,
  });

  final double amount;
  final String sign;
  final String currencyCode;
  final bool isIncomingTransfer;
}

bool transactionInvolvesWallet(TransactionEntity item, String walletId) {
  return matchesWalletFilter(item, walletId);
}

bool isIncomingTransferToWallet(TransactionEntity item, String walletId) {
  if (!item.isTransfer || item.toWalletId == null) {
    return false;
  }

  return normalizeTransactionId(item.toWalletId!) ==
          normalizeTransactionId(walletId) &&
      normalizeTransactionId(item.walletId) != normalizeTransactionId(walletId);
}

bool isOutgoingTransferFromWallet(TransactionEntity item, String walletId) {
  if (!item.isTransfer) {
    return false;
  }

  return normalizeTransactionId(item.walletId) ==
      normalizeTransactionId(walletId);
}

WalletTransactionDisplay walletTransactionDisplay(
  TransactionEntity item, {
  String? walletId,
  String fallbackCurrency = 'USD',
  Map<String, WalletEntity>? walletsById,
  Map<String, double>? exchangeRates,
}) {
  final wallets = walletsById ?? const <String, WalletEntity>{};

  if (item.isTransfer &&
      walletId != null &&
      isIncomingTransferToWallet(item, walletId)) {
    final currencyCode = resolveWalletCurrency(
      walletId: walletId,
      transactionCurrency: item.toWalletCurrency,
      walletsById: wallets,
      fallback: fallbackCurrency,
    );

    return WalletTransactionDisplay(
      amount: resolveTransferCreditAmount(
        item,
        walletsById: wallets,
        exchangeRates: exchangeRates,
      ),
      sign: '+',
      currencyCode: currencyCode,
      isIncomingTransfer: true,
    );
  }

  if (item.isTransfer &&
      walletId != null &&
      isOutgoingTransferFromWallet(item, walletId)) {
    return WalletTransactionDisplay(
      amount: resolveTransferDebitAmount(item, walletsById: wallets),
      sign: '-',
      currencyCode: resolveWalletCurrency(
        walletId: item.walletId,
        transactionCurrency:
            item.walletCurrency.isNotEmpty ? item.walletCurrency : null,
        walletsById: wallets,
        fallback: fallbackCurrency,
      ),
      isIncomingTransfer: false,
    );
  }

  if (item.isTransfer) {
    final sourceCurrency = resolveWalletCurrency(
      walletId: item.walletId,
      transactionCurrency:
          item.walletCurrency.isNotEmpty ? item.walletCurrency : null,
      walletsById: wallets,
      fallback: fallbackCurrency,
    );

    if (isCrossCurrencyTransferForWallets(item, wallets)) {
      final destinationId = item.toWalletId;
      final targetCurrency = destinationId == null
          ? sourceCurrency
          : resolveWalletCurrency(
              walletId: destinationId,
              transactionCurrency: item.toWalletCurrency,
              walletsById: wallets,
              fallback: fallbackCurrency,
            );

      return WalletTransactionDisplay(
        amount: resolveTransferCreditAmount(
          item,
          walletsById: wallets,
          exchangeRates: exchangeRates,
        ),
        sign: '+',
        currencyCode: targetCurrency,
        isIncomingTransfer: false,
      );
    }

    return WalletTransactionDisplay(
      amount: item.amount,
      sign: '',
      currencyCode: sourceCurrency,
      isIncomingTransfer: false,
    );
  }

  final currency = resolveWalletCurrency(
    walletId: item.walletId,
    transactionCurrency:
        item.walletCurrency.isNotEmpty ? item.walletCurrency : null,
    walletsById: wallets,
    fallback: fallbackCurrency,
  );

  return WalletTransactionDisplay(
    amount: item.amount,
    sign: item.isIncome ? '+' : '-',
    currencyCode: currency,
    isIncomingTransfer: false,
  );
}
