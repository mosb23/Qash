using MediatR;
using Microsoft.EntityFrameworkCore;
using Qash.API.Common.Responses;
using Qash.API.Features.Auth.Commands;
using Qash.API.Features.Auth.DTOs;
using Qash.API.Infrastructure.Data;
using Qash.API.Infrastructure.Demo;
using System.Threading;
using System.Threading.Tasks;

namespace Qash.API.Features.Auth.Handlers;

public class RequestForgotPasswordCodeCommandHandler
    : IRequestHandler<RequestForgotPasswordCodeCommand, ApiResponse<ForgotPasswordCodeResponseDto>>
{
    private readonly ApplicationDbContext _context;
    private readonly IConfiguration _configuration;

    public RequestForgotPasswordCodeCommandHandler(
        ApplicationDbContext context,
        IConfiguration configuration)
    {
        _context = context;
        _configuration = configuration;
    }

    public async Task<ApiResponse<ForgotPasswordCodeResponseDto>> Handle(
        RequestForgotPasswordCodeCommand request,
        CancellationToken cancellationToken)
    {
        var phone = request.PhoneNumber.Trim();

        var userExists = await _context.Users
            .AnyAsync(x => x.PhoneNumber == phone, cancellationToken);

        // Generic message to limit account enumeration; demo code only when account exists.
        var demoCode = userExists
            ? DemoOtpOptions.GetVerificationCode(_configuration)
            : string.Empty;

        return ApiResponse<ForgotPasswordCodeResponseDto>.SuccessResponse(
            new ForgotPasswordCodeResponseDto
            {
                PhoneNumber = phone,
                VerificationCode = demoCode
            },
            "If an account exists for this phone number, a verification code was sent.");
    }
}