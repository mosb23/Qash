namespace Qash.API.Features.SavingGoals.DTOs;

public class SavingGoalDto
{
    public Guid SavingGoalId { get; set; }

    public string Name { get; set; } = string.Empty;

    public decimal TargetAmount { get; set; }

    public decimal CurrentAmount { get; set; }

    public DateTime Deadline { get; set; }

    public decimal ProgressPercent { get; set; }

    public string Currency { get; set; } = "USD";
}
