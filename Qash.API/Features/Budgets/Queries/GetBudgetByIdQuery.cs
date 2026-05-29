using MediatR;
using Qash.API.Common.Responses;
using Qash.API.Features.Budgets.DTOs;

namespace Qash.API.Features.Budgets.Queries;

public class GetBudgetByIdQuery : IRequest<ApiResponse<BudgetStatusDto>>
{
    public GetBudgetByIdQuery(Guid userId, Guid budgetId)
    {
        UserId = userId;
        BudgetId = budgetId;
    }

    public Guid UserId { get; }

    public Guid BudgetId { get; }
}
