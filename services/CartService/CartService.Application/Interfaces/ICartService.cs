using CartService.Application.DTOs;

namespace CartService.Application.Interfaces;

public interface ICartService
{
    Task<CartDto?> GetCartByUserIdAsync(Guid userId);
    Task<CartDto> AddItemAsync(Guid userId, AddItemRequest request);
    Task<CartDto> UpdateItemQuantityAsync(Guid userId, string productId, UpdateItemRequest request);
    Task<CartDto> RemoveItemAsync(Guid userId, string productId);
    Task<bool> ClearCartAsync(Guid userId);
}

