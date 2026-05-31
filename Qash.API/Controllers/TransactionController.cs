using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Qash.API.Features.Transactions.Commands;
using Qash.API.Features.Transactions.Queries;
using System;
using System.Security.Claims;
using System.Threading.Tasks;

namespace Qash.API.Controllers;

[ApiController]
[Authorize]
[Route("api/transactions")]
public class TransactionController : ControllerBase
{
    private readonly IMediator _mediator;

    public TransactionController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpPost]
    public async Task<IActionResult> CreateTransaction([FromBody] CreateTransactionCommand command)
    {
        var userId = GetCurrentUserId();

        if (userId is null)
            return Unauthorized();

        command.UserId = userId.Value;

        var response = await _mediator.Send(command);
        return response.Success ? Ok(response) : BadRequest(response);
    }

    [HttpGet]
    public async Task<IActionResult> GetTransactions([FromQuery] Guid? walletId = null)
    {
        var userId = GetCurrentUserId();

        if (userId is null)
            return Unauthorized();

        var response = await _mediator.Send(new GetTransactionsQuery(userId.Value, walletId));
        return response.Success ? Ok(response) : BadRequest(response);
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetTransactionById([FromRoute] Guid id)
    {
        var userId = GetCurrentUserId();

        if (userId is null)
            return Unauthorized();

        var response = await _mediator.Send(new GetTransactionByIdQuery(userId.Value, id));
        return response.Success ? Ok(response) : NotFound(response);
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> UpdateTransaction([FromRoute] Guid id, [FromBody] UpdateTransactionCommand command)
    {
        var userId = GetCurrentUserId();

        if (userId is null)
            return Unauthorized();

        command.UserId = userId.Value;
        command.TransactionId = id;

        var response = await _mediator.Send(command);
        return response.Success ? Ok(response) : BadRequest(response);
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> DeleteTransaction([FromRoute] Guid id)
    {
        var userId = GetCurrentUserId();

        if (userId is null)
            return Unauthorized();

        var response = await _mediator.Send(new DeleteTransactionCommand
        {
            UserId = userId.Value,
            TransactionId = id
        });

        return response.Success ? Ok(response) : BadRequest(response);
    }

    private Guid? GetCurrentUserId()
    {
        var userIdValue = User.FindFirstValue(ClaimTypes.NameIdentifier);

        if (!Guid.TryParse(userIdValue, out var userId))
            return null;

        return userId;
    }
}