using MediatR;
using Microsoft.EntityFrameworkCore;
using Qash.API.Common.Responses;
using Qash.API.Domain.Enums;
using Qash.API.Features.Budgets.DTOs;
using Qash.API.Features.Budgets.Queries;
using Qash.API.Infrastructure.Data;
using Qash.API.Infrastructure.Services;

namespace Qash.API.Features.Budgets.Handlers;

public class GetBudgetStatusesQueryHandler : IRequestHandler<GetBudgetStatusesQuery, ApiResponse<List<BudgetStatusDto>>>
{
    private readonly ApplicationDbContext _context;
    private readonly ICurrencyConversionService _currency;

    public GetBudgetStatusesQueryHandler(
        ApplicationDbContext context,
        ICurrencyConversionService currency)
    {
        _context = context;
        _currency = currency;
    }

    public async Task<ApiResponse<List<BudgetStatusDto>>> Handle(
        GetBudgetStatusesQuery request,
        CancellationToken cancellationToken)
    {
        var monthStart = new DateTime(request.Year, request.Month, 1, 0, 0, 0, DateTimeKind.Utc);
        var monthEnd = monthStart.AddMonths(1);

        var budgets = await _context.Budgets
            .AsNoTracking()
            .Include(x => x.Category)
            .Where(x => x.ApplicationUserId == request.UserId && x.Year == request.Year && x.Month == request.Month)
            .ToListAsync(cancellationToken);

        if (budgets.Count == 0)
        {
            return ApiResponse<List<BudgetStatusDto>>.SuccessResponse(
                [],
                "No budgets for this period.");
        }

        var categoryIds = budgets.Select(x => x.CategoryId).Distinct().ToList();

        var expenses = await _context.Transactions
            .AsNoTracking()
            .Include(x => x.Wallet)
            .Where(x =>
                x.ApplicationUserId == request.UserId &&
                x.TransactionType == CategoryType.Expense &&
                categoryIds.Contains(x.CategoryId) &&
                x.TransactionDate >= monthStart &&
                x.TransactionDate < monthEnd)
            .ToListAsync(cancellationToken);

        var result = budgets.Select(b =>
        {
            var spentInBudgetCurrency = expenses
                .Where(x => x.CategoryId == b.CategoryId)
                .Sum(x =>
                {
                    var amountInBase = TransactionCurrencyHelper.ResolveAmountInBase(
                        x,
                        x.Wallet.Currency,
                        _currency);
                    return _currency.ConvertFromBase(amountInBase, b.Currency);
                });

            var remaining = b.Amount - spentInBudgetCurrency;
            return new BudgetStatusDto
            {
                BudgetId = b.Id,
                CategoryId = b.CategoryId,
                CategoryName = b.Category.Name,
                Year = b.Year,
                Month = b.Month,
                BudgetAmount = b.Amount,
                SpentAmount = spentInBudgetCurrency,
                RemainingAmount = remaining,
                Currency = b.Currency
            };
        }).ToList();

        return ApiResponse<List<BudgetStatusDto>>.SuccessResponse(
            result,
            "Budget statuses retrieved successfully.");
    }
}
