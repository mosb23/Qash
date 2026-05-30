using AutoMapper;
using Qash.API.Domain.Entities;
using Qash.API.Features.Auth.DTOs;
using Qash.API.Features.Profile.DTOs;
using Qash.API.Features.Transactions.DTOs;
using Qash.API.Features.Wallet.DTOs;
using Qash.API.Features.Categories.DTOs;
using Qash.API.Features.Budgets.DTOs;
using Qash.API.Features.SavingGoals.DTOs;
using Qash.API.Features.RecurringTransactions.DTOs;

using TransactionEntity = Qash.API.Domain.Entities.Transaction;
using TransactionDtoModel = Qash.API.Features.Transactions.DTOs.TransactionDto;
using RecurringTransactionEntity = Qash.API.Domain.Entities.RecurringTransaction;
using RecurringTransactionDtoModel = Qash.API.Features.RecurringTransactions.DTOs.RecurringTransactionDto;

namespace Qash.API.Infrastructure.Mapping;

public class MappingProfile : Profile
{
    public MappingProfile()
    {
        CreateMap<ApplicationUser, AuthResponseDto>()
            .ForMember(dest => dest.UserId, opt => opt.MapFrom(src => src.Id))
            .ForMember(dest => dest.FullName, opt => opt.MapFrom(src => src.FullName));

        CreateMap<ApplicationUser, ProfileDto>()
            .ForMember(dest => dest.UserId, opt => opt.MapFrom(src => src.Id))
            .ForMember(dest => dest.FullName, opt => opt.MapFrom(src => src.FullName));

        CreateMap<Wallet, WalletDto>()
            .ForMember(dest => dest.WalletId, opt => opt.MapFrom(src => src.Id))
            .ForMember(dest => dest.UserId, opt => opt.MapFrom(src => src.ApplicationUserId));

        CreateMap<TransactionEntity, TransactionDtoModel>()
            .ForMember(dest => dest.TransactionId, opt => opt.MapFrom(src => src.Id))
            .ForMember(dest => dest.WalletId, opt => opt.MapFrom(src => src.WalletId))
            .ForMember(dest => dest.WalletName, opt => opt.MapFrom(src => src.Wallet.Name))
            .ForMember(dest => dest.WalletCurrency, opt => opt.MapFrom(src => src.Wallet.Currency))
            .ForMember(dest => dest.UserId, opt => opt.MapFrom(src => src.ApplicationUserId))
            .ForMember(dest => dest.ToWalletId, opt => opt.MapFrom(src => src.ToWalletId))
            .ForMember(
                dest => dest.ToWalletName,
                opt => opt.MapFrom(src => src.ToWallet != null ? src.ToWallet.Name : null))
            .ForMember(
                dest => dest.ToWalletCurrency,
                opt => opt.MapFrom(src => src.ToWallet != null ? src.ToWallet.Currency : null))
            .ForMember(dest => dest.SourceCurrency, opt => opt.MapFrom(src => src.SourceCurrency))
            .ForMember(dest => dest.DestinationCurrency, opt => opt.MapFrom(src => src.DestinationCurrency))
            .ForMember(dest => dest.AmountInBaseCurrency, opt => opt.MapFrom(src => src.AmountInBaseCurrency))
            .ForMember(dest => dest.ExchangeRateUsed, opt => opt.MapFrom(src => src.ExchangeRateUsed))
            .ForMember(dest => dest.TransferGroupId, opt => opt.MapFrom(src => src.TransferGroupId))
            .ForMember(dest => dest.LinkedTransactionId, opt => opt.MapFrom(src => src.LinkedTransactionId));

        CreateMap<Category, CategoryDto>();

        CreateMap<Budget, BudgetDto>()
            .ForMember(dest => dest.BudgetId, opt => opt.MapFrom(src => src.Id))
            .ForMember(dest => dest.CategoryName, opt => opt.MapFrom(src => src.Category.Name));

        CreateMap<SavingGoal, SavingGoalDto>()
            .ForMember(dest => dest.SavingGoalId, opt => opt.MapFrom(src => src.Id))
            .ForMember(dest => dest.Currency, opt => opt.MapFrom(src => src.Currency))
            .AfterMap((src, dest) =>
            {
                dest.ProgressPercent = src.TargetAmount <= 0
                    ? 0
                    : Math.Min(100, Math.Round(src.CurrentAmount / src.TargetAmount * 100m, 2));
            });

        CreateMap<RecurringTransactionEntity, RecurringTransactionDtoModel>()
            .ForMember(dest => dest.RecurringTransactionId, opt => opt.MapFrom(src => src.Id))
            .ForMember(dest => dest.WalletName, opt => opt.MapFrom(src => src.Wallet.Name))
            .ForMember(dest => dest.CategoryName, opt => opt.MapFrom(src => src.Category.Name));
    }
}