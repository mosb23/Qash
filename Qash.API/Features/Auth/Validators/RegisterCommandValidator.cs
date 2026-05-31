using FluentValidation;
using Qash.API.Features.Auth.Commands;

namespace Qash.API.Features.Auth.Validators;

public class RegisterCommandValidator : AbstractValidator<RegisterCommand>
{
    public RegisterCommandValidator()
    {
        RuleFor(x => x.FirstName)
            .NotEmpty()
            .MaximumLength(100);

        RuleFor(x => x.LastName)
            .NotEmpty()
            .MaximumLength(100);

        RuleFor(x => x.Email)
            .NotEmpty()
            .EmailAddress()
            .WithMessage("Please enter a valid email address.");

        RuleFor(x => x.PhoneNumber)
            .Cascade(CascadeMode.Stop)
            .NotEmpty().WithMessage("Phone number is required.")
            .Matches(@"^\d+$").WithMessage("Phone number must contain digits only.")
            .MinimumLength(11).WithMessage("Phone number must contain 11 digits.")
            .MaximumLength(11).WithMessage("Phone number cannot exceed 11 digits.");

        RuleFor(x => x.Password)
            .NotEmpty()
            .MinimumLength(8).WithMessage("Password must be at least 8 characters.")
            .Matches("[A-Z]").WithMessage("Password must contain at least 1 uppercase letter.")
            .Matches("[a-z]").WithMessage("Password must contain at least 1 lowercase letter.")
            .Matches("[0-9]").WithMessage("Password must contain at least 1 number.");

        RuleFor(x => x.ConfirmPassword)
            .Equal(x => x.Password)
            .WithMessage("Passwords do not match.");
    }
}
