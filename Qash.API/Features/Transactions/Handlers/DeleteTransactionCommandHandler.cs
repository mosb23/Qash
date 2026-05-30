using MediatR;
using Microsoft.EntityFrameworkCore;
using Qash.API.Common.Responses;
using Qash.API.Domain.Enums;
using Qash.API.Features.Transactions;
using Qash.API.Features.Transactions.Commands;
using Qash.API.Infrastructure.Data;

using WalletEntity = Qash.API.Domain.Entities.Wallet;

namespace Qash.API.Features.Transactions.Handlers;

public class DeleteTransactionCommandHandler : IRequestHandler<DeleteTransactionCommand, ApiResponse<string>>
{
    private readonly ApplicationDbContext _context;

    public DeleteTransactionCommandHandler(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<ApiResponse<string>> Handle(DeleteTransactionCommand request, CancellationToken cancellationToken)
    {
        var transaction = await _context.Transactions
            .Include(x => x.Wallet)
            .Include(x => x.ToWallet)
            .FirstOrDefaultAsync(
                x => x.Id == request.TransactionId && x.ApplicationUserId == request.UserId,
                cancellationToken);

        if (transaction is null)
        {
            return ApiResponse<string>.FailResponse(
                "Delete transaction failed.",
                ["Transaction was not found."]);
        }

        if (transaction.TransferGroupId.HasValue)
        {
            var counterpart = await ResolveTransferCounterpart(transaction, cancellationToken);
            ReverseTransactionEffect(transaction);
            MarkDeleted(transaction);

            if (counterpart is not null)
            {
                await _context.Entry(counterpart).Reference(x => x.Wallet).LoadAsync(cancellationToken);
                if (counterpart.ToWalletId.HasValue)
                {
                    await _context.Entry(counterpart).Reference(x => x.ToWallet).LoadAsync(cancellationToken);
                }

                ReverseTransactionEffect(counterpart);
                MarkDeleted(counterpart);
            }
        }
        else
        {
            ReverseTransactionEffect(transaction);
            MarkDeleted(transaction);
        }

        await _context.SaveChangesAsync(cancellationToken);

        return ApiResponse<string>.SuccessResponse(
            "Transaction deleted",
            "Transaction deleted successfully.");
    }

    private async Task<Domain.Entities.Transaction?> ResolveTransferCounterpart(
        Domain.Entities.Transaction transaction,
        CancellationToken cancellationToken)
    {
        if (transaction.LinkedTransactionId.HasValue)
        {
            return await _context.Transactions
                .FirstOrDefaultAsync(
                    x => x.Id == transaction.LinkedTransactionId.Value &&
                         x.ApplicationUserId == transaction.ApplicationUserId &&
                         !x.IsDeleted,
                    cancellationToken);
        }

        if (!transaction.TransferGroupId.HasValue)
        {
            return null;
        }

        return await _context.Transactions
            .FirstOrDefaultAsync(
                x => x.TransferGroupId == transaction.TransferGroupId &&
                     x.Id != transaction.Id &&
                     x.ApplicationUserId == transaction.ApplicationUserId &&
                     !x.IsDeleted,
                cancellationToken);
    }

    private static void MarkDeleted(Domain.Entities.Transaction transaction)
    {
        transaction.IsDeleted = true;
        transaction.DeletedAt = DateTime.UtcNow;
        transaction.UpdatedAt = DateTime.UtcNow;
    }

    private static void ReverseTransactionEffect(Domain.Entities.Transaction transaction)
    {
        if (transaction.TransferGroupId.HasValue &&
            transaction.TransactionType is CategoryType.Expense or CategoryType.Income)
        {
            if (transaction.TransactionType == CategoryType.Expense)
            {
                ReverseEffect(transaction.Wallet, CategoryType.Expense, transaction.Amount);
                return;
            }

            ReverseEffect(transaction.Wallet, CategoryType.Income, transaction.Amount);
            return;
        }

        if (transaction.TransactionType == CategoryType.Transfer)
        {
            if (transaction.ToWallet is null)
            {
                return;
            }

            TransferBalanceHelper.ReverseTransfer(
                transaction.Wallet,
                transaction.ToWallet,
                transaction.Amount,
                TransferBalanceHelper.ResolveCreditAmount(transaction));
            return;
        }

        ReverseEffect(transaction.Wallet, transaction.TransactionType, transaction.Amount);
    }

    private static void ReverseEffect(WalletEntity wallet, CategoryType transactionType, decimal amount)
    {
        if (transactionType == CategoryType.Income)
        {
            wallet.Balance -= amount;
            return;
        }

        wallet.Balance += amount;
    }
}
