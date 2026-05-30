using Qash.API.Domain.Common;

namespace Qash.API.Domain.Entities;

public class Budget : BaseEntity
{
    public Guid ApplicationUserId { get; set; }

    public ApplicationUser ApplicationUser { get; set; } = null!;

    public Guid CategoryId { get; set; }

    public Category Category { get; set; } = null!;

    public int Year { get; set; }

    public int Month { get; set; }

    public decimal Amount { get; set; }

    /// <summary>Budget limit currency (ISO code).</summary>
    public string Currency { get; set; } = "USD";
}
