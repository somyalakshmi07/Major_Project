using PaymentService.Application.DTOs;

namespace PaymentService.Application.Interfaces;

public interface IPaymentService
{
    Task<PaymentResponse> ProcessPaymentAsync(ProcessPaymentRequest request);
}

