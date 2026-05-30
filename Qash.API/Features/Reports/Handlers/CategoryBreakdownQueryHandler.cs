using MediatR;
using Microsoft.EntityFrameworkCore;
using Qash.API.Domain.Enums;
using Qash.API.Features.Reports.DTOs;
using Qash.API.Features.Reports.Queries;
using Qash.API.Infrastructure.Data;
using Qash.API.Infrastructure.Services;

namespace Qash.API.Features.Reports.Handlers;

public class CategoryBreakdownQueryHandler : IRequestHandler<CategoryBreakdownQuery, List<CategoryBreakdownDto>>
{
    private readonly ApplicationDbContext _context;
    private readonly ICurrencyConversionService _currency;

    public CategoryBreakdownQueryHandler(
        ApplicationDbContext context,
        ICurrencyConversionService currency)
    {
        _context = context;
        _currency = currency;
    }

    public async Task<List<CategoryBreakdownDto>> Handle(
        CategoryBreakdownQuery request,
        CancellationToken cancellationToken)
    {
        var displayCurrency = await UserCurrencyResolver.GetDisplayCurrencyAsync(
            _context,
            request.UserId,
            cancellationToken);

        var transactions = await _context.Transactions
            .AsNoTracking()
            .Include(x => x.Wallet)
            .Include(x => x.Category)
            .Where(x => x.ApplicationUserId == request.UserId)
            .Where(x => x.TransactionType == CategoryType.Expense)
            .Where(x => x.TransactionDate.Year == request.Year && x.TransactionDate.Month == request.Month)
            .ToListAsync(cancellationToken);

        return transactions
            .GroupBy(x => x.Category.Name)
            .Select(group =>
            {
                var totalInBase = group.Sum(t =>
                    TransactionCurrencyHelper.ResolveAmountInBase(t, t.Wallet.Currency, _currency));
                return new CategoryBreakdownDto
                {
                    CategoryId = group.Key,
                    TotalAmount = UserCurrencyResolver.ToDisplayAmount(
                        totalInBase,
                        displayCurrency,
                        _currency)
                };
            })
            .OrderByDescending(x => x.TotalAmount)
            .ToList();
    }
}
