using MediatR;
using Microsoft.EntityFrameworkCore;
using Qash.API.Domain.Enums;
using Qash.API.Features.Reports.DTOs;
using Qash.API.Features.Reports.Queries;
using Qash.API.Infrastructure.Data;
using Qash.API.Infrastructure.Services;

namespace Qash.API.Features.Reports.Handlers;

public class SpendingTrendQueryHandler : IRequestHandler<SpendingTrendQuery, List<SpendingTrendDto>>
{
    private readonly ApplicationDbContext _context;
    private readonly ICurrencyConversionService _currency;

    public SpendingTrendQueryHandler(
        ApplicationDbContext context,
        ICurrencyConversionService currency)
    {
        _context = context;
        _currency = currency;
    }

    public async Task<List<SpendingTrendDto>> Handle(
        SpendingTrendQuery request,
        CancellationToken cancellationToken)
    {
        var displayCurrency = await UserCurrencyResolver.GetDisplayCurrencyAsync(
            _context,
            request.UserId,
            cancellationToken);

        var endDate = DateTime.UtcNow.Date;
        var startDate = endDate.AddDays(-(request.Days - 1));

        var transactions = await _context.Transactions
            .AsNoTracking()
            .Include(x => x.Wallet)
            .Where(x => x.ApplicationUserId == request.UserId)
            .Where(x => x.TransactionType == CategoryType.Expense)
            .Where(x => x.TransactionDate >= startDate && x.TransactionDate < endDate.AddDays(1))
            .ToListAsync(cancellationToken);

        var totalsByDate = transactions
            .GroupBy(x => x.TransactionDate.Date)
            .ToDictionary(
                group => group.Key,
                group => group.Sum(x =>
                    TransactionCurrencyHelper.ResolveAmountInBase(x, x.Wallet.Currency, _currency)));

        var result = new List<SpendingTrendDto>(request.Days);

        for (var offset = 0; offset < request.Days; offset++)
        {
            var currentDate = startDate.AddDays(offset);
            totalsByDate.TryGetValue(currentDate, out var totalInBase);

            result.Add(new SpendingTrendDto
            {
                Date = currentDate,
                TotalExpenses = UserCurrencyResolver.ToDisplayAmount(
                    totalInBase,
                    displayCurrency,
                    _currency)
            });
        }

        return result;
    }
}
