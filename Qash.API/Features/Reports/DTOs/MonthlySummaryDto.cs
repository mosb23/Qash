namespace Qash.API.Features.Reports.DTOs;

public class MonthlySummaryDto
{
    public string BaseCurrency { get; set; } = "USD";

    public string DisplayCurrency { get; set; } = "USD";

    public decimal TotalIncome { get; set; }

    public decimal TotalExpenses { get; set; }

    public decimal NetBalance { get; set; }

    public int TransactionCount { get; set; }
}
