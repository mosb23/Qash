using MediatR;
using Microsoft.EntityFrameworkCore;
using Qash.API.Common.Responses;
using Qash.API.Features.Profile.Commands;
using Qash.API.Infrastructure.Data;
using Qash.API.Infrastructure.Services;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Qash.API.Features.Profile.Handlers;

public class DeleteProfileCommandHandler : IRequestHandler<DeleteProfileCommand, ApiResponse<string>>
{
    private readonly ApplicationDbContext _context;
    private readonly IPasswordHasherService _passwordHasherService;

    public DeleteProfileCommandHandler(
        ApplicationDbContext context,
        IPasswordHasherService passwordHasherService)
    {
        _context = context;
        _passwordHasherService = passwordHasherService;
    }

    public async Task<ApiResponse<string>> Handle(DeleteProfileCommand request, CancellationToken cancellationToken)
    {
        var user = await _context.Users
            .FirstOrDefaultAsync(x => x.Id == request.UserId, cancellationToken);

        if (user is null)
        {
            return ApiResponse<string>.FailResponse(
                "Delete profile failed.",
                ["User profile was not found."]);
        }

        var validPassword = _passwordHasherService.VerifyPassword(
            request.Password,
            user.PasswordHash);

        if (!validPassword)
        {
            return ApiResponse<string>.FailResponse(
                "Delete profile failed.",
                ["Incorrect password."]);
        }

        user.IsDeleted = true;
        user.DeletedAt = DateTime.UtcNow;
        user.UpdatedAt = DateTime.UtcNow;

        await _context.RefreshTokens
            .Where(x => x.ApplicationUserId == user.Id && !x.IsRevoked && !x.IsDeleted)
            .ExecuteUpdateAsync(setters => setters
                .SetProperty(x => x.IsRevoked, true)
                .SetProperty(x => x.RevokedAt, DateTime.UtcNow)
                .SetProperty(x => x.UpdatedAt, DateTime.UtcNow),
                cancellationToken);

        await _context.SaveChangesAsync(cancellationToken);

        return ApiResponse<string>.SuccessResponse(
            "Profile deleted",
            "Profile deleted successfully.");
    }
}