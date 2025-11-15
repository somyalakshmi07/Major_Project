using AutoMapper;
using CartService.Application.DTOs;
using CartService.Application.Interfaces;
using CartService.Domain.Entities;
using CartService.Domain.Repositories;

namespace CartService.Application.Services;

public class CartService : ICartService
{
    private readonly ICartRepository _cartRepository;
    private readonly IMapper _mapper;

    public CartService(ICartRepository cartRepository, IMapper mapper)
    {
        _cartRepository = cartRepository;
        _mapper = mapper;
    }

    public async Task<CartDto?> GetCartByUserIdAsync(Guid userId)
    {
        var cart = await _cartRepository.GetByUserIdAsync(userId);
        if (cart == null)
        {
            return null;
        }

        var cartDto = _mapper.Map<CartDto>(cart);
        cartDto.Total = cart.GetTotal();
        return cartDto;
    }

    public async Task<CartDto> AddItemAsync(Guid userId, AddItemRequest request)
    {
        var cart = await _cartRepository.GetByUserIdAsync(userId);

        if (cart == null)
        {
            cart = new Cart
            {
                UserId = userId,
                Items = new List<CartItem>(),
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow,
                ExpiresAt = DateTime.UtcNow.AddDays(7)
            };
        }

        var existingItem = cart.Items.FirstOrDefault(i => i.ProductId == request.ProductId);
        if (existingItem != null)
        {
            existingItem.Quantity += request.Quantity;
        }
        else
        {
            cart.Items.Add(new CartItem
            {
                ProductId = request.ProductId,
                ProductName = request.ProductName,
                Price = request.Price,
                Quantity = request.Quantity,
                ImageUrl = request.ImageUrl
            });
        }

        cart.UpdatedAt = DateTime.UtcNow;
        cart.ExpiresAt = DateTime.UtcNow.AddDays(7);

        if (cart.Id == null || cart.Id == Guid.Empty.ToString())
        {
            cart = await _cartRepository.CreateAsync(cart);
        }
        else
        {
            cart = await _cartRepository.UpdateAsync(cart);
        }

        var cartDto = _mapper.Map<CartDto>(cart);
        cartDto.Total = cart.GetTotal();
        return cartDto;
    }

    public async Task<CartDto> UpdateItemQuantityAsync(Guid userId, string productId, UpdateItemRequest request)
    {
        var cart = await _cartRepository.GetByUserIdAsync(userId);
        if (cart == null)
        {
            throw new InvalidOperationException("Cart not found.");
        }

        var item = cart.Items.FirstOrDefault(i => i.ProductId == productId);
        if (item == null)
        {
            throw new InvalidOperationException("Item not found in cart.");
        }

        if (request.Quantity <= 0)
        {
            cart.Items.Remove(item);
        }
        else
        {
            item.Quantity = request.Quantity;
        }

        cart.UpdatedAt = DateTime.UtcNow;
        cart = await _cartRepository.UpdateAsync(cart);

        var cartDto = _mapper.Map<CartDto>(cart);
        cartDto.Total = cart.GetTotal();
        return cartDto;
    }

    public async Task<CartDto> RemoveItemAsync(Guid userId, string productId)
    {
        var cart = await _cartRepository.GetByUserIdAsync(userId);
        if (cart == null)
        {
            throw new InvalidOperationException("Cart not found.");
        }

        var item = cart.Items.FirstOrDefault(i => i.ProductId == productId);
        if (item == null)
        {
            throw new InvalidOperationException("Item not found in cart.");
        }

        cart.Items.Remove(item);
        cart.UpdatedAt = DateTime.UtcNow;
        cart = await _cartRepository.UpdateAsync(cart);

        var cartDto = _mapper.Map<CartDto>(cart);
        cartDto.Total = cart.GetTotal();
        return cartDto;
    }

    public async Task<bool> ClearCartAsync(Guid userId)
    {
        var cart = await _cartRepository.GetByUserIdAsync(userId);
        if (cart == null)
        {
            return false;
        }

        return await _cartRepository.DeleteAsync(cart.Id);
    }
}

