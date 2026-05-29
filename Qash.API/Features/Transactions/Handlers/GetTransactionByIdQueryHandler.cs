using AutoMapper;
using MediatR;
using Microsoft.EntityFrameworkCore;
using Qash.API.Common.Responses;
using Qash.API.Features.Transactions.DTOs;
using Qash.API.Features.Transactions.Queries;
using Qash.API.Infrastructure.Data;
using System.Threading;
using System.Threading.Tasks;

namespace Qash.API.Features.Transactions.Handlers;

public class GetTransactionByIdQueryHandler : IRequestHandler<GetTransactionByIdQuery, ApiResponse<TransactionDto>>
{
    private readonly ApplicationDbContext _context;
    private readonly IMapper _mapper;

    public GetTransactionByIdQueryHandler(ApplicationDbContext context, IMapper mapper)
    {
        _context = context;
        _mapper = mapper;
    }

    public async Task<ApiResponse<TransactionDto>> Handle(GetTransactionByIdQuery request, CancellationToken cancellationToken)
    {
        var transaction = await _context.Transactions
            .AsNoTracking()
            .Include(x => x.Wallet)
            .Include(x => x.ToWallet)
            .FirstOrDefaultAsync(x => x.Id == request.TransactionId && x.ApplicationUserId == request.UserId, cancellationToken);

        if (transaction is null)
        {
            return ApiResponse<TransactionDto>.FailResponse("Transaction not found.", ["Transaction was not found."]);
        }

        var dto = _mapper.Map<TransactionDto>(transaction);

        return ApiResponse<TransactionDto>.SuccessResponse(dto, "Transaction retrieved successfully.");
    }
}