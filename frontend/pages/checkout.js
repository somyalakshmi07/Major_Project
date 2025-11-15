async function checkoutPage() {
    const mainContent = document.getElementById('main-content');

    if (!auth.isAuthenticated()) {
        mainContent.innerHTML = '<div class="container"><div class="alert alert-error">Please login to checkout</div></div>';
        loadPage('login');
        return;
    }

    try {
        const cartData = await api.getCart();
        
        if (!cartData || !cartData.items || cartData.items.length === 0) {
            mainContent.innerHTML = '<div class="container"><div class="alert alert-error">Your cart is empty</div></div>';
            return;
        }

        mainContent.innerHTML = `
            <div class="container">
                <h1>Checkout</h1>
                <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 2rem;">
                    <div>
                        <h2>Order Summary</h2>
                        <div id="order-items">
                            ${cartData.items.map(item => `
                                <div style="display: flex; justify-content: space-between; padding: 0.5rem 0; border-bottom: 1px solid #eee;">
                                    <span>${item.productName} x ${item.quantity}</span>
                                    <span>$${(item.price * item.quantity).toFixed(2)}</span>
                                </div>
                            `).join('')}
                        </div>
                        <div style="margin-top: 1rem; padding-top: 1rem; border-top: 2px solid #eee;">
                            <div style="display: flex; justify-content: space-between; font-size: 1.2rem; font-weight: bold;">
                                <span>Total:</span>
                                <span>$${cartData.total.toFixed(2)}</span>
                            </div>
                        </div>
                        <h2 style="margin-top: 2rem;">Payment Information</h2>
                        <form id="checkout-form" onsubmit="handleCheckout(event)">
                            <div class="form-group">
                                <label for="card-number">Card Number</label>
                                <input type="text" id="card-number" placeholder="1234 5678 9012 3456" required>
                            </div>
                            <div class="form-group">
                                <label for="card-holder">Card Holder Name</label>
                                <input type="text" id="card-holder" required>
                            </div>
                            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem;">
                                <div class="form-group">
                                    <label for="expiry">Expiry Date</label>
                                    <input type="text" id="expiry" placeholder="MM/YY" required>
                                </div>
                                <div class="form-group">
                                    <label for="cvv">CVV</label>
                                    <input type="text" id="cvv" required>
                                </div>
                            </div>
                            <button type="submit" class="success" style="width: 100%; margin-top: 1rem;">Place Order</button>
                        </form>
                    </div>
                </div>
            </div>
        `;
    } catch (error) {
        mainContent.innerHTML = `<div class="container"><div class="alert alert-error">Error loading checkout: ${error.message}</div></div>`;
    }
}

async function handleCheckout(event) {
    event.preventDefault();

    try {
        // Get cart data
        const cartData = await api.getCart();
        
        // Create order
        const orderItems = cartData.items.map(item => ({
            productId: item.productId,
            productName: item.productName,
            price: item.price,
            quantity: item.quantity
        }));

        const order = await api.createOrder(orderItems);

        // Process payment
        const paymentData = {
            orderId: order.id,
            amount: order.totalAmount,
            paymentMethod: 'card',
            cardNumber: document.getElementById('card-number').value,
            cardHolderName: document.getElementById('card-holder').value,
            expiryDate: document.getElementById('expiry').value,
            cvv: document.getElementById('cvv').value
        };

        const paymentResult = await api.processPayment(paymentData);

        if (paymentResult.status === 'completed') {
            // Clear cart
            await api.clearCart();
            updateCartCount();
            
            // Redirect to payment success page
            window.location.hash = `#payment/${order.id}/${paymentResult.transactionId}`;
        } else {
            showAlert('Payment failed: ' + paymentResult.message, 'error');
        }
    } catch (error) {
        showAlert('Error processing order: ' + error.message, 'error');
    }
}

