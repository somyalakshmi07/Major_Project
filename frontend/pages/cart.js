async function cartPage() {
    const mainContent = document.getElementById('main-content');

    if (!auth.isAuthenticated()) {
        mainContent.innerHTML = '<div class="container"><div class="alert alert-error">Please login to view your cart</div></div>';
        loadPage('login');
        return;
    }

    try {
        const cartData = await api.getCart();
        cart = cartData?.items || [];
        
        let html = `
            <div class="container">
                <h1>Shopping Cart</h1>
        `;

        if (cart.length === 0) {
            html += '<div class="empty-state"><h2>Your cart is empty</h2><p><a href="#" onclick="loadPage(\'home\')">Continue Shopping</a></p></div>';
        } else {
            html += '<div id="cart-items">';
            
            cart.forEach(item => {
                html += `
                    <div class="cart-item" id="item-${item.productId}">
                        <div class="cart-item-info">
                            <h3>${item.productName}</h3>
                            <p>$${item.price.toFixed(2)} each</p>
                        </div>
                        <div class="cart-item-actions">
                            <div class="quantity-control">
                                <button onclick="updateQuantity('${item.productId}', ${item.quantity - 1})">-</button>
                                <span>${item.quantity}</span>
                                <button onclick="updateQuantity('${item.productId}', ${item.quantity + 1})">+</button>
                            </div>
                            <p style="margin: 0 1rem; font-weight: bold;">$${(item.price * item.quantity).toFixed(2)}</p>
                            <button class="danger" onclick="removeItem('${item.productId}')">Remove</button>
                        </div>
                    </div>
                `;
            });

            html += '</div>';
            
            html += `
                <div class="total-section">
                    <h3>Total: $${cartData.total.toFixed(2)}</h3>
                    <button class="success" onclick="loadPage('checkout')" style="margin-top: 1rem;">Proceed to Checkout</button>
                </div>
            `;
        }

        html += '</div>';
        mainContent.innerHTML = html;
    } catch (error) {
        mainContent.innerHTML = `<div class="container"><div class="alert alert-error">Error loading cart: ${error.message}</div></div>`;
    }
}

async function updateQuantity(productId, newQuantity) {
    if (newQuantity <= 0) {
        await removeItem(productId);
        return;
    }

    try {
        await api.updateCartItem(productId, newQuantity);
        await cartPage();
        updateCartCount();
    } catch (error) {
        showAlert('Error updating quantity: ' + error.message, 'error');
    }
}

async function removeItem(productId) {
    try {
        await api.removeFromCart(productId);
        await cartPage();
        updateCartCount();
    } catch (error) {
        showAlert('Error removing item: ' + error.message, 'error');
    }
}

