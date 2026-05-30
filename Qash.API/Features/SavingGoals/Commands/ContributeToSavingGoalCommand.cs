using System.Text.Json.Serialization;
using MediatR;
using Qash.API.Common.Responses;
using Qash.API.Features.SavingGoals.DTOs;

namespace Qash.API.Features.SavingGoals.Commands;

public class ContributeToSavingGoalCommand : IRequest<ApiResponse<SavingGoalDto>>
{
    public Guid UserId { get; set; }

    public Guid SavingGoalId { get; set; }

    /// <summary>Legacy: entered amount (may be non-USD). Prefer conversion below.</summary>
    public decimal Amount { get; set; }

    [JsonPropertyName("currency")]
    public string Currency { get; set; } = "USD";

    /// <summary>USD value to add; sent by the client after conversion.</summary>
    [JsonPropertyName("amountInBaseCurrency")]
    public decimal AmountInBaseCurrency { get; set; }

    [JsonPropertyName("inputAmount")]
    public decimal? InputAmount { get; set; }

    [JsonPropertyName("inputCurrency")]
    public string? InputCurrency { get; set; }
}
