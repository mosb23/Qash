using Qash.API.Domain.Common;
using Qash.API.Domain.Enums;

namespace Qash.API.Domain.Entities;

public class Transaction : BaseEntity
{
    public Guid WalletId { get; set; }

    public Wallet Wallet { get; set; } = null!;

    public Guid? ToWalletId { get; set; }

    public Wallet? ToWallet { get; set; }

    public Guid ApplicationUserId { get; set; }

    public ApplicationUser ApplicationUser { get; set; } = null!;

    public CategoryType TransactionType { get; set; }

    public decimal Amount { get; set; }

    /// <summary>
    /// Amount credited to <see cref="ToWallet"/> for transfers (destination currency).
    /// </summary>
    public decimal? ToAmount { get; set; }

    public Guid CategoryId { get; set; }

    public Category Category { get; set; } = null!;

    public string Description { get; set; } = string.Empty;

    public DateTime TransactionDate { get; set; } = DateTime.UtcNow;
}