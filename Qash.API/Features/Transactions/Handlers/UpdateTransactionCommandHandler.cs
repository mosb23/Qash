using AutoMapper;
using MediatR;
using Microsoft.EntityFrameworkCore;
using Qash.API.Common.Responses;
using Qash.API.Domain.Entities;
using Qash.API.Domain.Enums;
using Qash.API.Features.Transactions.Commands;
using Qash.API.Features.Transactions.DTOs;
using Qash.API.Infrastructure.Data;
using Qash.API.Infrastructure.Services;

using WalletEntity = Qash.API.Domain.Entities.Wallet;

namespace Qash.API.Features.Transactions.Handlers;

public class UpdateTransactionCommandHandler : IRequestHandler<UpdateTransactionCommand, ApiResponse<TransactionDto>>
{
    private readonly ApplicationDbContext _context;
    private readonly IMapper _mapper;
    private readonly IExchangeRateService _exchangeRateService;
    private readonly ICurrencyConversionService _currencyConversionService;

    public UpdateTransactionCommandHandler(
        ApplicationDbContext context,
        IMapper mapper,
        IExchangeRateService exchangeRateService,
        ICurrencyConversionService currencyConversionService)
    {
        _context = context;
        _mapper = mapper;
        _exchangeRateService = exchangeRateService;
        _currencyConversionService = currencyConversionService;
    }

    public async Task<ApiResponse<TransactionDto>> Handle(UpdateTransactionCommand request, CancellationToken cancellationToken)
    {
        var transaction = await _context.Transactions
            .Include(x => x.Wallet)
            .Include(x => x.Category)
            .Include(x => x.ToWallet)
            .FirstOrDefaultAsync(
                x => x.Id == request.TransactionId && x.ApplicationUserId == request.UserId,
                cancellationToken);

        if (transaction is null)
        {
            return ApiResponse<TransactionDto>.FailResponse(
                "Update transaction failed.",
                ["Transaction was not found."]);
        }

        var targetWallet = await _context.Wallets
            .FirstOrDefaultAsync(
                x => x.Id == request.WalletId && x.ApplicationUserId == request.UserId,
                cancellationToken);

        if (targetWallet is null)
        {
            return ApiResponse<TransactionDto>.FailResponse(
                "Update transaction failed.",
                ["Target wallet was not found."]);
        }

        Category category;

        if (request.TransactionType == CategoryType.Transfer)
        {
            category = await GetOrCreateTransferCategory(
                request.UserId,
                cancellationToken);
        }
        else
        {
            var resolvedCategory = await _context.Categories
                .FirstOrDefaultAsync(
                    x => x.Id == request.CategoryId && x.ApplicationUserId == request.UserId,
                    cancellationToken);

            if (resolvedCategory is null)
            {
                return ApiResponse<TransactionDto>.FailResponse(
                    "Update transaction failed.",
                    ["Category was not found."]);
            }

            if (resolvedCategory.Type != request.TransactionType)
            {
                return ApiResponse<TransactionDto>.FailResponse(
                    "Update transaction failed.",
                    ["Category type does not match transaction type."]);
            }

            category = resolvedCategory;
        }

        WalletEntity? targetTransferWallet = null;
        decimal? transferCreditAmount = null;

        if (request.TransactionType == CategoryType.Transfer)
        {
            if (request.ToWalletId is null || request.ToWalletId == Guid.Empty)
            {
                return ApiResponse<TransactionDto>.FailResponse(
                    "Update transaction failed.",
                    ["Target wallet is required for transfers."]);
            }

            if (request.ToWalletId == request.WalletId)
            {
                return ApiResponse<TransactionDto>.FailResponse(
                    "Update transaction failed.",
                    ["Source and target wallets must be different."]);
            }

            targetTransferWallet = await _context.Wallets
                .FirstOrDefaultAsync(
                    x => x.Id == request.ToWalletId && x.ApplicationUserId == request.UserId,
                    cancellationToken);

            if (targetTransferWallet is null)
            {
                return ApiResponse<TransactionDto>.FailResponse(
                    "Update transaction failed.",
                    ["Target wallet was not found."]);
            }

            try
            {
                transferCreditAmount = _exchangeRateService.GetTransferCreditAmount(
                    request.Amount,
                    targetWallet.Currency,
                    targetTransferWallet.Currency);
            }
            catch (InvalidOperationException ex)
            {
                return ApiResponse<TransactionDto>.FailResponse(
                    "Update transaction failed.",
                    [ex.Message]);
            }
        }

        ReverseTransactionEffect(transaction);

        if (request.TransactionType == CategoryType.Transfer)
        {
            var projectedSourceBalance = targetWallet.Balance;
            if (targetWallet.Id == transaction.WalletId)
            {
                projectedSourceBalance += transaction.Amount;
            }

            if (projectedSourceBalance < request.Amount)
            {
                ApplyTransactionEffect(
                    transaction.Wallet,
                    transaction.ToWallet,
                    transaction.TransactionType,
                    transaction.Amount,
                    TransferBalanceHelper.ResolveCreditAmount(transaction));

                return ApiResponse<TransactionDto>.FailResponse(
                    "Update transaction failed.",
                    ["Insufficient balance in the source wallet."]);
            }

            TransferBalanceHelper.ApplyTransfer(
                targetWallet,
                targetTransferWallet!,
                request.Amount,
                transferCreditAmount!.Value);
        }
        else
        {
            if (request.TransactionType == CategoryType.Expense && targetWallet.Balance < request.Amount)
            {
                ApplyTransactionEffect(
                    transaction.Wallet,
                    transaction.ToWallet,
                    transaction.TransactionType,
                    transaction.Amount,
                    TransferBalanceHelper.ResolveCreditAmount(transaction));

                return ApiResponse<TransactionDto>.FailResponse(
                    "Update transaction failed.",
                    ["Insufficient balance in the wallet."]);
            }

            ApplyEffect(targetWallet, request.TransactionType, request.Amount);
        }

        transaction.WalletId = targetWallet.Id;
        transaction.ToWalletId = request.TransactionType == CategoryType.Transfer
            ? request.ToWalletId
            : null;
        transaction.CategoryId = category.Id;
        transaction.Amount = request.Amount;
        transaction.ToAmount = request.TransactionType == CategoryType.Transfer
            ? transferCreditAmount
            : null;
        transaction.TransactionType = request.TransactionType;
        transaction.Description = request.Description.Trim();
        transaction.TransactionDate = request.TransactionDate == default
            ? transaction.TransactionDate
            : request.TransactionDate;
        transaction.UpdatedAt = DateTime.UtcNow;

        TransactionCurrencyHelper.ApplyConversionMetadata(
            transaction,
            targetWallet,
            targetTransferWallet,
            _currencyConversionService);

        await _context.SaveChangesAsync(cancellationToken);

        await _context.Entry(transaction).Reference(x => x.Wallet).LoadAsync(cancellationToken);
        await _context.Entry(transaction).Reference(x => x.Category).LoadAsync(cancellationToken);
        await _context.Entry(transaction).Reference(x => x.ToWallet).LoadAsync(cancellationToken);

        var dto = _mapper.Map<TransactionDto>(transaction);

        return ApiResponse<TransactionDto>.SuccessResponse(
            dto,
            "Transaction updated successfully.");
    }

    private static void ApplyEffect(WalletEntity wallet, CategoryType transactionType, decimal amount)
    {
        if (transactionType == CategoryType.Income)
        {
            wallet.Balance += amount;
            return;
        }

        wallet.Balance -= amount;
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

    private static void ReverseTransactionEffect(Transaction transaction)
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

    private static void ApplyTransactionEffect(
        WalletEntity sourceWallet,
        WalletEntity? targetWallet,
        CategoryType transactionType,
        decimal amount,
        decimal creditAmount)
    {
        if (transactionType == CategoryType.Transfer)
        {
            if (targetWallet is null)
            {
                return;
            }

            TransferBalanceHelper.ApplyTransfer(
                sourceWallet,
                targetWallet,
                amount,
                creditAmount);
            return;
        }

        ApplyEffect(sourceWallet, transactionType, amount);
    }

    private async Task<Category> GetOrCreateTransferCategory(
        Guid userId,
        CancellationToken cancellationToken)
    {
        var existing = await _context.Categories
            .FirstOrDefaultAsync(
                x => x.ApplicationUserId == userId && x.Type == CategoryType.Transfer,
                cancellationToken);

        if (existing is not null)
        {
            return existing;
        }

        var category = new Category
        {
            ApplicationUserId = userId,
            Name = "Transfer",
            Type = CategoryType.Transfer,
            Icon = null,
            Color = null
        };

        await _context.Categories.AddAsync(category, cancellationToken);
        await _context.SaveChangesAsync(cancellationToken);

        return category;
    }
}
