using Qash.API.Domain.Common;
using System.Collections.Generic;

namespace Qash.API.Domain.Entities;

public class ApplicationUser : BaseEntity
{
    public string FirstName { get; set; } = string.Empty;

    public string LastName { get; set; } = string.Empty;

    public string Email { get; set; } = string.Empty;

    public string PhoneNumber { get; set; } = string.Empty;

    public bool IsPhoneNumberVerified { get; set; } = false;

    public string PasswordHash { get; set; } = string.Empty;

    /// <summary>
    /// User's preferred display currency for aggregated totals (ISO code).
    /// </summary>
    public string PreferredCurrency { get; set; } = "USD";

    public List<RefreshToken> RefreshTokens { get; set; } = [];

    public List<Wallet> Wallets { get; set; } = [];

    public List<Transaction> Transactions { get; set; } = [];

    public List<Category> Categories { get; set; } = [];

    public string FullName => $"{FirstName} {LastName}";

}