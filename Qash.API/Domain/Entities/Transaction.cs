using Qash.API.Domain.Common;
using Qash.API.Domain.Enums;

namespace Qash.API.Domain.Entities;

public class Transaction : BaseEntity
{
    public Guid WalletId { get; set; }

    public Wallet Wallet { get; set; } = null!;

    public Guid? ToWalletId { get; set; }

    public Wallet? ToWallet { get; set; }

    /// <summary>Links paired transfer legs (outgoing expense + incoming income).</summary>
    public Guid? TransferGroupId { get; set; }

    /// <summary>Points to the counterpart transaction in a transfer pair.</summary>
    public Guid? LinkedTransactionId { get; set; }

    public Guid ApplicationUserId { get; set; }

    public ApplicationUser ApplicationUser { get; set; } = null!;

    public CategoryType TransactionType { get; set; }

    public decimal Amount { get; set; }

    /// <summary>
    /// Amount credited to <see cref="ToWallet"/> for transfers (destination currency).
    /// </summary>
    public decimal? ToAmount { get; set; }

    /// <summary>Original transaction currency (source wallet).</summary>
    public string SourceCurrency { get; set; } = "USD";

    /// <summary>Destination wallet currency for transfers.</summary>
    public string? DestinationCurrency { get; set; }

    /// <summary>Amount normalized to the base currency (USD) at transaction time.</summary>
    public decimal AmountInBaseCurrency { get; set; }

    /// <summary>
    /// Exchange rate applied: destination per source unit for transfers,
    /// or source-to-base rate for income/expense.
    /// </summary>
    public decimal? ExchangeRateUsed { get; set; }

    public Guid CategoryId { get; set; }

    public Category Category { get; set; } = null!;

    public string Description { get; set; } = string.Empty;

    public DateTime TransactionDate { get; set; } = DateTime.UtcNow;
}
