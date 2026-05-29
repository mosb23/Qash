using FluentValidation;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Qash.API.Features.Budgets.Commands;
using Qash.API.Features.Budgets.Queries;
using System.Security.Claims;

namespace Qash.API.Controllers;

[ApiController]
[Authorize]
[Route("api/budgets")]
public class BudgetsController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly IValidator<GetBudgetStatusesQuery> _getBudgetStatusesValidator;

    public BudgetsController(
        IMediator mediator,
        IValidator<GetBudgetStatusesQuery> getBudgetStatusesValidator)
    {
        _mediator = mediator;
        _getBudgetStatusesValidator = getBudgetStatusesValidator;
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id)
    {
        var userId = GetCurrentUserId();
        if (userId is null)
            return Unauthorized();

        var response = await _mediator.Send(new GetBudgetByIdQuery(userId.Value, id));
        return response.Success ? Ok(response) : NotFound(response);
    }

    [HttpGet("status")]
    public async Task<IActionResult> GetStatuses([FromQuery] int year, [FromQuery] int month)
    {
        var userId = GetCurrentUserId();
        if (userId is null)
            return Unauthorized();

        var query = new GetBudgetStatusesQuery(userId.Value, year, month);
        var validation = await _getBudgetStatusesValidator.ValidateAsync(query);
        if (!validation.IsValid)
            return BadRequest(new { Errors = validation.Errors.Select(e => e.ErrorMessage).ToArray() });

        var response = await _mediator.Send(query);
        return response.Success ? Ok(response) : BadRequest(response);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateBudgetCommand command)
    {
        var userId = GetCurrentUserId();
        if (userId is null)
            return Unauthorized();

        command.UserId = userId.Value;
        var response = await _mediator.Send(command);
        return response.Success ? Ok(response) : BadRequest(response);
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateBudgetCommand command)
    {
        var userId = GetCurrentUserId();
        if (userId is null)
            return Unauthorized();

        command.UserId = userId.Value;
        command.BudgetId = id;
        var response = await _mediator.Send(command);
        return response.Success ? Ok(response) : BadRequest(response);
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var userId = GetCurrentUserId();
        if (userId is null)
            return Unauthorized();

        var response = await _mediator.Send(new DeleteBudgetCommand
        {
            UserId = userId.Value,
            BudgetId = id
        });

        return response.Success ? Ok(response) : BadRequest(response);
    }

    private Guid? GetCurrentUserId()
    {
        var userIdValue = User.FindFirstValue(ClaimTypes.NameIdentifier);
        return Guid.TryParse(userIdValue, out var userId) ? userId : null;
    }
}
