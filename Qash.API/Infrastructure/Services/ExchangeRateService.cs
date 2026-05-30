namespace Qash.API.Infrastructure.Services;

public class ExchangeRateService : CurrencyConversionService, IExchangeRateService
{
    public ExchangeRateService(Microsoft.Extensions.Options.IOptions<ExchangeRateOptions> options)
        : base(options)
    {
    }
}
