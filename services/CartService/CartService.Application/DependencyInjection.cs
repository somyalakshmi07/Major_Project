using CartService.Application.Interfaces;
using CartService.Application.Mapping;
using CartService.Application.Services;
using Microsoft.Extensions.DependencyInjection;

namespace CartService.Application;

public static class DependencyInjection
{
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        services.AddAutoMapper(typeof(MappingProfile));
        services.AddScoped<ICartService, Services.CartService>();
        return services;
    }
}

