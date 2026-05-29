using MediatR;
using Qash.API.Common.Responses;
using Qash.API.Features.Transactions.DTOs;
using System;
using Qash.API.Domain.Enums;

namespace Qash.API.Features.Transactions.Commands;

public class CreateTransactionCommand : IRequest<ApiResponse<TransactionDto>>
{
    public Guid UserId { get; set; }

    public Guid WalletId { get; set; }

    public Guid? ToWalletId { get; set; }

    public decimal Amount { get; set; }

    public CategoryType TransactionType { get; set; }

    public Guid CategoryId { get; set; }

    public string Description { get; set; } = string.Empty;

    public DateTime TransactionDate { get; set; } = DateTime.UtcNow;
}