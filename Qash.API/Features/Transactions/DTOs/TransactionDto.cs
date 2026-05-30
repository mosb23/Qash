using System;
using Qash.API.Domain.Enums;


namespace Qash.API.Features.Transactions.DTOs;

public class TransactionDto
{
    public Guid TransactionId { get; set; }

    public Guid WalletId { get; set; }

    public string WalletName { get; set; } = string.Empty;

    public Guid? ToWalletId { get; set; }

    public string? ToWalletName { get; set; }

    public Guid? TransferGroupId { get; set; }

    public Guid? LinkedTransactionId { get; set; }

    public Guid UserId { get; set; }

    public decimal Amount { get; set; }

    public decimal? ToAmount { get; set; }

    public string SourceCurrency { get; set; } = string.Empty;

    public string? DestinationCurrency { get; set; }

    public decimal AmountInBaseCurrency { get; set; }

    public decimal? ExchangeRateUsed { get; set; }

    public string WalletCurrency { get; set; } = string.Empty;

    public string? ToWalletCurrency { get; set; }

    public CategoryType TransactionType { get; set; }

    public Guid CategoryId { get; set; }

    public string CategoryName { get; set; } = string.Empty;

    public string Description { get; set; } = string.Empty;

    public DateTime TransactionDate { get; set; }
}
