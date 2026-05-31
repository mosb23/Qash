using FluentValidation;
using Qash.API.Features.Auth.Commands;

namespace Qash.API.Features.Auth.Validators;

public class VerifyPhoneCommandValidator : AbstractValidator<VerifyPhoneCommand>
{
    public VerifyPhoneCommandValidator()
    {
        RuleFor(x => x.PhoneNumber)
            .Cascade(CascadeMode.Stop)
            .NotEmpty().WithMessage("Phone number is required.")
            .Matches(@"^\d+$").WithMessage("Phone number must contain digits only.")
            .MinimumLength(11).WithMessage("Phone number must contain 11 digits.")
            .MaximumLength(11).WithMessage("Phone number cannot exceed 11 digits.");

        RuleFor(x => x.VerificationCode)
            .Cascade(CascadeMode.Stop)
            .NotEmpty().WithMessage("Verification code is required.")
            .Length(5).WithMessage("Verification code must be exactly 5 digits.")
            .Matches(@"^\d{5}$").WithMessage("Verification code must be exactly 5 digits.");
    }
}
