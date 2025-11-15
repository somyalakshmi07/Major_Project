using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Http;
using PaymentService.Application.Interfaces;
using PaymentService.Application.Services;

namespace PaymentService.Application;

public static class DependencyInjection
{
    public static IServiceCollection AddApplication(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddHttpClient<IPaymentService, Services.PaymentService>(client =>
        {
            var orderServiceUrl = configuration["OrderService:Url"] ?? "http://localhost:5004";
            client.BaseAddress = new Uri(orderServiceUrl);
            client.Timeout = TimeSpan.FromSeconds(30);
        });

        services.AddScoped<IPaymentService, Services.PaymentService>();
        return services;
    }
}
