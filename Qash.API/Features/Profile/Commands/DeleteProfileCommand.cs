using MediatR;
using Qash.API.Common.Responses;
using System;

namespace Qash.API.Features.Profile.Commands;

public class DeleteProfileCommand : IRequest<ApiResponse<string>>
{
    public Guid UserId { get; set; }

    public string Password { get; set; } = string.Empty;

    public DeleteProfileCommand(Guid userId, string password)
    {
        UserId = userId;
        Password = password;
    }
}