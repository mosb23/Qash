using Qash.API.Domain.Entities;
using Qash.API.Domain.Enums;
using Qash.API.Infrastructure.Services;

using WalletEntity = Qash.API.Domain.Entities.Wallet;

namespace Qash.API.Features.Transactions;

internal static class TransferPairHelper
{
    public static (Transaction Outgoing, Transaction Incoming) CreatePair(
        Guid userId,
        WalletEntity sourceWallet,
        WalletEntity targetWallet,
        Category expenseCategory,
        Category incomeCategory,
        decimal sourceAmount,
        decimal targetAmount,
        string description,
        DateTime transactionDate,
        ICurrencyConversionService conversionService)
    {
        var transferGroupId = Guid.NewGuid();
        var trimmedDescription = description.Trim();
        var outgoingDescription = string.IsNullOrWhiteSpace(trimmedDescription)
            ? $"Transfer to {targetWallet.Name}"
            : trimmedDescription;
        var incomingDescription = string.IsNullOrWhiteSpace(trimmedDescription)
            ? $"Transfer from {sourceWallet.Name}"
            : trimmedDescription;

        var outgoing = new Transaction
        {
            ApplicationUserId = userId,
            WalletId = sourceWallet.Id,
            ToWalletId = targetWallet.Id,
            CategoryId = expenseCategory.Id,
            Amount = sourceAmount,
            TransactionType = CategoryType.Expense,
            Description = outgoingDescription,
            TransactionDate = transactionDate,
            TransferGroupId = transferGroupId,
        };

        var incoming = new Transaction
        {
            ApplicationUserId = userId,
            WalletId = targetWallet.Id,
            ToWalletId = sourceWallet.Id,
            CategoryId = incomeCategory.Id,
            Amount = targetAmount,
            ToAmount = targetAmount,
            TransactionType = CategoryType.Income,
            Description = incomingDescription,
            TransactionDate = transactionDate,
            TransferGroupId = transferGroupId,
        };

        TransactionCurrencyHelper.ApplyConversionMetadata(
            outgoing,
            sourceWallet,
            targetWallet,
            conversionService);

        TransactionCurrencyHelper.ApplyConversionMetadata(
            incoming,
            targetWallet,
            sourceWallet,
            conversionService);

        incoming.DestinationCurrency = outgoing.SourceCurrency;
        incoming.ExchangeRateUsed = outgoing.ExchangeRateUsed;

        return (outgoing, incoming);
    }

    public static void LinkPair(Transaction outgoing, Transaction incoming)
    {
        outgoing.LinkedTransactionId = incoming.Id;
        incoming.LinkedTransactionId = outgoing.Id;
        outgoing.UpdatedAt = DateTime.UtcNow;
        incoming.UpdatedAt = DateTime.UtcNow;
    }

    public static void ApplyPairEffects(
        WalletEntity sourceWallet,
        WalletEntity targetWallet,
        decimal sourceAmount,
        decimal targetAmount)
    {
        sourceWallet.Balance -= sourceAmount;
        targetWallet.Balance += targetAmount;
    }

    public static void ReversePairEffects(
        WalletEntity sourceWallet,
        WalletEntity targetWallet,
        decimal sourceAmount,
        decimal targetAmount)
    {
        sourceWallet.Balance += sourceAmount;
        targetWallet.Balance -= targetAmount;
    }
}
