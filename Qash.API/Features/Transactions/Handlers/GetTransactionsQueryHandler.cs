using AutoMapper;
using MediatR;
using Microsoft.EntityFrameworkCore;
using Qash.API.Common.Responses;
using Qash.API.Features.Transactions.DTOs;
using Qash.API.Features.Transactions.Queries;
using Qash.API.Infrastructure.Data;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Qash.API.Features.Transactions.Handlers;

public class GetTransactionsQueryHandler : IRequestHandler<GetTransactionsQuery, ApiResponse<List<TransactionDto>>>
{
    private readonly ApplicationDbContext _context;
    private readonly IMapper _mapper;

    public GetTransactionsQueryHandler(ApplicationDbContext context, IMapper mapper)
    {
        _context = context;
        _mapper = mapper;
    }

    public async Task<ApiResponse<List<TransactionDto>>> Handle(GetTransactionsQuery request, CancellationToken cancellationToken)
    {
        var transactions = await _context.Transactions
            .AsNoTracking()
            .Include(x => x.Wallet)
            .Include(x => x.Category)
            .Include(x => x.ToWallet)
            .Where(x => x.ApplicationUserId == request.UserId)
            .OrderByDescending(x => x.TransactionDate)
            .ThenByDescending(x => x.CreatedAt)
            .ToListAsync(cancellationToken);

        var dto = _mapper.Map<List<TransactionDto>>(transactions);

        return ApiResponse<List<TransactionDto>>.SuccessResponse(dto, "Transactions retrieved successfully.");
    }
}