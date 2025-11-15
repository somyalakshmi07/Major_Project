using CartService.Domain.Entities;
using CartService.Domain.Repositories;
using CartService.Infrastructure.Data;
using Microsoft.Extensions.Caching.Distributed;
using System.Text.Json;
using MongoDB.Driver;

namespace CartService.Infrastructure.Repositories;

public class CartRepository : ICartRepository
{
    private readonly IMongoCollection<Cart> _collection;
    private readonly IDistributedCache _cache;
    private readonly TimeSpan _cacheExpiration = TimeSpan.FromDays(7);

    public CartRepository(MongoDbContext context, IDistributedCache cache)
    {
        _collection = context.GetCollection<Cart>("Carts");
        _cache = cache;

        // Create index on UserId
        var indexKeys = Builders<Cart>.IndexKeys.Ascending(c => c.UserId);
        var indexModel = new CreateIndexModel<Cart>(indexKeys);
        _collection.Indexes.CreateOne(indexModel);
    }

    public async Task<Cart?> GetByUserIdAsync(Guid userId)
    {
        // Try cache first
        var cacheKey = $"cart:{userId}";
        var cachedCart = await _cache.GetStringAsync(cacheKey);
        if (cachedCart != null)
        {
            return JsonSerializer.Deserialize<Cart>(cachedCart);
        }

        // Fall back to database
        var cart = await _collection.Find(c => c.UserId == userId).FirstOrDefaultAsync();
        
        if (cart != null)
        {
            // Cache the result
            await _cache.SetStringAsync(cacheKey, JsonSerializer.Serialize(cart), new DistributedCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = _cacheExpiration
            });
        }

        return cart;
    }

    public async Task<Cart> CreateAsync(Cart cart)
    {
        await _collection.InsertOneAsync(cart);
        
        // Cache the result
        var cacheKey = $"cart:{cart.UserId}";
        await _cache.SetStringAsync(cacheKey, JsonSerializer.Serialize(cart), new DistributedCacheEntryOptions
        {
            AbsoluteExpirationRelativeToNow = _cacheExpiration
        });

        return cart;
    }

    public async Task<Cart> UpdateAsync(Cart cart)
    {
        await _collection.ReplaceOneAsync(c => c.Id == cart.Id, cart);
        
        // Update cache
        var cacheKey = $"cart:{cart.UserId}";
        await _cache.SetStringAsync(cacheKey, JsonSerializer.Serialize(cart), new DistributedCacheEntryOptions
        {
            AbsoluteExpirationRelativeToNow = _cacheExpiration
        });

        return cart;
    }

    public async Task<bool> DeleteAsync(string id)
    {
        var cart = await _collection.Find(c => c.Id == id).FirstOrDefaultAsync();
        if (cart == null)
        {
            return false;
        }

        var result = await _collection.DeleteOneAsync(c => c.Id == id);
        
        // Remove from cache
        var cacheKey = $"cart:{cart.UserId}";
        await _cache.RemoveAsync(cacheKey);

        return result.DeletedCount > 0;
    }

    public async Task<bool> DeleteByUserIdAsync(Guid userId)
    {
        var result = await _collection.DeleteManyAsync(c => c.UserId == userId);
        
        // Remove from cache
        var cacheKey = $"cart:{userId}";
        await _cache.RemoveAsync(cacheKey);

        return result.DeletedCount > 0;
    }
}

