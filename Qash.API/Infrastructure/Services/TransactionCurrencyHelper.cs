using Qash.API.Domain.Entities;
using Qash.API.Domain.Enums;

namespace Qash.API.Infrastructure.Services;

public static class TransactionCurrencyHelper
{
    public static void ApplyConversionMetadata(
        Transaction transaction,
        Wallet sourceWallet,
        Wallet? destinationWallet,
        ICurrencyConversionService conversionService)
    {
        var sourceCurrency = Normalize(sourceWallet.Currency);
        transaction.SourceCurrency = sourceCurrency;
        transaction.AmountInBaseCurrency = conversionService.ConvertToBase(
            transaction.Amount,
            sourceCurrency);

        if (transaction.TransactionType == CategoryType.Transfer && destinationWallet is not null)
        {
            var destinationCurrency = Normalize(destinationWallet.Currency);
            transaction.DestinationCurrency = destinationCurrency;
            transaction.ToAmount ??= conversionService.GetTransferCreditAmount(
                transaction.Amount,
                sourceCurrency,
                destinationCurrency);
            transaction.ExchangeRateUsed = transaction.Amount == 0
                ? 0
                : RoundMoney(transaction.ToAmount.Value / transaction.Amount);
            return;
        }

        transaction.DestinationCurrency = null;
        transaction.ToAmount = null;
        transaction.ExchangeRateUsed = conversionService.GetEffectiveRate(
            sourceCurrency,
            conversionService.BaseCurrency);
    }

    /// <summary>
    /// Amount is always stored in the source wallet currency. Always convert from wallet
    /// currency so stale SourceCurrency / AmountInBaseCurrency metadata cannot skew totals.
    /// </summary>
    public static decimal ResolveAmountInBase(
        Transaction transaction,
        string walletCurrency,
        ICurrencyConversionService conversionService)
    {
        if (transaction.Amount == 0)
        {
            return 0;
        }

        var currency = ResolveWalletCurrency(transaction, walletCurrency);
        return conversionService.ConvertToBase(transaction.Amount, currency);
    }

    private static string ResolveWalletCurrency(
        Transaction transaction,
        string walletCurrency)
    {
        if (!string.IsNullOrWhiteSpace(walletCurrency))
        {
            return Normalize(walletCurrency);
        }

        if (!string.IsNullOrWhiteSpace(transaction.SourceCurrency))
        {
            return Normalize(transaction.SourceCurrency);
        }

        return CurrencyConstants.BaseCurrency;
    }

    private static string Normalize(string currency) =>
        string.IsNullOrWhiteSpace(currency)
            ? CurrencyConstants.BaseCurrency
            : currency.Trim().ToUpperInvariant();

    private static decimal RoundMoney(decimal value) =>
        Math.Round(value, 2, MidpointRounding.AwayFromZero);
}
