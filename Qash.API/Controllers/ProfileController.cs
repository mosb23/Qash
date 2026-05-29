using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Qash.API.Features.Auth.Commands;
using Qash.API.Features.Profile.Commands;
using Qash.API.Features.Profile.DTOs;
using Qash.API.Features.Profile.Queries;
using System;
using System.Security.Claims;
using System.Threading.Tasks;

namespace Qash.API.Controllers;

[ApiController]
[Authorize]
[Route("api/profile")]
public class ProfileController : ControllerBase
{
    private readonly IMediator _mediator;

    public ProfileController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    public async Task<IActionResult> GetProfile()
    {
        var userId = GetCurrentUserId();

        if (userId is null)
            return Unauthorized();

        var response = await _mediator.Send(new GetProfileQuery(userId.Value));
        return response.Success ? Ok(response) : NotFound(response);
    }

    [HttpPut]
    public async Task<IActionResult> UpdateProfile([FromBody] UpdateProfileCommand command)
    {
        var userId = GetCurrentUserId();

        if (userId is null)
            return Unauthorized();

        command.UserId = userId.Value;

        var response = await _mediator.Send(command);
        return response.Success ? Ok(response) : BadRequest(response);
    }

    [HttpPost("change-password")]
    public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordCommand command)
    {
        var userId = GetCurrentUserId();

        if (userId is null)
            return Unauthorized();

        command.UserId = userId.Value;

        var response = await _mediator.Send(command);
        return response.Success ? Ok(response) : BadRequest(response);
    }

    [HttpDelete]
    public async Task<IActionResult> DeleteProfile([FromBody] DeleteProfileRequestDto request)
    {
        var userId = GetCurrentUserId();

        if (userId is null)
            return Unauthorized();

        var response = await _mediator.Send(
            new DeleteProfileCommand(userId.Value, request.Password));
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