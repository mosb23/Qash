namespace Qash.API.Features.Budgets.DTOs;

public class BudgetStatusDto
{
    public Guid BudgetId { get; set; }

    public Guid CategoryId { get; set; }

    public string CategoryName { get; set; } = string.Empty;

    public int Year { get; set; }

    public int Month { get; set; }

    public decimal BudgetAmount { get; set; }

    public decimal SpentAmount { get; set; }

    public decimal RemainingAmount { get; set; }

    public string Currency { get; set; } = "USD";
}
