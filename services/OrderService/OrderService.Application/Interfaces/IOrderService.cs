using OrderService.Application.DTOs;

namespace OrderService.Application.Interfaces;

public interface IOrderService
{
    Task<OrderDto?> GetByIdAsync(Guid id);
    Task<IEnumerable<OrderDto>> GetByUserIdAsync(Guid userId);
    Task<IEnumerable<OrderDto>> GetAllAsync();
    Task<OrderDto> CreateAsync(Guid userId, CreateOrderRequest request);
    Task<OrderDto> UpdateStatusAsync(Guid id, UpdateOrderStatusRequest request);
    Task<OrderDto> UpdatePaymentStatusAsync(Guid id, UpdatePaymentStatusRequest request);
}

