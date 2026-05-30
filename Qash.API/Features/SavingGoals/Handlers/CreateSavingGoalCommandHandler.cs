using AutoMapper;
using MediatR;
using Microsoft.EntityFrameworkCore;
using Qash.API.Common.Responses;
using Qash.API.Domain.Entities;
using Qash.API.Features.SavingGoals.Commands;
using Qash.API.Features.SavingGoals.DTOs;
using Qash.API.Infrastructure.Data;
using Qash.API.Infrastructure.Services;

namespace Qash.API.Features.SavingGoals.Handlers;

public class CreateSavingGoalCommandHandler : IRequestHandler<CreateSavingGoalCommand, ApiResponse<SavingGoalDto>>
{
    private readonly ApplicationDbContext _context;
    private readonly IMapper _mapper;
    public CreateSavingGoalCommandHandler(
        ApplicationDbContext context,
        IMapper mapper)
    {
        _context = context;
        _mapper = mapper;
    }

    public async Task<ApiResponse<SavingGoalDto>> Handle(CreateSavingGoalCommand request, CancellationToken cancellationToken)
    {
        var deadlineUtc = ToUtc(request.Deadline);

        if (deadlineUtc.Date < DateTime.UtcNow.Date)
        {
            return ApiResponse<SavingGoalDto>.FailResponse(
                "Create saving goal failed.",
                ["Deadline must be today or in the future."]);
        }

        // Goals are stored in USD only; amounts are entered in USD at creation.
        const string displayCurrency = CurrencyConstants.BaseCurrency;
        var targetUsd = request.TargetAmount;

        var goal = new SavingGoal
        {
            ApplicationUserId = request.UserId,
            Name = request.Name.Trim(),
            TargetAmount = targetUsd,
            CurrentAmount = 0,
            Deadline = deadlineUtc,
            Currency = displayCurrency
        };

        await _context.SavingGoals.AddAsync(goal, cancellationToken);
        await _context.SaveChangesAsync(cancellationToken);

        return ApiResponse<SavingGoalDto>.SuccessResponse(
            _mapper.Map<SavingGoalDto>(goal),
            "Saving goal created successfully.");
    }

    private static DateTime ToUtc(DateTime d)
    {
        return d.Kind switch
        {
            DateTimeKind.Utc => d,
            DateTimeKind.Local => d.ToUniversalTime(),
            _ => DateTime.SpecifyKind(d, DateTimeKind.Utc)
        };
    }
}
