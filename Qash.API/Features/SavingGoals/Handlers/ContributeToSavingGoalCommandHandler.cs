using AutoMapper;
using MediatR;
using Microsoft.EntityFrameworkCore;
using Qash.API.Common.Responses;
using Qash.API.Features.SavingGoals.Commands;
using Qash.API.Features.SavingGoals.DTOs;
using Qash.API.Infrastructure.Data;
using Qash.API.Infrastructure.Services;

namespace Qash.API.Features.SavingGoals.Handlers;

public class ContributeToSavingGoalCommandHandler : IRequestHandler<ContributeToSavingGoalCommand, ApiResponse<SavingGoalDto>>
{
    private readonly ApplicationDbContext _context;
    private readonly IMapper _mapper;
    private readonly ICurrencyConversionService _currency;

    public ContributeToSavingGoalCommandHandler(
        ApplicationDbContext context,
        IMapper mapper,
        ICurrencyConversionService currency)
    {
        _context = context;
        _mapper = mapper;
        _currency = currency;
    }

    public async Task<ApiResponse<SavingGoalDto>> Handle(ContributeToSavingGoalCommand request, CancellationToken cancellationToken)
    {
        var goal = await _context.SavingGoals
            .FirstOrDefaultAsync(
                x => x.Id == request.SavingGoalId && x.ApplicationUserId == request.UserId,
                cancellationToken);

        if (goal is null)
        {
            return ApiResponse<SavingGoalDto>.FailResponse(
                "Contribution failed.",
                ["Saving goal was not found."]);
        }

        var inputCurrency = UserCurrencyResolver.NormalizeDisplayCurrency(
            request.InputCurrency ?? request.Currency);
        var inputAmount = request.InputAmount ?? request.Amount;

        var amountUsd = ResolveContributionUsd(request, inputCurrency, inputAmount);
        var remainingUsd = goal.TargetAmount - goal.CurrentAmount;

        if (amountUsd <= 0)
        {
            return ApiResponse<SavingGoalDto>.FailResponse(
                "Contribution failed.",
                ["Contribution amount must be greater than zero."]);
        }

        if (amountUsd > remainingUsd)
        {
            return ApiResponse<SavingGoalDto>.FailResponse(
                "Contribution failed.",
                ["Contribution exceeds the remaining goal balance."]);
        }

        goal.CurrentAmount += amountUsd;
        goal.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync(cancellationToken);

        return ApiResponse<SavingGoalDto>.SuccessResponse(
            _mapper.Map<SavingGoalDto>(goal),
            "Contribution recorded successfully.");
    }

    /// <summary>
    /// Always persists USD. Server conversion wins when input is non-USD;
    /// otherwise uses explicit <see cref="ContributeToSavingGoalCommand.AmountInBaseCurrency"/>.
    /// </summary>
    private decimal ResolveContributionUsd(
        ContributeToSavingGoalCommand request,
        string inputCurrency,
        decimal inputAmount)
    {
        if (inputCurrency != CurrencyConstants.BaseCurrency)
        {
            return _currency.ConvertToBase(inputAmount, inputCurrency);
        }

        if (request.AmountInBaseCurrency > 0)
        {
            return request.AmountInBaseCurrency;
        }

        return _currency.ConvertToBase(inputAmount, inputCurrency);
    }
}
