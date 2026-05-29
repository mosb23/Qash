using MediatR;
using Microsoft.EntityFrameworkCore;
using Qash.API.Common.Responses;
using Qash.API.Features.Auth.Commands;
using Qash.API.Infrastructure.Data;
using Qash.API.Infrastructure.Services;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Qash.API.Features.Auth.Handlers;

public class ChangePasswordCommandHandler
    : IRequestHandler<ChangePasswordCommand, ApiResponse<string>>
{
    private readonly ApplicationDbContext _context;
    private readonly IPasswordHasherService _passwordHasherService;

    public ChangePasswordCommandHandler(
        ApplicationDbContext context,
        IPasswordHasherService passwordHasherService)
    {
        _context = context;
        _passwordHasherService = passwordHasherService;
    }

    public async Task<ApiResponse<string>> Handle(
        ChangePasswordCommand request,
        CancellationToken cancellationToken)
    {
        var user = await _context.Users
            .FirstOrDefaultAsync(x => x.Id == request.UserId, cancellationToken);

        if (user is null)
        {
            return ApiResponse<string>.FailResponse(
                "Change password failed.",
                ["User not found."]);
        }

        var oldPasswordValid = _passwordHasherService.VerifyPassword(
            request.OldPassword,
            user.PasswordHash);

        if (!oldPasswordValid)
        {
            return ApiResponse<string>.FailResponse(
                "Change password failed.",
                ["Old password is incorrect."]);
        }

        user.PasswordHash = _passwordHasherService.HashPassword(request.NewPassword);
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
            "Password changed",
            "Password changed successfully.");
    }
}