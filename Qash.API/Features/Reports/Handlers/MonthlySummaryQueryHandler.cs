using MediatR;
using Microsoft.EntityFrameworkCore;
using Qash.API.Domain.Enums;
using Qash.API.Features.Reports.DTOs;
using Qash.API.Features.Reports.Queries;
using Qash.API.Infrastructure.Data;
using Qash.API.Infrastructure.Services;

namespace Qash.API.Features.Reports.Handlers;

public class MonthlySummaryQueryHandler : IRequestHandler<MonthlySummaryQuery, MonthlySummaryDto>
{
    private readonly ApplicationDbContext _context;
    private readonly ICurrencyConversionService _currency;

    public MonthlySummaryQueryHandler(
        ApplicationDbContext context,
        ICurrencyConversionService currency)
    {
        _context = context;
        _currency = currency;
    }

    public async Task<MonthlySummaryDto> Handle(
        MonthlySummaryQuery request,
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
            .Where(x => x.TransactionDate.Year == request.Year && x.TransactionDate.Month == request.Month)
            .ToListAsync(cancellationToken);

        var totalIncomeInBase = transactions
            .Where(x => x.TransactionType == CategoryType.Income)
            .Sum(x => TransactionCurrencyHelper.ResolveAmountInBase(x, x.Wallet.Currency, _currency));

        var totalExpensesInBase = transactions
            .Where(x => x.TransactionType == CategoryType.Expense)
            .Sum(x => TransactionCurrencyHelper.ResolveAmountInBase(x, x.Wallet.Currency, _currency));

        return new MonthlySummaryDto
        {
            BaseCurrency = _currency.BaseCurrency,
            DisplayCurrency = displayCurrency,
            TotalIncome = UserCurrencyResolver.ToDisplayAmount(
                totalIncomeInBase,
                displayCurrency,
                _currency),
            TotalExpenses = UserCurrencyResolver.ToDisplayAmount(
                totalExpensesInBase,
                displayCurrency,
                _currency),
            NetBalance = UserCurrencyResolver.ToDisplayAmount(
                totalIncomeInBase - totalExpensesInBase,
                displayCurrency,
                _currency),
            TransactionCount = transactions.Count
        };
    }
}
