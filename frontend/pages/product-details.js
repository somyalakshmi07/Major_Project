async function productPage(params) {
    const productId = params[0];
    const mainContent = document.getElementById('main-content');

    try {
        const product = await api.getProduct(productId);
        
        mainContent.innerHTML = `
            <div class="container">
                <button onclick="loadPage('home')" style="margin-bottom: 1rem;">← Back to Products</button>
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 2rem;">
                    <img src="${product.imageUrl || 'https://via.placeholder.com/500'}" alt="${product.name}" style="width: 100%; border-radius: 8px;">
                    <div>
                        <h1>${product.name}</h1>
                        <div style="font-size: 2rem; color: #27ae60; font-weight: bold; margin: 1rem 0;">
                            $${product.price.toFixed(2)}
                        </div>
                        <p style="margin-bottom: 1rem;">${product.description}</p>
                        <p style="margin-bottom: 1rem;"><strong>Category:</strong> ${product.categoryName}</p>
                        <p style="margin-bottom: 1rem;"><strong>Stock:</strong> ${product.stock}</p>
                        <div style="margin-top: 2rem;">
                            <label for="quantity">Quantity:</label>
                            <input type="number" id="quantity" value="1" min="1" max="${product.stock}" style="width: 100px; margin-left: 0.5rem;">
                        </div>
                        <button onclick="addToCartFromDetails('${product.id}', '${product.name}', ${product.price}, '${product.imageUrl || ''}')" 
                                style="margin-top: 1rem; width: 100%;" 
                                ${product.stock === 0 ? 'disabled' : ''}>
                            ${product.stock === 0 ? 'Out of Stock' : 'Add to Cart'}
                        </button>
                    </div>
                </div>
            </div>
        `;
    } catch (error) {
        mainContent.innerHTML = `<div class="container"><div class="alert alert-error">Error loading product: ${error.message}</div></div>`;
    }
}

async function addToCartFromDetails(productId, productName, price, imageUrl) {
    if (!auth.isAuthenticated()) {
        showAlert('Please login to add items to cart', 'error');
        loadPage('login');
        return;
    }

    const quantity = parseInt(document.getElementById('quantity').value) || 1;

    try {
        await api.addToCart({
            productId,
            productName,
            price,
            quantity,
            imageUrl
        });
        showAlert('Item added to cart', 'success');
        updateCartCount();
    } catch (error) {
        showAlert('Error adding to cart: ' + error.message, 'error');
    }
}

