using CatalogService.Domain.Entities;
using CatalogService.Domain.Repositories;
using CatalogService.Infrastructure.Data;
using MongoDB.Driver;

namespace CatalogService.Infrastructure.Repositories;

public class CategoryRepository : ICategoryRepository
{
    private readonly IMongoCollection<Category> _collection;

    public CategoryRepository(MongoDbContext context)
    {
        _collection = context.GetCollection<Category>("Categories");
    }

    public async Task<Category?> GetByIdAsync(string id)
    {
        return await _collection.Find(c => c.Id == id).FirstOrDefaultAsync();
    }

    public async Task<IEnumerable<Category>> GetAllAsync()
    {
        return await _collection.Find(c => c.IsActive).ToListAsync();
    }

    public async Task<Category> CreateAsync(Category category)
    {
        await _collection.InsertOneAsync(category);
        return category;
    }

    public async Task<Category> UpdateAsync(Category category)
    {
        await _collection.ReplaceOneAsync(c => c.Id == category.Id, category);
        return category;
    }

    public async Task<bool> DeleteAsync(string id)
    {
        var result = await _collection.DeleteOneAsync(c => c.Id == id);
        return result.DeletedCount > 0;
    }

    public async Task<bool> ExistsAsync(string id)
    {
        var count = await _collection.CountDocumentsAsync(c => c.Id == id);
        return count > 0;
    }
}

