using AutoMapper;
using MediatR;
using Microsoft.EntityFrameworkCore;
using Qash.API.Common.Responses;
using Qash.API.Features.Profile.Commands;
using Qash.API.Features.Profile.DTOs;
using Qash.API.Infrastructure.Data;
using Qash.API.Infrastructure.Services;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Qash.API.Features.Profile.Handlers;

public class UpdateProfileCommandHandler : IRequestHandler<UpdateProfileCommand, ApiResponse<ProfileDto>>
{
    private readonly ApplicationDbContext _context;
    private readonly IMapper _mapper;

    public UpdateProfileCommandHandler(ApplicationDbContext context, IMapper mapper)
    {
        _context = context;
        _mapper = mapper;
    }

    public async Task<ApiResponse<ProfileDto>> Handle(UpdateProfileCommand request, CancellationToken cancellationToken)
    {
        var user = await _context.Users
            .FirstOrDefaultAsync(x => x.Id == request.UserId, cancellationToken);

        if (user is null)
        {
            return ApiResponse<ProfileDto>.FailResponse(
                "Update profile failed.",
                ["User profile was not found."]);
        }

        var email = request.Email.Trim().ToLower();
        var incomingPhone = request.PhoneNumber.Trim();

        if (!string.IsNullOrEmpty(incomingPhone) && incomingPhone != user.PhoneNumber)
        {
            return ApiResponse<ProfileDto>.FailResponse(
                "Update profile failed.",
                ["Phone number cannot be changed after account creation."]);
        }

        var emailExists = await _context.Users
            .AnyAsync(x => x.Id != request.UserId && x.Email == email, cancellationToken);

        if (emailExists)
        {
            return ApiResponse<ProfileDto>.FailResponse(
                "Update profile failed.",
                ["Email is already used by another account."]);
        }

        user.FirstName = request.FirstName.Trim();
        user.LastName = request.LastName.Trim();
        user.Email = email;
        user.PreferredCurrency = UserCurrencyResolver.NormalizeDisplayCurrency(
            request.PreferredCurrency);
        user.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync(cancellationToken);

        var profile = _mapper.Map<ProfileDto>(user);

        return ApiResponse<ProfileDto>.SuccessResponse(
            profile,
            "Profile updated successfully.");
    }
}