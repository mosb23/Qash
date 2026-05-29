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

        ReverseTransactionEffect(transaction);

        transaction.IsDeleted = true;
        transaction.DeletedAt = DateTime.UtcNow;
        transaction.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync(cancellationToken);

        return ApiResponse<string>.SuccessResponse(
            "Transaction deleted",
            "Transaction deleted successfully.");
    }

    private static void ReverseTransactionEffect(Domain.Entities.Transaction transaction)
    {
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
