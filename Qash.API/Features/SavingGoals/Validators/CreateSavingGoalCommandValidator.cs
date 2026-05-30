using FluentValidation;
using Qash.API.Features.SavingGoals.Commands;

namespace Qash.API.Features.SavingGoals.Validators;

public class CreateSavingGoalCommandValidator : AbstractValidator<CreateSavingGoalCommand>
{
    public CreateSavingGoalCommandValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty()
            .MaximumLength(150);

        RuleFor(x => x.TargetAmount)
            .GreaterThan(0);

        RuleFor(x => x.InitialAmount)
            .GreaterThanOrEqualTo(0);

        RuleFor(x => x.StartingBalance)
            .GreaterThanOrEqualTo(0);

        RuleFor(x => x)
            .Must(x => x.ResolveStartingAmount() <= x.TargetAmount)
            .WithMessage("Initial saved amount cannot exceed the target amount.");

        RuleFor(x => x.Deadline)
            .Must(d => d.Date >= DateTime.UtcNow.Date)
            .WithMessage("Deadline must be today or in the future.");

        RuleFor(x => x.Currency)
            .NotEmpty()
            .MaximumLength(10);
    }
}
