using System;
using System.Collections.Generic;

namespace Qash.API.Features.Dashboard.DTOs;

public class DashboardDto
{
    public string BaseCurrency { get; set; } = "USD";

    public string DisplayCurrency { get; set; } = "USD";

    public decimal TotalBalance { get; set; }

    public decimal MonthlyIncome { get; set; }

    public decimal MonthlyExpenses { get; set; }

    public decimal MonthlyNet { get; set; }

    public List<RecentTransactionDto> RecentTransactions { get; set; } = [];

    public List<TopCategoryDto> TopCategories { get; set; } = [];
}

public class RecentTransactionDto
{
    public Guid Id { get; set; }

    public string Title { get; set; } = string.Empty;

    public decimal Amount { get; set; }

    public decimal? ConvertedAmount { get; set; }

    public string SourceCurrency { get; set; } = string.Empty;

    public string? DestinationCurrency { get; set; }

    public decimal? ExchangeRateUsed { get; set; }

    public string Type { get; set; } = string.Empty;

    public string CategoryName { get; set; } = string.Empty;

    public string WalletName { get; set; } = string.Empty;

    public DateTime TransactionDate { get; set; }
}

public class TopCategoryDto
{
    public Guid CategoryId { get; set; }

    public string CategoryName { get; set; } = string.Empty;

    public decimal TotalAmount { get; set; }

    public decimal Percentage { get; set; }
}
