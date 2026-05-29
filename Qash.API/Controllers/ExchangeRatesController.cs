using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Qash.API.Common.Responses;
using Qash.API.Infrastructure.Services;

namespace Qash.API.Controllers;

[ApiController]
[Authorize]
[Route("api/exchange-rates")]
public class ExchangeRatesController : ControllerBase
{
    private readonly IExchangeRateService _exchangeRateService;

    public ExchangeRatesController(IExchangeRateService exchangeRateService)
    {
        _exchangeRateService = exchangeRateService;
    }

    [HttpGet]
    public IActionResult GetExchangeRates()
    {
        var rates = _exchangeRateService.GetRates()
            .ToDictionary(
                pair => pair.Key,
                pair => pair.Value,
                StringComparer.OrdinalIgnoreCase);

        return Ok(ApiResponse<Dictionary<string, decimal>>.SuccessResponse(
            rates,
            "Exchange rates retrieved successfully."));
    }
}
