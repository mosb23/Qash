using MediatR;
using Qash.API.Common.Responses;
using Qash.API.Features.Profile.DTOs;
using System;

namespace Qash.API.Features.Profile.Commands;

public class UpdateProfileCommand : IRequest<ApiResponse<ProfileDto>>
{
    public Guid UserId { get; set; }

    public string FirstName { get; set; } = string.Empty;

    public string LastName { get; set; } = string.Empty;

    public string Email { get; set; } = string.Empty;

    public string PhoneNumber { get; set; } = string.Empty;

    public string PreferredCurrency { get; set; } = "USD";
}