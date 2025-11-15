using CartService.Domain.Entities;

namespace CartService.Domain.Entities;

public class Cart
{
    public string Id { get; set; } = Guid.NewGuid().ToString();
    public Guid UserId { get; set; }
    public List<CartItem> Items { get; set; } = new();
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    public DateTime ExpiresAt { get; set; } = DateTime.UtcNow.AddDays(7);

    public decimal GetTotal()
    {
        return Items.Sum(item => item.Price * item.Quantity);
    }
}

