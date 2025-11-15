function adminPage() {
    const mainContent = document.getElementById('main-content');

    if (!auth.isAuthenticated() || !auth.isAdmin()) {
        mainContent.innerHTML = '<div class="container"><div class="alert alert-error">Access denied. Admin privileges required.</div></div>';
        return;
    }

    mainContent.innerHTML = `
        <div class="container">
            <h1>Admin Dashboard</h1>
            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 2rem; margin-top: 2rem;">
                <div class="card" onclick="loadPage('admin-products')" style="padding: 2rem; background: #3498db; color: white; border-radius: 8px; cursor: pointer; text-align: center;">
                    <h2>Products</h2>
                    <p>Manage products and categories</p>
                </div>
                <div class="card" onclick="loadPage('admin-orders')" style="padding: 2rem; background: #27ae60; color: white; border-radius: 8px; cursor: pointer; text-align: center;">
                    <h2>Orders</h2>
                    <p>View and manage orders</p>
                </div>
            </div>
        </div>
    `;
}

