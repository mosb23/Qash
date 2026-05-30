using System.Text.Json.Serialization;
using MediatR;
using Qash.API.Common.Responses;
using Qash.API.Features.SavingGoals.DTOs;

namespace Qash.API.Features.SavingGoals.Commands;

public class CreateSavingGoalCommand : IRequest<ApiResponse<SavingGoalDto>>
{
    public Guid UserId { get; set; }

    public string Name { get; set; } = string.Empty;

    public decimal TargetAmount { get; set; }

    public decimal InitialAmount { get; set; }

    /// <summary>Alternate JSON field for the starting saved balance.</summary>
    [JsonPropertyName("currentAmount")]
    public decimal StartingBalance { get; set; }

    public DateTime Deadline { get; set; }

    public string Currency { get; set; } = "USD";

    public decimal ResolveStartingAmount() =>
        InitialAmount > 0 ? InitialAmount : StartingBalance;
}
