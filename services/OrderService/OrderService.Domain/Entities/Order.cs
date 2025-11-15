using OrderService.Domain.Entities;

namespace OrderService.Domain.Entities;

public class Order
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid UserId { get; set; }
    public string Status { get; set; } = "pending"; // pending, confirmed, shipped, delivered, cancelled
    public decimal TotalAmount { get; set; }
    public string PaymentTransactionId { get; set; } = string.Empty;
    public string PaymentStatus { get; set; } = "pending"; // pending, completed, failed
    public List<OrderItem> Items { get; set; } = new();
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    public void CalculateTotal()
    {
        TotalAmount = Items.Sum(item => item.Subtotal);
    }
}

