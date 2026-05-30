using MediatR;
using Microsoft.EntityFrameworkCore;
using Qash.API.Domain.Enums;
using Qash.API.Features.Reports.DTOs;
using Qash.API.Features.Reports.Queries;
using Qash.API.Infrastructure.Data;
using Qash.API.Infrastructure.Services;

namespace Qash.API.Features.Reports.Handlers;

public class DateRangeSummaryQueryHandler : IRequestHandler<DateRangeSummaryQuery, DateRangeSummaryDto>
{
    private readonly ApplicationDbContext _context;
    private readonly ICurrencyConversionService _currency;

    public DateRangeSummaryQueryHandler(
        ApplicationDbContext context,
        ICurrencyConversionService currency)
    {
        _context = context;
        _currency = currency;
    }

    public async Task<DateRangeSummaryDto> Handle(
        DateRangeSummaryQuery request,
        CancellationToken cancellationToken)
    {
        var displayCurrency = await UserCurrencyResolver.GetDisplayCurrencyAsync(
            _context,
            request.UserId,
            cancellationToken);

        var from = NormalizeStartUtc(request.FromUtc);
        var toExclusive = NormalizeEndExclusiveUtc(request.ToUtc);

        var transactions = await _context.Transactions
            .AsNoTracking()
            .Include(x => x.Wallet)
            .Where(x => x.ApplicationUserId == request.UserId)
            .Where(x => x.TransactionDate >= from && x.TransactionDate < toExclusive)
            .ToListAsync(cancellationToken);

        var incomeInBase = transactions
            .Where(x => x.TransactionType == CategoryType.Income)
            .Sum(x => TransactionCurrencyHelper.ResolveAmountInBase(x, x.Wallet.Currency, _currency));

        var expensesInBase = transactions
            .Where(x => x.TransactionType == CategoryType.Expense)
            .Sum(x => TransactionCurrencyHelper.ResolveAmountInBase(x, x.Wallet.Currency, _currency));

        return new DateRangeSummaryDto
        {
            FromUtc = from,
            ToUtcExclusive = toExclusive,
            BaseCurrency = _currency.BaseCurrency,
            DisplayCurrency = displayCurrency,
            TotalIncome = UserCurrencyResolver.ToDisplayAmount(
                incomeInBase,
                displayCurrency,
                _currency),
            TotalExpenses = UserCurrencyResolver.ToDisplayAmount(
                expensesInBase,
                displayCurrency,
                _currency),
            Net = UserCurrencyResolver.ToDisplayAmount(
                incomeInBase - expensesInBase,
                displayCurrency,
                _currency),
            TransactionCount = transactions.Count
        };
    }

    private static DateTime NormalizeStartUtc(DateTime value)
    {
        var utc = value.Kind switch
        {
            DateTimeKind.Utc => value,
            DateTimeKind.Local => value.ToUniversalTime(),
            _ => DateTime.SpecifyKind(value, DateTimeKind.Utc)
        };

        return new DateTime(utc.Year, utc.Month, utc.Day, 0, 0, 0, DateTimeKind.Utc);
    }

    private static DateTime NormalizeEndExclusiveUtc(DateTime value)
    {
        var utc = value.Kind switch
        {
            DateTimeKind.Utc => value,
            DateTimeKind.Local => value.ToUniversalTime(),
            _ => DateTime.SpecifyKind(value, DateTimeKind.Utc)
        };

        return new DateTime(utc.Year, utc.Month, utc.Day, 0, 0, 0, DateTimeKind.Utc).AddDays(1);
    }
}
