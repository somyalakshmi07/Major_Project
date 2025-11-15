using OrderService.Application.Interfaces;
using OrderService.Application.Mapping;
using OrderService.Application.Services;
using Microsoft.Extensions.DependencyInjection;

namespace OrderService.Application;

public static class DependencyInjection
{
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        services.AddAutoMapper(typeof(MappingProfile));
        services.AddScoped<IOrderService, Services.OrderService>();
        return services;
    }
}

