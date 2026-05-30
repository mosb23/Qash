namespace Qash.API.Features.Reports.DTOs;

public class DateRangeSummaryDto
{
    public DateTime FromUtc { get; set; }

    public DateTime ToUtcExclusive { get; set; }

    public string BaseCurrency { get; set; } = "USD";

    public string DisplayCurrency { get; set; } = "USD";

    public decimal TotalIncome { get; set; }

    public decimal TotalExpenses { get; set; }

    public decimal Net { get; set; }

    public int TransactionCount { get; set; }
}
