using Microsoft.EntityFrameworkCore;
using Qash.API.Infrastructure.Data;
using Qash.API.Infrastructure.Services;

namespace Qash.API.Infrastructure.Services;

public static class UserCurrencyResolver
{
    public static async Task<string> GetDisplayCurrencyAsync(
        ApplicationDbContext context,
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        var preferred = await context.Users
            .AsNoTracking()
            .Where(x => x.Id == userId)
            .Select(x => x.PreferredCurrency)
            .FirstOrDefaultAsync(cancellationToken);

        return NormalizeDisplayCurrency(preferred);
    }

    public static string NormalizeDisplayCurrency(string? currency)
    {
        if (string.IsNullOrWhiteSpace(currency))
        {
            return CurrencyConstants.BaseCurrency;
        }

        var normalized = currency.Trim().ToUpperInvariant();
        return CurrencyConstants.SupportedCurrencies.Contains(normalized)
            ? normalized
            : CurrencyConstants.BaseCurrency;
    }

    public static decimal ToDisplayAmount(
        decimal amountInBase,
        string displayCurrency,
        ICurrencyConversionService conversionService) =>
        conversionService.ConvertFromBase(amountInBase, displayCurrency);
}
