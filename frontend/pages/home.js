async function homePage() {
    const mainContent = document.getElementById('main-content');
    
    try {
        const [products, categories] = await Promise.all([
            api.getProducts(),
            api.getCategories()
        ]);

        let html = `
            <div class="container">
                <h1>Products</h1>
                <div class="search-filter">
                    <input type="text" id="search-input" placeholder="Search products..." onkeyup="handleSearch()">
                    <select id="category-filter" onchange="handleCategoryFilter()">
                        <option value="">All Categories</option>
                        ${categories.map(cat => `<option value="${cat.id}">${cat.name}</option>`).join('')}
                    </select>
                </div>
                <div id="products-grid" class="product-grid">
        `;

        if (products.length === 0) {
            html += '<div class="empty-state"><h2>No products found</h2></div>';
        } else {
            products.forEach(product => {
                html += `
                    <div class="product-card" onclick="viewProduct('${product.id}')">
                        <img src="${product.imageUrl || 'https://via.placeholder.com/300'}" alt="${product.name}" class="product-image">
                        <div class="product-info">
                            <div class="product-name">${product.name}</div>
                            <div class="product-price">$${product.price.toFixed(2)}</div>
                            <div class="product-stock">Stock: ${product.stock}</div>
                            <button onclick="event.stopPropagation(); addToCart('${product.id}', '${product.name}', ${product.price}, '${product.imageUrl || ''}')">Add to Cart</button>
                        </div>
                    </div>
                `;
            });
        }

        html += `
                </div>
            </div>
        `;

        mainContent.innerHTML = html;
    } catch (error) {
        mainContent.innerHTML = `<div class="container"><div class="alert alert-error">Error loading products: ${error.message}</div></div>`;
    }
}

async function handleSearch() {
    const searchTerm = document.getElementById('search-input').value;
    const mainContent = document.getElementById('main-content');
    const productsGrid = document.getElementById('products-grid');

    if (searchTerm.length < 2) {
        homePage();
        return;
    }

    try {
        const products = await api.searchProducts(searchTerm);
        productsGrid.innerHTML = '';

        if (products.length === 0) {
            productsGrid.innerHTML = '<div class="empty-state"><h2>No products found</h2></div>';
        } else {
            products.forEach(product => {
                const productCard = document.createElement('div');
                productCard.className = 'product-card';
                productCard.onclick = () => viewProduct(product.id);
                productCard.innerHTML = `
                    <img src="${product.imageUrl || 'https://via.placeholder.com/300'}" alt="${product.name}" class="product-image">
                    <div class="product-info">
                        <div class="product-name">${product.name}</div>
                        <div class="product-price">$${product.price.toFixed(2)}</div>
                        <div class="product-stock">Stock: ${product.stock}</div>
                        <button onclick="event.stopPropagation(); addToCart('${product.id}', '${product.name}', ${product.price}, '${product.imageUrl || ''}')">Add to Cart</button>
                    </div>
                `;
                productsGrid.appendChild(productCard);
            });
        }
    } catch (error) {
        showAlert('Error searching products: ' + error.message, 'error');
    }
}

async function handleCategoryFilter() {
    const categoryId = document.getElementById('category-filter').value;
    const mainContent = document.getElementById('main-content');
    const productsGrid = document.getElementById('products-grid');

    if (!categoryId) {
        homePage();
        return;
    }

    try {
        const products = await api.request(`${API_CONFIG.CATALOG_SERVICE}/products/category/${categoryId}`);
        productsGrid.innerHTML = '';

        if (products.length === 0) {
            productsGrid.innerHTML = '<div class="empty-state"><h2>No products found in this category</h2></div>';
        } else {
            products.forEach(product => {
                const productCard = document.createElement('div');
                productCard.className = 'product-card';
                productCard.onclick = () => viewProduct(product.id);
                productCard.innerHTML = `
                    <img src="${product.imageUrl || 'https://via.placeholder.com/300'}" alt="${product.name}" class="product-image">
                    <div class="product-info">
                        <div class="product-name">${product.name}</div>
                        <div class="product-price">$${product.price.toFixed(2)}</div>
                        <div class="product-stock">Stock: ${product.stock}</div>
                        <button onclick="event.stopPropagation(); addToCart('${product.id}', '${product.name}', ${product.price}, '${product.imageUrl || ''}')">Add to Cart</button>
                    </div>
                `;
                productsGrid.appendChild(productCard);
            });
        }
    } catch (error) {
        showAlert('Error filtering products: ' + error.message, 'error');
    }
}

async function addToCart(productId, productName, price, imageUrl) {
    if (!auth.isAuthenticated()) {
        showAlert('Please login to add items to cart', 'error');
        loadPage('login');
        return;
    }

    try {
        await api.addToCart({
            productId,
            productName,
            price,
            quantity: 1,
            imageUrl
        });
        showAlert('Item added to cart', 'success');
        updateCartCount();
    } catch (error) {
        showAlert('Error adding to cart: ' + error.message, 'error');
    }
}

function viewProduct(id) {
    loadPage('product', [id]);
}

