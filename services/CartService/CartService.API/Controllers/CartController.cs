using CartService.Application.DTOs;
using CartService.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace CartService.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class CartController : ControllerBase
{
    private readonly ICartService _cartService;

    public CartController(ICartService cartService)
    {
        _cartService = cartService;
    }

    private Guid GetUserId()
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        return Guid.Parse(userIdClaim ?? Guid.Empty.ToString());
    }

    [HttpGet]
    public async Task<ActionResult<CartDto>> GetCart()
    {
        var userId = GetUserId();
        var cart = await _cartService.GetCartByUserIdAsync(userId);
        
        if (cart == null)
        {
            return Ok(new CartDto { UserId = userId, Items = new List<CartItemDto>() });
        }

        return Ok(cart);
    }

    [HttpPost("items")]
    public async Task<ActionResult<CartDto>> AddItem([FromBody] AddItemRequest request)
    {
        try
        {
            var userId = GetUserId();
            var cart = await _cartService.AddItemAsync(userId, request);
            return Ok(cart);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "An error occurred while adding item to cart." });
        }
    }

    [HttpPut("items/{productId}")]
    public async Task<ActionResult<CartDto>> UpdateItemQuantity(string productId, [FromBody] UpdateItemRequest request)
    {
        try
        {
            var userId = GetUserId();
            var cart = await _cartService.UpdateItemQuantityAsync(userId, productId, request);
            return Ok(cart);
        }
        catch (InvalidOperationException ex)
        {
            return NotFound(new { message = ex.Message });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "An error occurred while updating item quantity." });
        }
    }

    [HttpDelete("items/{productId}")]
    public async Task<ActionResult<CartDto>> RemoveItem(string productId)
    {
        try
        {
            var userId = GetUserId();
            var cart = await _cartService.RemoveItemAsync(userId, productId);
            return Ok(cart);
        }
        catch (InvalidOperationException ex)
        {
            return NotFound(new { message = ex.Message });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "An error occurred while removing item from cart." });
        }
    }

    [HttpDelete("clear")]
    public async Task<IActionResult> ClearCart()
    {
        var userId = GetUserId();
        var result = await _cartService.ClearCartAsync(userId);
        
        if (!result)
        {
            return NotFound();
        }

        return NoContent();
    }
}

