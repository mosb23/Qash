namespace Qash.API.Infrastructure.Services;

public interface ICurrencyConversionService
{
    string BaseCurrency { get; }

    IReadOnlyDictionary<string, decimal> GetRates();

    decimal Convert(decimal amount, string fromCurrency, string toCurrency);

    decimal ConvertToBase(decimal amount, string fromCurrency);

    decimal ConvertFromBase(decimal amountInBase, string toCurrency);

    decimal GetEffectiveRate(string fromCurrency, string toCurrency);

    decimal GetTransferCreditAmount(
        decimal sourceAmount,
        string sourceCurrency,
        string targetCurrency);
}
