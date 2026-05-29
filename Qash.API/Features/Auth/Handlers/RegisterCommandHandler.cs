using MediatR;
using Microsoft.EntityFrameworkCore;
using Qash.API.Common.Responses;
using Qash.API.Domain.Entities;
using Qash.API.Features.Auth.Commands;
using Qash.API.Features.Auth.DTOs;
using Qash.API.Infrastructure.Data;
using Qash.API.Infrastructure.Services;
using Qash.API.Domain.Enums;

namespace Qash.API.Features.Auth.Handlers;

public class RegisterCommandHandler : IRequestHandler<RegisterCommand, ApiResponse<AuthResponseDto>>
{
    private readonly ApplicationDbContext _context;
    private readonly IPasswordHasherService _passwordHasherService;

    public RegisterCommandHandler(
        ApplicationDbContext context,
        IPasswordHasherService passwordHasherService)
    {
        _context = context;
        _passwordHasherService = passwordHasherService;
    }

    public async Task<ApiResponse<AuthResponseDto>> Handle(RegisterCommand request, CancellationToken cancellationToken)
    {
        var email = request.Email.Trim().ToLower();
        var phone = request.PhoneNumber.Trim();

        var exists = await _context.Users.AnyAsync(
            x => x.Email == email || x.PhoneNumber == phone,
            cancellationToken);

        if (exists)
        {
            return ApiResponse<AuthResponseDto>.FailResponse(
                "Registration failed.",
                ["Email or phone number already exists."]);
        }

        var user = new ApplicationUser
        {
            FirstName = request.FirstName.Trim(),
            LastName = request.LastName.Trim(),
            Email = email,
            PhoneNumber = phone,
            IsPhoneNumberVerified = false,
            PasswordHash = _passwordHasherService.HashPassword(request.Password)
        };

        await _context.Users.AddAsync(user, cancellationToken);
        var defaultCategories = GetDefaultCategories(user.Id);
        await _context.Categories.AddRangeAsync(defaultCategories, cancellationToken);
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
                AccessToken = string.Empty,
                RefreshToken = string.Empty
            },
            "Registration completed successfully. Please verify your phone number using code 00000.");
    }

    private List<Category> GetDefaultCategories(Guid userId)
    {
        return new List<Category>
    {
        // Expense
        new() { Name = "Food", Type = CategoryType.Expense, ApplicationUserId = userId },
        new() { Name = "Transport", Type = CategoryType.Expense, ApplicationUserId = userId },
        new() { Name = "Shopping", Type = CategoryType.Expense, ApplicationUserId = userId },
        new() { Name = "Bills", Type = CategoryType.Expense, ApplicationUserId = userId },
        new() { Name = "Health", Type = CategoryType.Expense, ApplicationUserId = userId },
        new() { Name = "Education", Type = CategoryType.Expense, ApplicationUserId = userId },
        new() { Name = "Entertainment", Type = CategoryType.Expense, ApplicationUserId = userId },
        new() { Name = "Transfer", Type = CategoryType.Transfer, ApplicationUserId = userId },

        // Income
        new() { Name = "Salary", Type = CategoryType.Income, ApplicationUserId = userId },
        new() { Name = "Freelance", Type = CategoryType.Income, ApplicationUserId = userId },
        new() { Name = "Gift", Type = CategoryType.Income, ApplicationUserId = userId },
        new() { Name = "Other", Type = CategoryType.Income, ApplicationUserId = userId }
    };
    }
}