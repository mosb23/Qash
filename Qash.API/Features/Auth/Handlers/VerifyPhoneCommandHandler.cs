using MediatR;
using Microsoft.EntityFrameworkCore;
using Qash.API.Common.Responses;
using Qash.API.Domain.Entities;
using Qash.API.Features.Auth.Commands;
using Qash.API.Features.Auth.DTOs;
using Qash.API.Infrastructure.Data;
using Qash.API.Infrastructure.Authentication;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Qash.API.Features.Auth.Handlers;

public class VerifyPhoneCommandHandler : IRequestHandler<VerifyPhoneCommand, ApiResponse<AuthResponseDto>>
{
    private readonly ApplicationDbContext _context;
    private readonly IConfiguration _configuration;
    private readonly IJwtTokenService _jwtTokenService;

    public VerifyPhoneCommandHandler(
        ApplicationDbContext context,
        IConfiguration configuration,
        IJwtTokenService jwtTokenService)
    {
        _context = context;
        _configuration = configuration;
        _jwtTokenService = jwtTokenService;
    }

    public async Task<ApiResponse<AuthResponseDto>> Handle(VerifyPhoneCommand request, CancellationToken cancellationToken)
    {
        var demoCode = _configuration["DemoOtp:VerificationCode"] ?? "00000";

        if (request.VerificationCode != demoCode)
        {
            return ApiResponse<AuthResponseDto>.FailResponse(
                "Phone verification failed.",
                ["Invalid verification code."]);
        }

        var phone = request.PhoneNumber.Trim();

        var user = await _context.Users
            .FirstOrDefaultAsync(x => x.PhoneNumber == phone, cancellationToken);

        if (user is null)
        {
            return ApiResponse<AuthResponseDto>.FailResponse(
                "Phone verification failed.",
                ["No account found with this phone number."]);
        }

        if (!user.IsPhoneNumberVerified)
        {
            user.IsPhoneNumberVerified = true;
            user.UpdatedAt = DateTime.UtcNow;
        }

        await _context.RefreshTokens
            .Where(x =>
                x.ApplicationUserId == user.Id &&
                !x.IsRevoked &&
                !x.IsDeleted &&
                x.ExpiresAt > DateTime.UtcNow)
            .ExecuteUpdateAsync(setters => setters
                .SetProperty(x => x.IsRevoked, true)
                .SetProperty(x => x.RevokedAt, DateTime.UtcNow)
                .SetProperty(x => x.UpdatedAt, DateTime.UtcNow),
                cancellationToken);

        var tokenResult = _jwtTokenService.GenerateTokens(user);
        var refreshToken = new RefreshToken
        {
            Token = tokenResult.RefreshToken,
            ExpiresAt = tokenResult.RefreshTokenExpiresAt,
            ApplicationUserId = user.Id
        };
        await _context.RefreshTokens.AddAsync(refreshToken, cancellationToken);

        await _context.SaveChangesAsync(cancellationToken);

        return ApiResponse<AuthResponseDto>.SuccessResponse(
            new AuthResponseDto
            {
                UserId = user.Id,
                FirstName = user.FirstName,
                LastName = user.LastName,
                FullName = user.FullName,
                Email = user.Email,
                PhoneNumber = user.PhoneNumber,
                AccessToken = tokenResult.AccessToken,
                RefreshToken = tokenResult.RefreshToken
            },
            "Phone number verified successfully.");
    }
}