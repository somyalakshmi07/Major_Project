using Microsoft.Extensions.Configuration;
using PaymentService.Application.DTOs;
using PaymentService.Application.Interfaces;
using PaymentService.Domain.Entities;
using System.Net.Http.Json;

namespace PaymentService.Application.Services;

public class PaymentService : IPaymentService
{
    private readonly HttpClient _httpClient;
    private readonly IConfiguration _configuration;
    private readonly Random _random;

    public PaymentService(HttpClient httpClient, IConfiguration configuration)
    {
        _httpClient = httpClient;
        _configuration = configuration;
        _random = new Random();
    }

    public async Task<PaymentResponse> ProcessPaymentAsync(ProcessPaymentRequest request)
    {
        // Simulate payment processing with random success/failure
        await Task.Delay(1000); // Simulate network delay

        var transactionId = $"TXN-{DateTime.UtcNow:yyyyMMddHHmmss}-{Guid.NewGuid():N}".Substring(0, 32).ToUpper();
        var successRate = _configuration.GetValue<double>("Payment:SuccessRate", 0.85); // 85% success rate
        
        var isSuccess = _random.NextDouble() < successRate;
        var status = isSuccess ? "completed" : "failed";

        var payment = new Payment
        {
            OrderId = request.OrderId,
            Amount = request.Amount,
            Status = status,
            TransactionId = transactionId,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        // Update order status via Order Service
        var orderServiceUrl = _configuration["OrderService:Url"] ?? "http://localhost:5004";
        
        try
        {
            var updateRequest = new
            {
                PaymentTransactionId = transactionId,
                PaymentStatus = status
            };

            var response = await _httpClient.PutAsJsonAsync(
                $"{orderServiceUrl}/api/orders/{request.OrderId}/payment",
                updateRequest);

            if (!response.IsSuccessStatusCode)
            {
                // Log error but continue
                Console.WriteLine($"Failed to update order status: {response.StatusCode}");
            }
        }
        catch (Exception ex)
        {
            // Log error but continue
            Console.WriteLine($"Error updating order status: {ex.Message}");
        }

        return new PaymentResponse
        {
            PaymentId = payment.Id,
            OrderId = payment.OrderId,
            TransactionId = payment.TransactionId,
            Status = payment.Status,
            Amount = payment.Amount,
            Message = isSuccess ? "Payment processed successfully" : "Payment processing failed. Please try again.",
            CreatedAt = payment.CreatedAt
        };
    }
}
