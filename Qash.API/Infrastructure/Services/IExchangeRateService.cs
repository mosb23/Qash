namespace Qash.API.Infrastructure.Services;

public interface IExchangeRateService
{
    IReadOnlyDictionary<string, decimal> GetRates();

    decimal Convert(decimal amount, string fromCurrency, string toCurrency);

    decimal GetTransferCreditAmount(decimal sourceAmount, string sourceCurrency, string targetCurrency);
}
