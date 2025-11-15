using CartService.Domain.Entities;

namespace CartService.Domain.Repositories;

public interface ICartRepository
{
    Task<Cart?> GetByUserIdAsync(Guid userId);
    Task<Cart> CreateAsync(Cart cart);
    Task<Cart> UpdateAsync(Cart cart);
    Task<bool> DeleteAsync(string id);
    Task<bool> DeleteByUserIdAsync(Guid userId);
}

