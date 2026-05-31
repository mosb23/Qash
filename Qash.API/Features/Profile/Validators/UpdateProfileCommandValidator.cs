using FluentValidation;
using Qash.API.Features.Profile.Commands;

namespace Qash.API.Features.Profile.Validators;

public class UpdateProfileCommandValidator : AbstractValidator<UpdateProfileCommand>
{
    public UpdateProfileCommandValidator()
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
    }
}
