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

        RuleFor(x => x.Amount)
            .GreaterThan(0);

        RuleFor(x => x.Description)
            .MaximumLength(500);

        When(x => x.TransactionType == CategoryType.Transfer, () =>
        {
            RuleFor(x => x.ToWalletId)
                .NotEmpty()
                .WithMessage("Destination wallet is required for transfers.");

            RuleFor(x => x)
                .Must(x => x.ToWalletId != x.WalletId)
                .WithMessage("Source and destination wallets must be different.")
                .When(x => x.ToWalletId.HasValue);
        });

        When(x => x.TransactionType != CategoryType.Transfer, () =>
        {
            RuleFor(x => x.CategoryId)
                .NotEmpty();

            RuleFor(x => x.TransactionType)
                .Must(x => x == CategoryType.Income || x == CategoryType.Expense)
                .WithMessage("Transaction type must be Income or Expense.");
        });
    }
}
