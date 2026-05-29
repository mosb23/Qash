using MediatR;
using Microsoft.EntityFrameworkCore;
using Qash.API.Common.Responses;
using Qash.API.Domain.Enums;
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
            .FirstOrDefaultAsync(
                x => x.Id == request.TransactionId && x.ApplicationUserId == request.UserId,
                cancellationToken);

        if (transaction is null)
        {
            return ApiResponse<string>.FailResponse(
                "Delete transaction failed.",
                ["Transaction was not found."]);
        }

        if (transaction.TransactionType == CategoryType.Transfer && transaction.ToWalletId.HasValue)
        {
            var toWallet = await _context.Wallets
                .FirstOrDefaultAsync(
                    x => x.Id == transaction.ToWalletId && x.ApplicationUserId == request.UserId,
                    cancellationToken);

            if (toWallet is null)
            {
                return ApiResponse<string>.FailResponse(
                    "Delete transaction failed.",
                    ["Destination wallet was not found."]);
            }

            transaction.Wallet.Balance += transaction.Amount;
            toWallet.Balance -= transaction.Amount;
        }
        else
        {
            ReverseEffect(transaction.Wallet, transaction.TransactionType, transaction.Amount);
        }

        transaction.IsDeleted = true;
        transaction.DeletedAt = DateTime.UtcNow;
        transaction.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync(cancellationToken);

        return ApiResponse<string>.SuccessResponse(
            "Transaction deleted",
            "Transaction deleted successfully.");
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