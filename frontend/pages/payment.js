async function paymentPage(params) {
    const orderId = params[0];
    const transactionId = params[1];
    const mainContent = document.getElementById('main-content');

    try {
        const order = await api.getOrder(orderId);
        
        const statusClass = order.paymentStatus === 'completed' ? 'status-confirmed' : 'status-cancelled';
        const statusText = order.paymentStatus === 'completed' ? 'Success' : 'Failed';

        mainContent.innerHTML = `
            <div class="container">
                <div class="alert ${order.paymentStatus === 'completed' ? 'alert-success' : 'alert-error'}">
                    <h2>Payment ${statusText}</h2>
                    <p>Transaction ID: ${transactionId || order.paymentTransactionId}</p>
                    <p>Order ID: ${order.id}</p>
                    <p>Amount: $${order.totalAmount.toFixed(2)}</p>
                </div>
                <div style="margin-top: 2rem;">
                    <h3>Order Details</h3>
                    ${order.items.map(item => `
                        <div style="display: flex; justify-content: space-between; padding: 0.5rem 0; border-bottom: 1px solid #eee;">
                            <span>${item.productName} x ${item.quantity}</span>
                            <span>$${item.subtotal.toFixed(2)}</span>
                        </div>
                    `).join('')}
                </div>
                <div style="margin-top: 2rem;">
                    <button onclick="loadPage('home')">Continue Shopping</button>
                    <button onclick="loadPage('orders')" style="margin-left: 1rem;">View Orders</button>
                </div>
            </div>
        `;
    } catch (error) {
        mainContent.innerHTML = `<div class="container"><div class="alert alert-error">Error loading payment details: ${error.message}</div></div>`;
    }
}

