using CartService.Domain.Repositories;
using CartService.Infrastructure.Data;
using CartService.Infrastructure.Repositories;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using MongoDB.Driver;
using StackExchange.Redis;

namespace CartService.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        // MongoDB
        var mongoConnectionString = configuration.GetConnectionString("MongoDB") ?? "mongodb://localhost:27017";
        var mongoDatabaseName = configuration["MongoDB:DatabaseName"] ?? "CartDb";
        var mongoClient = new MongoClient(mongoConnectionString);
        var mongoContext = new MongoDbContext(mongoClient, mongoDatabaseName);

        services.AddSingleton<MongoDbContext>(mongoContext);

        // Redis
        var redisConnectionString = configuration.GetConnectionString("Redis") ?? "localhost:6379";
        services.AddStackExchangeRedisCache(options =>
        {
            options.Configuration = redisConnectionString;
        });

        services.AddScoped<ICartRepository, CartRepository>();

        return services;
    }
}

