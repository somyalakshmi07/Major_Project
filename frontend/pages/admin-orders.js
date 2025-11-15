async function adminOrdersPage() {
    const mainContent = document.getElementById('main-content');

    if (!auth.isAuthenticated() || !auth.isAdmin()) {
        mainContent.innerHTML = '<div class="container"><div class="alert alert-error">Access denied. Admin privileges required.</div></div>';
        return;
    }

    try {
        const orders = await api.getOrders();

        let html = `
            <div class="container">
                <h1>Order Management</h1>
                <table>
                    <thead>
                        <tr>
                            <th>Order ID</th>
                            <th>User ID</th>
                            <th>Total</th>
                            <th>Status</th>
                            <th>Payment Status</th>
                            <th>Date</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
        `;

        orders.forEach(order => {
            const statusClass = `status-${order.status.toLowerCase()}`;
            html += `
                <tr>
                    <td>${order.id.substring(0, 8)}</td>
                    <td>${order.userId.substring(0, 8)}</td>
                    <td>$${order.totalAmount.toFixed(2)}</td>
                    <td><span class="status-badge ${statusClass}">${order.status}</span></td>
                    <td>${order.paymentStatus}</td>
                    <td>${new Date(order.createdAt).toLocaleDateString()}</td>
                    <td>
                        <select onchange="updateOrderStatus('${order.id}', this.value)">
                            <option value="pending" ${order.status === 'pending' ? 'selected' : ''}>Pending</option>
                            <option value="confirmed" ${order.status === 'confirmed' ? 'selected' : ''}>Confirmed</option>
                            <option value="shipped" ${order.status === 'shipped' ? 'selected' : ''}>Shipped</option>
                            <option value="delivered" ${order.status === 'delivered' ? 'selected' : ''}>Delivered</option>
                            <option value="cancelled" ${order.status === 'cancelled' ? 'selected' : ''}>Cancelled</option>
                        </select>
                        <button onclick="viewOrderDetails('${order.id}')" style="margin-left: 0.5rem;">View</button>
                    </td>
                </tr>
            `;
        });

        html += `
                    </tbody>
                </table>
            </div>
        `;

        mainContent.innerHTML = html;
    } catch (error) {
        mainContent.innerHTML = `<div class="container"><div class="alert alert-error">Error loading orders: ${error.message}</div></div>`;
    }
}

async function updateOrderStatus(orderId, status) {
    try {
        await api.updateOrderStatus(orderId, status);
        showAlert('Order status updated', 'success');
        adminOrdersPage();
    } catch (error) {
        showAlert('Error updating order status: ' + error.message, 'error');
    }
}

async function viewOrderDetails(id) {
    try {
        const order = await api.getOrder(id);
        
        const mainContent = document.getElementById('main-content');
        mainContent.innerHTML = `
            <div class="container">
                <button onclick="loadPage('admin-orders')" style="margin-bottom: 1rem;">← Back to Orders</button>
                <h1>Order Details</h1>
                <div class="order-item">
                    <div class="order-header">
                        <div>
                            <h3>Order #${order.id.substring(0, 8)}</h3>
                            <p>User ID: ${order.userId}</p>
                            <p>Date: ${new Date(order.createdAt).toLocaleString()}</p>
                        </div>
                        <div>
                            <span class="status-badge status-${order.status.toLowerCase()}">${order.status}</span>
                            <p style="margin-top: 0.5rem;">Payment: ${order.paymentStatus}</p>
                            <p style="font-weight: bold; font-size: 1.2rem;">$${order.totalAmount.toFixed(2)}</p>
                        </div>
                    </div>
                    <h4>Items:</h4>
                    ${order.items.map(item => `
                        <div style="display: flex; justify-content: space-between; padding: 0.5rem 0; border-bottom: 1px solid #eee;">
                            <span>${item.productName} x ${item.quantity}</span>
                            <span>$${item.subtotal.toFixed(2)}</span>
                        </div>
                    `).join('')}
                    <div style="margin-top: 1rem;">
                        <label>Update Status:</label>
                        <select onchange="updateOrderStatus('${order.id}', this.value)" style="margin-left: 1rem;">
                            <option value="pending" ${order.status === 'pending' ? 'selected' : ''}>Pending</option>
                            <option value="confirmed" ${order.status === 'confirmed' ? 'selected' : ''}>Confirmed</option>
                            <option value="shipped" ${order.status === 'shipped' ? 'selected' : ''}>Shipped</option>
                            <option value="delivered" ${order.status === 'delivered' ? 'selected' : ''}>Delivered</option>
                            <option value="cancelled" ${order.status === 'cancelled' ? 'selected' : ''}>Cancelled</option>
                        </select>
                    </div>
                </div>
            </div>
        `;
    } catch (error) {
        showAlert('Error loading order details: ' + error.message, 'error');
    }
}

