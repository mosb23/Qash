using Microsoft.Extensions.Options;

namespace Qash.API.Infrastructure.Services;

public class ExchangeRateService : IExchangeRateService
{
    private readonly IReadOnlyDictionary<string, decimal> _rates;

    public ExchangeRateService(IOptions<ExchangeRateOptions> options)
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

        if (!normalized.ContainsKey("USD"))
        {
            normalized["USD"] = 1.00m;
        }

        _rates = normalized;
    }

    public IReadOnlyDictionary<string, decimal> GetRates() => _rates;

    public decimal Convert(decimal amount, string fromCurrency, string toCurrency)
    {
        var from = NormalizeCurrency(fromCurrency);
        var to = NormalizeCurrency(toCurrency);

        if (from == to)
        {
            return RoundMoney(amount);
        }

        var fromRate = GetRate(from);
        var toRate = GetRate(to);

        var amountInUsd = amount / fromRate;
        return RoundMoney(amountInUsd * toRate);
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
