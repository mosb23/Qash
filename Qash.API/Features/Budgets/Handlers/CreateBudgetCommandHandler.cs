using AutoMapper;
using MediatR;
using Microsoft.EntityFrameworkCore;
using Qash.API.Common.Responses;
using Qash.API.Domain.Entities;
using Qash.API.Domain.Enums;
using Qash.API.Features.Budgets.Commands;
using Qash.API.Features.Budgets.DTOs;
using Qash.API.Infrastructure.Data;
using Qash.API.Infrastructure.Services;

namespace Qash.API.Features.Budgets.Handlers;

public class CreateBudgetCommandHandler : IRequestHandler<CreateBudgetCommand, ApiResponse<BudgetDto>>
{
    private readonly ApplicationDbContext _context;
    private readonly IMapper _mapper;

    public CreateBudgetCommandHandler(ApplicationDbContext context, IMapper mapper)
    {
        _context = context;
        _mapper = mapper;
    }

    public async Task<ApiResponse<BudgetDto>> Handle(CreateBudgetCommand request, CancellationToken cancellationToken)
    {
        var category = await _context.Categories
            .FirstOrDefaultAsync(
                x => x.Id == request.CategoryId && x.ApplicationUserId == request.UserId,
                cancellationToken);

        if (category is null)
        {
            return ApiResponse<BudgetDto>.FailResponse(
                "Create budget failed.",
                ["Category was not found."]);
        }

        if (category.Type != CategoryType.Expense)
        {
            return ApiResponse<BudgetDto>.FailResponse(
                "Create budget failed.",
                ["Budgets can only be linked to expense categories."]);
        }

        var duplicate = await _context.Budgets
            .AnyAsync(
                x =>
                    x.ApplicationUserId == request.UserId &&
                    x.CategoryId == request.CategoryId &&
                    x.Year == request.Year &&
                    x.Month == request.Month,
                cancellationToken);

        if (duplicate)
        {
            return ApiResponse<BudgetDto>.FailResponse(
                "Create budget failed.",
                ["A budget for this category and month already exists."]);
        }

        var budget = new Budget
        {
            ApplicationUserId = request.UserId,
            CategoryId = category.Id,
            Year = request.Year,
            Month = request.Month,
            Amount = request.Amount,
            Currency = UserCurrencyResolver.NormalizeDisplayCurrency(request.Currency)
        };

        await _context.Budgets.AddAsync(budget, cancellationToken);
        await _context.SaveChangesAsync(cancellationToken);

        await _context.Entry(budget).Reference(x => x.Category).LoadAsync(cancellationToken);

        return ApiResponse<BudgetDto>.SuccessResponse(
            _mapper.Map<BudgetDto>(budget),
            "Budget created successfully.");
    }
}
