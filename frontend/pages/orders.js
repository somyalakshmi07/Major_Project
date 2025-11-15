async function ordersPage() {
    const mainContent = document.getElementById('main-content');

    if (!auth.isAuthenticated()) {
        mainContent.innerHTML = '<div class="container"><div class="alert alert-error">Please login to view your orders</div></div>';
        loadPage('login');
        return;
    }

    try {
        const orders = await api.getOrders();
        
        let html = `
            <div class="container">
                <h1>My Orders</h1>
        `;

        if (orders.length === 0) {
            html += '<div class="empty-state"><h2>No orders found</h2><p><a href="#" onclick="loadPage(\'home\')">Start Shopping</a></p></div>';
        } else {
            orders.forEach(order => {
                const statusClass = `status-${order.status.toLowerCase()}`;
                html += `
                    <div class="order-item">
                        <div class="order-header">
                            <div>
                                <h3>Order #${order.id.substring(0, 8)}</h3>
                                <p>Placed on: ${new Date(order.createdAt).toLocaleDateString()}</p>
                            </div>
                            <div>
                                <span class="status-badge ${statusClass}">${order.status}</span>
                                <p style="margin-top: 0.5rem; font-weight: bold;">$${order.totalAmount.toFixed(2)}</p>
                            </div>
                        </div>
                        <div>
                            ${order.items.map(item => `
                                <div style="display: flex; justify-content: space-between; padding: 0.25rem 0;">
                                    <span>${item.productName} x ${item.quantity}</span>
                                    <span>$${item.subtotal.toFixed(2)}</span>
                                </div>
                            `).join('')}
                        </div>
                        <button onclick="viewOrder('${order.id}')" style="margin-top: 1rem;">View Details</button>
                    </div>
                `;
            });
        }

        html += '</div>';
        mainContent.innerHTML = html;
    } catch (error) {
        mainContent.innerHTML = `<div class="container"><div class="alert alert-error">Error loading orders: ${error.message}</div></div>`;
    }
}

function viewOrder(id) {
    window.location.hash = `#order/${id}`;
}

