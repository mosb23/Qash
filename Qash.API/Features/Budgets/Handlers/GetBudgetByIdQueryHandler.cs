using MediatR;
using Microsoft.EntityFrameworkCore;
using Qash.API.Common.Responses;
using Qash.API.Domain.Enums;
using Qash.API.Features.Budgets.DTOs;
using Qash.API.Features.Budgets.Queries;
using Qash.API.Infrastructure.Data;

namespace Qash.API.Features.Budgets.Handlers;

public class GetBudgetByIdQueryHandler : IRequestHandler<GetBudgetByIdQuery, ApiResponse<BudgetStatusDto>>
{
    private readonly ApplicationDbContext _context;

    public GetBudgetByIdQueryHandler(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<ApiResponse<BudgetStatusDto>> Handle(
        GetBudgetByIdQuery request,
        CancellationToken cancellationToken)
    {
        var budget = await _context.Budgets
            .AsNoTracking()
            .Include(x => x.Category)
            .FirstOrDefaultAsync(
                x => x.Id == request.BudgetId && x.ApplicationUserId == request.UserId,
                cancellationToken);

        if (budget is null)
        {
            return ApiResponse<BudgetStatusDto>.FailResponse(
                "Budget was not found.",
                ["Budget was not found."]);
        }

        var monthStart = new DateTime(budget.Year, budget.Month, 1, 0, 0, 0, DateTimeKind.Utc);
        var monthEnd = monthStart.AddMonths(1);

        var spent = await _context.Transactions
            .AsNoTracking()
            .Where(x =>
                x.ApplicationUserId == request.UserId &&
                x.TransactionType == CategoryType.Expense &&
                x.CategoryId == budget.CategoryId &&
                x.TransactionDate >= monthStart &&
                x.TransactionDate < monthEnd)
            .SumAsync(x => x.Amount, cancellationToken);

        var dto = new BudgetStatusDto
        {
            BudgetId = budget.Id,
            CategoryId = budget.CategoryId,
            CategoryName = budget.Category.Name,
            Year = budget.Year,
            Month = budget.Month,
            BudgetAmount = budget.Amount,
            SpentAmount = spent,
            RemainingAmount = budget.Amount - spent,
        };

        return ApiResponse<BudgetStatusDto>.SuccessResponse(
            dto,
            "Budget retrieved successfully.");
    }
}
