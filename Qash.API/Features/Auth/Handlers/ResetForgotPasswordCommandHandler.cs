using MediatR;
using Microsoft.EntityFrameworkCore;
using Qash.API.Common.Responses;
using Qash.API.Features.Auth.Commands;
using Qash.API.Infrastructure.Data;
using Qash.API.Infrastructure.Demo;
using Qash.API.Infrastructure.Services;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Qash.API.Features.Auth.Handlers;

public class ResetForgotPasswordCommandHandler
    : IRequestHandler<ResetForgotPasswordCommand, ApiResponse<string>>
{
    private readonly ApplicationDbContext _context;
    private readonly IPasswordHasherService _passwordHasherService;
    private readonly IConfiguration _configuration;

    public ResetForgotPasswordCommandHandler(
        ApplicationDbContext context,
        IPasswordHasherService passwordHasherService,
        IConfiguration configuration)
    {
        _context = context;
        _passwordHasherService = passwordHasherService;
        _configuration = configuration;
    }

    public async Task<ApiResponse<string>> Handle(
        ResetForgotPasswordCommand request,
        CancellationToken cancellationToken)
    {
        // Demo/university only — server-side check; never trust client-only delays.
        var demoCode = DemoOtpOptions.GetVerificationCode(_configuration);

        if (request.VerificationCode != demoCode)
        {
            return ApiResponse<string>.FailResponse(
                "Reset password failed.",
                ["Invalid verification code."]);
        }

        var phone = request.PhoneNumber.Trim();

        var user = await _context.Users
            .FirstOrDefaultAsync(x => x.PhoneNumber == phone, cancellationToken);

        if (user is null)
        {
            return ApiResponse<string>.FailResponse(
                "Reset password failed.",
                ["No account found with this phone number."]);
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
            "Password reset",
            "Password reset successfully.");
    }
}