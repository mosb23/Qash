using MediatR;
using Qash.API.Common.Responses;
using Qash.API.Features.Auth.DTOs;

namespace Qash.API.Features.Auth.Commands;

public class VerifyPhoneCommand : IRequest<ApiResponse<AuthResponseDto>>
{
    public string PhoneNumber { get; set; } = string.Empty;

    public string VerificationCode { get; set; } = string.Empty;
}