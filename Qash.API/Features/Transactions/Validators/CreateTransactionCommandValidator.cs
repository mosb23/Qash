using FluentValidation;
using Qash.API.Domain.Enums;
using Qash.API.Features.Transactions.Commands;

namespace Qash.API.Features.Transactions.Validators;

public class CreateTransactionCommandValidator : AbstractValidator<CreateTransactionCommand>
{
    public CreateTransactionCommandValidator()
    {
        RuleFor(x => x.WalletId)
            .NotEmpty();

        RuleFor(x => x.CategoryId)
            .NotEmpty()
            .When(x => x.TransactionType != CategoryType.Transfer)
            .WithMessage("Category is required for income and expense.");

        RuleFor(x => x.TransactionType)
            .Must(
                x =>
                    x == CategoryType.Income ||
                    x == CategoryType.Expense ||
                    x == CategoryType.Transfer)
            .WithMessage("Transaction type must be Income, Expense, or Transfer.");

        RuleFor(x => x.ToWalletId)
            .NotEmpty()
            .When(x => x.TransactionType == CategoryType.Transfer)
            .WithMessage("Target wallet is required for transfers.");

        RuleFor(x => x.Amount)
            .GreaterThan(0);

        RuleFor(x => x.Description)
            .MaximumLength(500);
    }
}