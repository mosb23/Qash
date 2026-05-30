using MediatR;
using Microsoft.EntityFrameworkCore;
using Qash.API.Domain.Enums;
using Qash.API.Features.Reports.DTOs;
using Qash.API.Features.Reports.Queries;
using Qash.API.Infrastructure.Data;
using Qash.API.Infrastructure.Services;

namespace Qash.API.Features.Reports.Handlers;

public class IncomeVsExpenseQueryHandler : IRequestHandler<IncomeVsExpenseQuery, List<IncomeVsExpenseDto>>
{
    private readonly ApplicationDbContext _context;
    private readonly ICurrencyConversionService _currency;

    public IncomeVsExpenseQueryHandler(
        ApplicationDbContext context,
        ICurrencyConversionService currency)
    {
        _context = context;
        _currency = currency;
    }

    public async Task<List<IncomeVsExpenseDto>> Handle(
        IncomeVsExpenseQuery request,
        CancellationToken cancellationToken)
    {
        var displayCurrency = await UserCurrencyResolver.GetDisplayCurrencyAsync(
            _context,
            request.UserId,
            cancellationToken);

        var transactions = await _context.Transactions
            .AsNoTracking()
            .Include(x => x.Wallet)
            .Where(x => x.ApplicationUserId == request.UserId)
            .Where(x => x.TransactionDate.Year == request.Year)
            .ToListAsync(cancellationToken);

        var monthlyTotals = transactions
            .GroupBy(x => x.TransactionDate.Month)
            .ToDictionary(
                group => group.Key,
                group => new
                {
                    IncomeInBase = group
                        .Where(x => x.TransactionType == CategoryType.Income)
                        .Sum(x => TransactionCurrencyHelper.ResolveAmountInBase(
                            x,
                            x.Wallet.Currency,
                            _currency)),
                    ExpensesInBase = group
                        .Where(x => x.TransactionType == CategoryType.Expense)
                        .Sum(x => TransactionCurrencyHelper.ResolveAmountInBase(
                            x,
                            x.Wallet.Currency,
                            _currency))
                });

        var result = new List<IncomeVsExpenseDto>(12);

        for (var month = 1; month <= 12; month++)
        {
            if (monthlyTotals.TryGetValue(month, out var totals))
            {
                result.Add(new IncomeVsExpenseDto
                {
                    Month = month,
                    Income = UserCurrencyResolver.ToDisplayAmount(
                        totals.IncomeInBase,
                        displayCurrency,
                        _currency),
                    Expenses = UserCurrencyResolver.ToDisplayAmount(
                        totals.ExpensesInBase,
                        displayCurrency,
                        _currency)
                });
            }
            else
            {
                result.Add(new IncomeVsExpenseDto
                {
                    Month = month,
                    Income = 0,
                    Expenses = 0
                });
            }
        }

        return result;
    }
}
