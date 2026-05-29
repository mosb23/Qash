using Qash.API.Domain.Entities;

using WalletEntity = Qash.API.Domain.Entities.Wallet;

namespace Qash.API.Features.Transactions;

internal static class TransferBalanceHelper
{
    public static decimal ResolveCreditAmount(Transaction transaction) =>
        transaction.ToAmount ?? transaction.Amount;

    public static void ApplyTransfer(
        WalletEntity sourceWallet,
        WalletEntity targetWallet,
        decimal sourceAmount,
        decimal targetAmount)
    {
        sourceWallet.Balance -= sourceAmount;
        targetWallet.Balance += targetAmount;
    }

    public static void ReverseTransfer(
        WalletEntity sourceWallet,
        WalletEntity targetWallet,
        decimal sourceAmount,
        decimal targetAmount)
    {
        sourceWallet.Balance += sourceAmount;
        targetWallet.Balance -= targetAmount;
    }
}
