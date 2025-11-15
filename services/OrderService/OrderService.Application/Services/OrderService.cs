using AutoMapper;
using OrderService.Application.DTOs;
using OrderService.Application.Interfaces;
using OrderService.Domain.Entities;
using OrderService.Domain.Repositories;

namespace OrderService.Application.Services;

public class OrderService : IOrderService
{
    private readonly IOrderRepository _orderRepository;
    private readonly IMapper _mapper;

    public OrderService(IOrderRepository orderRepository, IMapper mapper)
    {
        _orderRepository = orderRepository;
        _mapper = mapper;
    }

    public async Task<OrderDto?> GetByIdAsync(Guid id)
    {
        var order = await _orderRepository.GetByIdAsync(id);
        return order == null ? null : _mapper.Map<OrderDto>(order);
    }

    public async Task<IEnumerable<OrderDto>> GetByUserIdAsync(Guid userId)
    {
        var orders = await _orderRepository.GetByUserIdAsync(userId);
        return _mapper.Map<IEnumerable<OrderDto>>(orders);
    }

    public async Task<IEnumerable<OrderDto>> GetAllAsync()
    {
        var orders = await _orderRepository.GetAllAsync();
        return _mapper.Map<IEnumerable<OrderDto>>(orders);
    }

    public async Task<OrderDto> CreateAsync(Guid userId, CreateOrderRequest request)
    {
        var order = new Order
        {
            UserId = userId,
            Status = "pending",
            PaymentStatus = "pending",
            Items = request.Items.Select(item => new OrderItem
            {
                ProductId = item.ProductId,
                ProductName = item.ProductName,
                Price = item.Price,
                Quantity = item.Quantity,
                Subtotal = item.Price * item.Quantity
            }).ToList(),
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        order.CalculateTotal();
        order = await _orderRepository.CreateAsync(order);

        return _mapper.Map<OrderDto>(order);
    }

    public async Task<OrderDto> UpdateStatusAsync(Guid id, UpdateOrderStatusRequest request)
    {
        var order = await _orderRepository.GetByIdAsync(id);
        if (order == null)
        {
            throw new InvalidOperationException("Order not found.");
        }

        order.Status = request.Status;
        order.UpdatedAt = DateTime.UtcNow;
        order = await _orderRepository.UpdateAsync(order);

        return _mapper.Map<OrderDto>(order);
    }

    public async Task<OrderDto> UpdatePaymentStatusAsync(Guid id, UpdatePaymentStatusRequest request)
    {
        var order = await _orderRepository.GetByIdAsync(id);
        if (order == null)
        {
            throw new InvalidOperationException("Order not found.");
        }

        order.PaymentTransactionId = request.PaymentTransactionId;
        order.PaymentStatus = request.PaymentStatus;
        order.UpdatedAt = DateTime.UtcNow;

        if (request.PaymentStatus == "completed")
        {
            order.Status = "confirmed";
        }

        order = await _orderRepository.UpdateAsync(order);

        return _mapper.Map<OrderDto>(order);
    }
}

