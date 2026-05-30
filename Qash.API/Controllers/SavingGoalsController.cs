using FluentValidation;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Qash.API.Common.Responses;
using Qash.API.Features.SavingGoals.Commands;
using Qash.API.Features.SavingGoals.DTOs;
using Qash.API.Features.SavingGoals.Queries;
using System.Security.Claims;

namespace Qash.API.Controllers;

[ApiController]
[Authorize]
[Route("api/saving-goals")]
public class SavingGoalsController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly IValidator<CreateSavingGoalCommand> _createValidator;

    public SavingGoalsController(
        IMediator mediator,
        IValidator<CreateSavingGoalCommand> createValidator)
    {
        _mediator = mediator;
        _createValidator = createValidator;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var userId = GetCurrentUserId();
        if (userId is null)
            return Unauthorized();

        var response = await _mediator.Send(new GetSavingGoalsQuery(userId.Value));
        return response.Success ? Ok(response) : BadRequest(response);
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id)
    {
        var userId = GetCurrentUserId();
        if (userId is null)
            return Unauthorized();

        var response = await _mediator.Send(new GetSavingGoalByIdQuery(userId.Value, id));
        return response.Success ? Ok(response) : NotFound(response);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateSavingGoalCommand command)
    {
        var userId = GetCurrentUserId();
        if (userId is null)
            return Unauthorized();

        var validation = await _createValidator.ValidateAsync(command);
        if (!validation.IsValid)
        {
            return BadRequest(
                ApiResponse<SavingGoalDto>.FailResponse(
                    "Create saving goal failed.",
                    validation.Errors.Select(e => e.ErrorMessage).ToList()));
        }

        command.UserId = userId.Value;
        var response = await _mediator.Send(command);
        return response.Success ? Ok(response) : BadRequest(response);
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateSavingGoalCommand command)
    {
        var userId = GetCurrentUserId();
        if (userId is null)
            return Unauthorized();

        command.UserId = userId.Value;
        command.SavingGoalId = id;
        var response = await _mediator.Send(command);
        return response.Success ? Ok(response) : BadRequest(response);
    }

    [HttpPost("{id:guid}/contribute")]
    public async Task<IActionResult> Contribute(Guid id, [FromBody] ContributeToSavingGoalCommand command)
    {
        var userId = GetCurrentUserId();
        if (userId is null)
            return Unauthorized();

        command.UserId = userId.Value;
        command.SavingGoalId = id;
        var response = await _mediator.Send(command);
        return response.Success ? Ok(response) : BadRequest(response);
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var userId = GetCurrentUserId();
        if (userId is null)
            return Unauthorized();

        var response = await _mediator.Send(new DeleteSavingGoalCommand(userId.Value, id));
        return response.Success ? Ok(response) : BadRequest(response);
    }

    private Guid? GetCurrentUserId()
    {
        var userIdValue = User.FindFirstValue(ClaimTypes.NameIdentifier);
        return Guid.TryParse(userIdValue, out var userId) ? userId : null;
    }
}
