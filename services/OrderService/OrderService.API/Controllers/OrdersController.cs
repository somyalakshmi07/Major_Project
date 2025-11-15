using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OrderService.Application.DTOs;
using OrderService.Application.Interfaces;
using System.Security.Claims;

namespace OrderService.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class OrdersController : ControllerBase
{
    private readonly IOrderService _orderService;

    public OrdersController(IOrderService orderService)
    {
        _orderService = orderService;
    }

    private Guid GetUserId()
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        return Guid.Parse(userIdClaim ?? Guid.Empty.ToString());
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<OrderDto>>> GetOrders()
    {
        var userId = GetUserId();
        var role = User.FindFirst(ClaimTypes.Role)?.Value;

        IEnumerable<OrderDto> orders;

        if (role == "admin")
        {
            orders = await _orderService.GetAllAsync();
        }
        else
        {
            orders = await _orderService.GetByUserIdAsync(userId);
        }

        return Ok(orders);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<OrderDto>> GetOrder(Guid id)
    {
        var userId = GetUserId();
        var role = User.FindFirst(ClaimTypes.Role)?.Value;

        var order = await _orderService.GetByIdAsync(id);
        if (order == null)
        {
            return NotFound();
        }

        if (role != "admin" && order.UserId != userId)
        {
            return Forbid();
        }

        return Ok(order);
    }

    [HttpPost]
    public async Task<ActionResult<OrderDto>> CreateOrder([FromBody] CreateOrderRequest request)
    {
        try
        {
            var userId = GetUserId();
            var order = await _orderService.CreateAsync(userId, request);
            return CreatedAtAction(nameof(GetOrder), new { id = order.Id }, order);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "An error occurred while creating the order." });
        }
    }

    [HttpPut("{id}/status")]
    [Authorize(Roles = "admin")]
    public async Task<ActionResult<OrderDto>> UpdateOrderStatus(Guid id, [FromBody] UpdateOrderStatusRequest request)
    {
        try
        {
            var order = await _orderService.UpdateStatusAsync(id, request);
            return Ok(order);
        }
        catch (InvalidOperationException ex)
        {
            return NotFound(new { message = ex.Message });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "An error occurred while updating the order status." });
        }
    }

    [HttpPut("{id}/payment")]
    [AllowAnonymous]
    public async Task<ActionResult<OrderDto>> UpdatePaymentStatus(Guid id, [FromBody] UpdatePaymentStatusRequest request)
    {
        try
        {
            var order = await _orderService.UpdatePaymentStatusAsync(id, request);
            return Ok(order);
        }
        catch (InvalidOperationException ex)
        {
            return NotFound(new { message = ex.Message });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "An error occurred while updating the payment status." });
        }
    }
}

