using Microsoft.EntityFrameworkCore;
using Qash.API.Domain.Common;
using Qash.API.Domain.Entities;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Qash.API.Infrastructure.Data;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {
    }

    public DbSet<ApplicationUser> Users => Set<ApplicationUser>();
    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();
    public DbSet<Wallet> Wallets => Set<Wallet>();
    public DbSet<Transaction> Transactions => Set<Transaction>();
    public DbSet<Category> Categories => Set<Category>();
    public DbSet<Budget> Budgets => Set<Budget>();
    public DbSet<SavingGoal> SavingGoals => Set<SavingGoal>();
    public DbSet<RecurringTransaction> RecurringTransactions => Set<RecurringTransaction>();

    public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        ApplyAuditInfo();
        return base.SaveChangesAsync(cancellationToken);
    }

    public override int SaveChanges()
    {
        ApplyAuditInfo();
        return base.SaveChanges();
    }

    private void ApplyAuditInfo()
    {
        var entries = ChangeTracker
            .Entries<BaseEntity>()
            .Where(e => e.State is EntityState.Added or EntityState.Modified or EntityState.Deleted);

        foreach (var entry in entries)
        {
            if (entry.State == EntityState.Added)
            {
                entry.Entity.CreatedAt = DateTime.UtcNow;
            }

            if (entry.State == EntityState.Modified)
            {
                entry.Entity.UpdatedAt = DateTime.UtcNow;
            }

            if (entry.State == EntityState.Deleted)
            {
                entry.State = EntityState.Modified;
                entry.Entity.IsDeleted = true;
                entry.Entity.DeletedAt = DateTime.UtcNow;
            }
        }
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<ApplicationUser>(entity =>
        {
            entity.ToTable("Users");

            entity.HasKey(x => x.Id);

            entity.Property(x => x.FirstName)
                .IsRequired()
                .HasMaxLength(100);

            entity.Property(x => x.LastName)
                .IsRequired()
                .HasMaxLength(100);

            entity.Property(x => x.Email)
                .IsRequired()
                .HasMaxLength(200);

            entity.Property(x => x.PhoneNumber)
                .IsRequired()
                .HasMaxLength(20);

            entity.HasIndex(x => x.Email)
                .IsUnique()
                .HasFilter("\"IsDeleted\" = FALSE");

            entity.HasIndex(x => x.PhoneNumber)
                .IsUnique()
                .HasFilter("\"IsDeleted\" = FALSE");

            entity.Property(x => x.PasswordHash)
                .IsRequired();

            entity.Property(x => x.PreferredCurrency)
                .IsRequired()
                .HasMaxLength(10)
                .HasDefaultValue("USD");

            entity.HasQueryFilter(x => !x.IsDeleted);
        });

        modelBuilder.Entity<RefreshToken>(entity =>
        {
            entity.ToTable("RefreshTokens");

            entity.HasKey(x => x.Id);

            entity.Property(x => x.Token)
                .IsRequired();

            entity.Property(x => x.ExpiresAt)
                .IsRequired();

            entity.HasOne(x => x.ApplicationUser)
                .WithMany(x => x.RefreshTokens)
                .HasForeignKey(x => x.ApplicationUserId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasQueryFilter(x => !x.IsDeleted);
        });

        modelBuilder.Entity<Wallet>(entity =>
        {
            entity.ToTable("Wallets");

            entity.HasKey(x => x.Id);

            entity.Property(x => x.Name)
                .IsRequired()
                .HasMaxLength(100);

            entity.Property(x => x.Currency)
                .IsRequired()
                .HasMaxLength(10);

            entity.Property(x => x.Balance)
                .HasPrecision(18, 2)
                .IsRequired();

            entity.HasOne(x => x.ApplicationUser)
                .WithMany(x => x.Wallets)
                .HasForeignKey(x => x.ApplicationUserId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasIndex(x => new { x.ApplicationUserId, x.Name });

            entity.HasQueryFilter(x => !x.IsDeleted);
        });

        modelBuilder.Entity<Transaction>(entity =>
        {
            entity.ToTable("Transactions");

            entity.HasKey(x => x.Id);

            entity.Property(x => x.TransactionType)
                .IsRequired();

            entity.Property(x => x.Amount)
                .HasColumnType("decimal(18,2)")
                .IsRequired();

            entity.Property(x => x.ToAmount)
                .HasColumnType("decimal(18,2)");

            entity.Property(x => x.SourceCurrency)
                .IsRequired()
                .HasMaxLength(10)
                .HasDefaultValue("USD");

            entity.Property(x => x.DestinationCurrency)
                .HasMaxLength(10);

            entity.Property(x => x.AmountInBaseCurrency)
                .HasColumnType("decimal(18,2)")
                .HasDefaultValue(0m);

            entity.Property(x => x.ExchangeRateUsed)
                .HasColumnType("decimal(18,6)");

            entity.Property(x => x.Description)
                .HasMaxLength(500);

            entity.Property(x => x.TransactionDate)
                .IsRequired();

            entity.HasOne(x => x.ApplicationUser)
                .WithMany(x => x.Transactions)
                .HasForeignKey(x => x.ApplicationUserId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(x => x.Wallet)
                .WithMany(x => x.Transactions)
                .HasForeignKey(x => x.WalletId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(x => x.ToWallet)
                .WithMany()
                .HasForeignKey(x => x.ToWalletId)
                .OnDelete(DeleteBehavior.Restrict)
                .IsRequired(false);

            entity.HasOne(x => x.Category)
                .WithMany(x => x.Transactions)
                .HasForeignKey(x => x.CategoryId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasQueryFilter(x => !x.IsDeleted);
        });

        modelBuilder.Entity<Category>(entity =>
        {
            entity.ToTable("Categories");

            entity.HasKey(x => x.Id);

            entity.Property(x => x.Name)
                .IsRequired()
                .HasMaxLength(100);

            entity.Property(x => x.Type)
                .IsRequired();

            entity.Property(x => x.Icon)
                .HasMaxLength(100);

            entity.Property(x => x.Color)
                .HasMaxLength(20);

            entity.HasOne(x => x.ApplicationUser)
                .WithMany(x => x.Categories)
                .HasForeignKey(x => x.ApplicationUserId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasIndex(x => new { x.ApplicationUserId, x.Name, x.Type })
                .IsUnique();

            entity.HasQueryFilter(x => !x.IsDeleted);
        });

        modelBuilder.Entity<Budget>(entity =>
        {
            entity.ToTable("Budgets");

            entity.HasKey(x => x.Id);

            entity.Property(x => x.Amount)
                .HasPrecision(18, 2)
                .IsRequired();

            entity.Property(x => x.Currency)
                .IsRequired()
                .HasMaxLength(10)
                .HasDefaultValue("USD");

            entity.HasOne(x => x.ApplicationUser)
                .WithMany()
                .HasForeignKey(x => x.ApplicationUserId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(x => x.Category)
                .WithMany()
                .HasForeignKey(x => x.CategoryId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasIndex(x => new { x.ApplicationUserId, x.CategoryId, x.Year, x.Month })
                .IsUnique()
                .HasFilter("\"IsDeleted\" = FALSE");

            entity.HasQueryFilter(x => !x.IsDeleted);
        });

        modelBuilder.Entity<SavingGoal>(entity =>
        {
            entity.ToTable("SavingGoals");

            entity.HasKey(x => x.Id);

            entity.Property(x => x.Name)
                .IsRequired()
                .HasMaxLength(150);

            entity.Property(x => x.TargetAmount)
                .HasPrecision(18, 2)
                .IsRequired();

            entity.Property(x => x.CurrentAmount)
                .HasPrecision(18, 2)
                .IsRequired();

            entity.Property(x => x.Currency)
                .IsRequired()
                .HasMaxLength(10)
                .HasDefaultValue("USD");

            entity.Property(x => x.Deadline)
                .IsRequired();

            entity.HasOne(x => x.ApplicationUser)
                .WithMany()
                .HasForeignKey(x => x.ApplicationUserId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasQueryFilter(x => !x.IsDeleted);
        });

        modelBuilder.Entity<RecurringTransaction>(entity =>
        {
            entity.ToTable("RecurringTransactions");

            entity.HasKey(x => x.Id);

            entity.Property(x => x.Amount)
                .HasPrecision(18, 2)
                .IsRequired();

            entity.Property(x => x.Description)
                .HasMaxLength(500);

            entity.Property(x => x.TransactionType)
                .IsRequired();

            entity.Property(x => x.Frequency)
                .IsRequired();

            entity.Property(x => x.NextRunAt)
                .IsRequired();

            entity.HasOne(x => x.ApplicationUser)
                .WithMany()
                .HasForeignKey(x => x.ApplicationUserId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(x => x.Wallet)
                .WithMany()
                .HasForeignKey(x => x.WalletId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(x => x.Category)
                .WithMany()
                .HasForeignKey(x => x.CategoryId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasIndex(x => new { x.IsActive, x.NextRunAt });

            entity.HasQueryFilter(x => !x.IsDeleted);
        });
    }
}