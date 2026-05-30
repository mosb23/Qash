using Microsoft.Extensions.Options;

namespace Qash.API.Infrastructure.Services;

public class CurrencyConversionService : ICurrencyConversionService
{
    private readonly IReadOnlyDictionary<string, decimal> _rates;

    public CurrencyConversionService(IOptions<ExchangeRateOptions> options)
    {
        var configured = options.Value.Rates;
        var normalized = new Dictionary<string, decimal>(StringComparer.OrdinalIgnoreCase);

        foreach (var (currency, rate) in configured)
        {
            if (string.IsNullOrWhiteSpace(currency) || rate <= 0)
            {
                continue;
            }

            normalized[currency.Trim().ToUpperInvariant()] = rate;
        }

        if (!normalized.ContainsKey(CurrencyConstants.BaseCurrency))
        {
            normalized[CurrencyConstants.BaseCurrency] = 1.00m;
        }

        _rates = normalized;
    }

    public string BaseCurrency => CurrencyConstants.BaseCurrency;

    public IReadOnlyDictionary<string, decimal> GetRates() => _rates;

    public decimal Convert(decimal amount, string fromCurrency, string toCurrency) =>
        ConvertToBase(amount, fromCurrency) is var inBase
            ? ConvertFromBase(inBase, toCurrency)
            : 0;

    public decimal ConvertToBase(decimal amount, string fromCurrency)
    {
        var from = NormalizeCurrency(fromCurrency);
        if (from == BaseCurrency)
        {
            return RoundMoney(amount);
        }

        return RoundMoney(amount / GetRate(from));
    }

    public decimal ConvertFromBase(decimal amountInBase, string toCurrency)
    {
        var to = NormalizeCurrency(toCurrency);
        if (to == BaseCurrency)
        {
            return RoundMoney(amountInBase);
        }

        return RoundMoney(amountInBase * GetRate(to));
    }

    public decimal GetEffectiveRate(string fromCurrency, string toCurrency)
    {
        var from = NormalizeCurrency(fromCurrency);
        var to = NormalizeCurrency(toCurrency);

        if (from == to)
        {
            return 1m;
        }

        return RoundMoney(GetRate(to) / GetRate(from));
    }

    public decimal GetTransferCreditAmount(
        decimal sourceAmount,
        string sourceCurrency,
        string targetCurrency) =>
        Convert(sourceAmount, sourceCurrency, targetCurrency);

    private decimal GetRate(string currency)
    {
        if (_rates.TryGetValue(currency, out var rate))
        {
            return rate;
        }

        throw new InvalidOperationException(
            $"Exchange rate is not configured for currency '{currency}'.");
    }

    private static string NormalizeCurrency(string currency)
    {
        if (string.IsNullOrWhiteSpace(currency))
        {
            throw new InvalidOperationException("Currency is required.");
        }

        return currency.Trim().ToUpperInvariant();
    }

    private static decimal RoundMoney(decimal value) =>
        Math.Round(value, 2, MidpointRounding.AwayFromZero);
}
