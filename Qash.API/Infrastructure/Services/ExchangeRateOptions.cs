namespace Qash.API.Infrastructure.Services;

public class ExchangeRateOptions
{
    public const string SectionName = "ExchangeRates";

    /// <summary>
    /// Units of each currency per 1 USD (e.g. 1 USD = 49.50 EGP).
    /// </summary>
    public Dictionary<string, decimal> Rates { get; set; } = new(StringComparer.OrdinalIgnoreCase)
    {
        ["USD"] = 1.00m,
        ["EGP"] = 49.50m,
        ["EUR"] = 0.86m,
        ["GBP"] = 0.74m,
        ["JPY"] = 143.20m
    };
}
