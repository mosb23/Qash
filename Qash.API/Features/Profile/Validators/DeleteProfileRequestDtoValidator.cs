using FluentValidation;
using Qash.API.Features.Profile.DTOs;

namespace Qash.API.Features.Profile.Validators;

public class DeleteProfileRequestDtoValidator : AbstractValidator<DeleteProfileRequestDto>
{
    public DeleteProfileRequestDtoValidator()
    {
        RuleFor(x => x.Password)
            .NotEmpty()
            .WithMessage("Password is required to delete your account.");
    }
}
