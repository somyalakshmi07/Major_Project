using CatalogService.Application.Interfaces;
using CatalogService.Application.Mapping;
using CatalogService.Application.Services;
using Microsoft.Extensions.DependencyInjection;
using System.Reflection;

namespace CatalogService.Application;

public static class DependencyInjection
{
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        services.AddAutoMapper(typeof(MappingProfile));
        services.AddScoped<IProductService, ProductService>();
        services.AddScoped<ICategoryService, CategoryService>();
        return services;
    }
}

