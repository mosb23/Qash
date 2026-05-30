using MediatR;
using Qash.API.Common.Responses;
using Qash.API.Features.Budgets.DTOs;

namespace Qash.API.Features.Budgets.Commands;

public class CreateBudgetCommand : IRequest<ApiResponse<BudgetDto>>
{
    public Guid UserId { get; set; }

    public Guid CategoryId { get; set; }

    public int Year { get; set; }

    public int Month { get; set; }

    public decimal Amount { get; set; }

    public string Currency { get; set; } = "USD";
}
