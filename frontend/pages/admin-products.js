let categories = [];
let editingProduct = null;

async function adminProductsPage() {
    const mainContent = document.getElementById('main-content');

    if (!auth.isAuthenticated() || !auth.isAdmin()) {
        mainContent.innerHTML = '<div class="container"><div class="alert alert-error">Access denied. Admin privileges required.</div></div>';
        return;
    }

    try {
        const [products, categoriesData] = await Promise.all([
            api.getProducts(),
            api.getCategories()
        ]);
        categories = categoriesData;

        let html = `
            <div class="container">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem;">
                    <h1>Product Management</h1>
                    <button onclick="showAddProductForm()">Add Product</button>
                </div>
                <table>
                    <thead>
                        <tr>
                            <th>Name</th>
                            <th>Price</th>
                            <th>Stock</th>
                            <th>Category</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
        `;

        products.forEach(product => {
            html += `
                <tr>
                    <td>${product.name}</td>
                    <td>$${product.price.toFixed(2)}</td>
                    <td>${product.stock}</td>
                    <td>${product.categoryName}</td>
                    <td>
                        <button onclick="editProduct('${product.id}')">Edit</button>
                        <button class="danger" onclick="deleteProduct('${product.id}')">Delete</button>
                    </td>
                </tr>
            `;
        });

        html += `
                    </tbody>
                </table>
                <div id="product-form-modal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 1000;">
                    <div style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); background: white; padding: 2rem; border-radius: 8px; max-width: 500px; width: 90%;">
                        <h2 id="form-title">Add Product</h2>
                        <form id="product-form" onsubmit="handleProductSubmit(event)">
                            <div class="form-group">
                                <label for="product-name">Name</label>
                                <input type="text" id="product-name" required>
                            </div>
                            <div class="form-group">
                                <label for="product-description">Description</label>
                                <textarea id="product-description" required></textarea>
                            </div>
                            <div class="form-group">
                                <label for="product-price">Price</label>
                                <input type="number" id="product-price" step="0.01" required>
                            </div>
                            <div class="form-group">
                                <label for="product-stock">Stock</label>
                                <input type="number" id="product-stock" required>
                            </div>
                            <div class="form-group">
                                <label for="product-category">Category</label>
                                <select id="product-category" required>
                                    <option value="">Select Category</option>
                                    ${categories.map(cat => `<option value="${cat.id}">${cat.name}</option>`).join('')}
                                </select>
                            </div>
                            <div class="form-group">
                                <label for="product-image">Image URL</label>
                                <input type="text" id="product-image">
                            </div>
                            <div style="display: flex; gap: 1rem; margin-top: 1rem;">
                                <button type="submit">Save</button>
                                <button type="button" onclick="hideProductForm()">Cancel</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        `;

        mainContent.innerHTML = html;
    } catch (error) {
        mainContent.innerHTML = `<div class="container"><div class="alert alert-error">Error loading products: ${error.message}</div></div>`;
    }
}

function showAddProductForm() {
    editingProduct = null;
    document.getElementById('form-title').textContent = 'Add Product';
    document.getElementById('product-form').reset();
    document.getElementById('product-form-modal').style.display = 'block';
}

async function editProduct(id) {
    try {
        const product = await api.getProduct(id);
        editingProduct = product;
        document.getElementById('form-title').textContent = 'Edit Product';
        document.getElementById('product-name').value = product.name;
        document.getElementById('product-description').value = product.description;
        document.getElementById('product-price').value = product.price;
        document.getElementById('product-stock').value = product.stock;
        document.getElementById('product-category').value = product.categoryId;
        document.getElementById('product-image').value = product.imageUrl;
        document.getElementById('product-form-modal').style.display = 'block';
    } catch (error) {
        showAlert('Error loading product: ' + error.message, 'error');
    }
}

function hideProductForm() {
    document.getElementById('product-form-modal').style.display = 'none';
    editingProduct = null;
}

async function handleProductSubmit(event) {
    event.preventDefault();

    const productData = {
        name: document.getElementById('product-name').value,
        description: document.getElementById('product-description').value,
        price: parseFloat(document.getElementById('product-price').value),
        stock: parseInt(document.getElementById('product-stock').value),
        categoryId: document.getElementById('product-category').value,
        imageUrl: document.getElementById('product-image').value
    };

    try {
        if (editingProduct) {
            await api.updateProduct(editingProduct.id, productData);
            showAlert('Product updated successfully', 'success');
        } else {
            await api.createProduct(productData);
            showAlert('Product created successfully', 'success');
        }
        hideProductForm();
        adminProductsPage();
    } catch (error) {
        showAlert('Error saving product: ' + error.message, 'error');
    }
}

async function deleteProduct(id) {
    if (!confirm('Are you sure you want to delete this product?')) {
        return;
    }

    try {
        await api.deleteProduct(id);
        showAlert('Product deleted successfully', 'success');
        adminProductsPage();
    } catch (error) {
        showAlert('Error deleting product: ' + error.message, 'error');
    }
}

