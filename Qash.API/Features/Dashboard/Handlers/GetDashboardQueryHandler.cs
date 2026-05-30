using MediatR;
using Microsoft.EntityFrameworkCore;
using Qash.API.Common.Responses;
using Qash.API.Domain.Enums;
using Qash.API.Features.Dashboard.DTOs;
using Qash.API.Features.Dashboard.Queries;
using Qash.API.Infrastructure.Data;
using Qash.API.Infrastructure.Services;

namespace Qash.API.Features.Dashboard.Handlers;

public class GetDashboardQueryHandler : IRequestHandler<GetDashboardQuery, ApiResponse<DashboardDto>>
{
    private readonly ApplicationDbContext _context;
    private readonly ICurrencyConversionService _currency;

    public GetDashboardQueryHandler(
        ApplicationDbContext context,
        ICurrencyConversionService currency)
    {
        _context = context;
        _currency = currency;
    }

    public async Task<ApiResponse<DashboardDto>> Handle(
        GetDashboardQuery request,
        CancellationToken cancellationToken)
    {
        var displayCurrency = await UserCurrencyResolver.GetDisplayCurrencyAsync(
            _context,
            request.UserId,
            cancellationToken);

        var now = DateTime.UtcNow;
        var monthStart = new DateTime(now.Year, now.Month, 1, 0, 0, 0, DateTimeKind.Utc);
        var nextMonthStart = monthStart.AddMonths(1);

        var wallets = await _context.Wallets
            .AsNoTracking()
            .Where(x => x.ApplicationUserId == request.UserId)
            .ToListAsync(cancellationToken);

        var totalBalanceInBase = wallets.Sum(wallet =>
            _currency.ConvertToBase(wallet.Balance, wallet.Currency));

        var monthlyTransactions = await _context.Transactions
            .AsNoTracking()
            .Include(x => x.Wallet)
            .Where(x =>
                x.ApplicationUserId == request.UserId &&
                x.TransactionDate >= monthStart &&
                x.TransactionDate < nextMonthStart &&
                x.TransactionType != CategoryType.Transfer)
            .ToListAsync(cancellationToken);

        var monthlyIncomeInBase = monthlyTransactions
            .Where(x => x.TransactionType == CategoryType.Income)
            .Sum(x => TransactionCurrencyHelper.ResolveAmountInBase(x, x.Wallet.Currency, _currency));

        var monthlyExpensesInBase = monthlyTransactions
            .Where(x => x.TransactionType == CategoryType.Expense)
            .Sum(x => TransactionCurrencyHelper.ResolveAmountInBase(x, x.Wallet.Currency, _currency));

        var recentTransactions = await _context.Transactions
            .AsNoTracking()
            .Include(x => x.Wallet)
            .Include(x => x.Category)
            .Include(x => x.ToWallet)
            .Where(x => x.ApplicationUserId == request.UserId)
            .OrderByDescending(x => x.TransactionDate)
            .Take(5)
            .ToListAsync(cancellationToken);

        var recentDtos = recentTransactions.Select(x =>
        {
            var sourceCurrency = string.IsNullOrWhiteSpace(x.SourceCurrency)
                ? x.Wallet.Currency
                : x.SourceCurrency;
            var amountInDisplay = UserCurrencyResolver.ToDisplayAmount(
                TransactionCurrencyHelper.ResolveAmountInBase(x, x.Wallet.Currency, _currency),
                displayCurrency,
                _currency);

            return new RecentTransactionDto
            {
                Id = x.Id,
                Title = x.Description,
                Amount = x.Amount,
                ConvertedAmount = x.TransactionType == CategoryType.Transfer
                    ? x.ToAmount
                    : amountInDisplay,
                SourceCurrency = sourceCurrency,
                DestinationCurrency = x.DestinationCurrency ?? x.ToWallet?.Currency,
                ExchangeRateUsed = x.ExchangeRateUsed,
                Type = x.TransactionType.ToString(),
                CategoryName = x.Category.Name,
                WalletName = x.Wallet.Name,
                TransactionDate = x.TransactionDate
            };
        }).ToList();

        var expenseGroups = monthlyTransactions
            .Where(x => x.TransactionType == CategoryType.Expense)
            .GroupBy(x => new { x.CategoryId, x.Category.Name })
            .Select(g => new
            {
                g.Key.CategoryId,
                g.Key.Name,
                TotalInBase = g.Sum(t =>
                    TransactionCurrencyHelper.ResolveAmountInBase(t, t.Wallet.Currency, _currency))
            })
            .OrderByDescending(x => x.TotalInBase)
            .Take(5)
            .ToList();

        var topCategories = expenseGroups.Select(x => new TopCategoryDto
        {
            CategoryId = x.CategoryId,
            CategoryName = x.Name,
            TotalAmount = UserCurrencyResolver.ToDisplayAmount(
                x.TotalInBase,
                displayCurrency,
                _currency),
            Percentage = monthlyExpensesInBase == 0
                ? 0
                : Math.Round((x.TotalInBase / monthlyExpensesInBase) * 100, 2)
        }).ToList();

        var dashboard = new DashboardDto
        {
            BaseCurrency = _currency.BaseCurrency,
            DisplayCurrency = displayCurrency,
            TotalBalance = UserCurrencyResolver.ToDisplayAmount(
                totalBalanceInBase,
                displayCurrency,
                _currency),
            MonthlyIncome = UserCurrencyResolver.ToDisplayAmount(
                monthlyIncomeInBase,
                displayCurrency,
                _currency),
            MonthlyExpenses = UserCurrencyResolver.ToDisplayAmount(
                monthlyExpensesInBase,
                displayCurrency,
                _currency),
            MonthlyNet = UserCurrencyResolver.ToDisplayAmount(
                monthlyIncomeInBase - monthlyExpensesInBase,
                displayCurrency,
                _currency),
            RecentTransactions = recentDtos,
            TopCategories = topCategories
        };

        return ApiResponse<DashboardDto>.SuccessResponse(
            dashboard,
            "Dashboard retrieved successfully.");
    }
}
