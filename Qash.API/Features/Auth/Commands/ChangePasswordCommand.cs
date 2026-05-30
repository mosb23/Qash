using MediatR;
using Qash.API.Common.Responses;
using System;

namespace Qash.API.Features.Auth.Commands;

public class ChangePasswordCommand : IRequest<ApiResponse<string>>
{
    public Guid UserId { get; set; }
    public string OldPassword { get; set; } = string.Empty;
    public string NewPassword { get; set; } = string.Empty;
    public string ConfirmPassword { get; set; } = string.Empty;
}