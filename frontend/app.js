let cart = [];

async function updateCartCount() {
    if (auth.isAuthenticated()) {
        try {
            const cartData = await api.getCart();
            cart = cartData?.items || [];
            const cartCount = cart.reduce((sum, item) => sum + item.quantity, 0);
            document.getElementById('cart-count').textContent = cartCount;
        } catch (error) {
            console.error('Error updating cart count:', error);
        }
    } else {
        document.getElementById('cart-count').textContent = '0';
    }
}

function showAlert(message, type = 'info') {
    const mainContent = document.getElementById('main-content');
    const alert = document.createElement('div');
    alert.className = `alert alert-${type}`;
    alert.textContent = message;
    mainContent.insertBefore(alert, mainContent.firstChild);
    
    setTimeout(() => {
        alert.remove();
    }, 5000);
}

// Initialize app
document.addEventListener('DOMContentLoaded', () => {
    initRouter();
    updateCartCount();
    
    // Update cart count every 30 seconds
    setInterval(updateCartCount, 30000);
});

// Global logout function
function logout() {
    auth.logout();
    showAlert('Logged out successfully', 'success');
}

