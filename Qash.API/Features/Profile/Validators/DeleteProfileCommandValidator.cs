using FluentValidation;
using Qash.API.Features.Profile.Commands;

namespace Qash.API.Features.Profile.Validators;

public class DeleteProfileCommandValidator : AbstractValidator<DeleteProfileCommand>
{
    public DeleteProfileCommandValidator()
    {
        RuleFor(x => x.Password)
            .NotEmpty()
            .WithMessage("Password is required.");
    }
}
