using CatalogService.Domain.Entities;
using CatalogService.Domain.Repositories;
using CatalogService.Infrastructure.Data;
using MongoDB.Driver;

namespace CatalogService.Infrastructure.Repositories;

public class ProductRepository : IProductRepository
{
    private readonly IMongoCollection<Product> _collection;

    public ProductRepository(MongoDbContext context)
    {
        _collection = context.GetCollection<Product>("Products");
        
        // Create indexes
        var indexKeys = Builders<Product>.IndexKeys.Ascending(p => p.CategoryId);
        var indexModel = new CreateIndexModel<Product>(indexKeys);
        _collection.Indexes.CreateOne(indexModel);
    }

    public async Task<Product?> GetByIdAsync(string id)
    {
        return await _collection.Find(p => p.Id == id).FirstOrDefaultAsync();
    }

    public async Task<IEnumerable<Product>> GetAllAsync()
    {
        return await _collection.Find(p => p.IsActive).ToListAsync();
    }

    public async Task<IEnumerable<Product>> GetByCategoryAsync(string categoryId)
    {
        return await _collection.Find(p => p.CategoryId == categoryId && p.IsActive).ToListAsync();
    }

    public async Task<IEnumerable<Product>> SearchAsync(string searchTerm)
    {
        var filter = Builders<Product>.Filter.And(
            Builders<Product>.Filter.Regex(p => p.Name, new MongoDB.Bson.BsonRegularExpression(searchTerm, "i")),
            Builders<Product>.Filter.Eq(p => p.IsActive, true)
        );
        
        return await _collection.Find(filter).ToListAsync();
    }

    public async Task<Product> CreateAsync(Product product)
    {
        await _collection.InsertOneAsync(product);
        return product;
    }

    public async Task<Product> UpdateAsync(Product product)
    {
        await _collection.ReplaceOneAsync(p => p.Id == product.Id, product);
        return product;
    }

    public async Task<bool> DeleteAsync(string id)
    {
        var result = await _collection.DeleteOneAsync(p => p.Id == id);
        return result.DeletedCount > 0;
    }

    public async Task<bool> ExistsAsync(string id)
    {
        var count = await _collection.CountDocumentsAsync(p => p.Id == id);
        return count > 0;
    }
}

