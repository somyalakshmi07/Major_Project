const API_CONFIG = {
    AUTH_SERVICE: 'http://localhost:5001/api',
    CATALOG_SERVICE: 'http://localhost:5002/api',
    CART_SERVICE: 'http://localhost:5003/api',
    ORDER_SERVICE: 'http://localhost:5004/api',
    PAYMENT_SERVICE: 'http://localhost:5005/api'
};

class ApiService {
    constructor() {
        this.token = localStorage.getItem('token');
    }

    setToken(token) {
        this.token = token;
        if (token) {
            localStorage.setItem('token', token);
        } else {
            localStorage.removeItem('token');
        }
    }

    getHeaders(includeAuth = true) {
        const headers = {
            'Content-Type': 'application/json'
        };
        if (includeAuth && this.token) {
            headers['Authorization'] = `Bearer ${this.token}`;
        }
        return headers;
    }

    async request(url, options = {}) {
        try {
            const response = await fetch(url, {
                ...options,
                headers: {
                    ...this.getHeaders(options.auth !== false),
                    ...options.headers
                }
            });

            if (response.status === 401) {
                this.setToken(null);
                window.location.hash = '#login';
                throw new Error('Unauthorized');
            }

            const data = await response.json();
            
            if (!response.ok) {
                throw new Error(data.message || 'An error occurred');
            }

            return data;
        } catch (error) {
            console.error('API Error:', error);
            throw error;
        }
    }

    // Auth Service
    async register(data) {
        return this.request(`${API_CONFIG.AUTH_SERVICE}/auth/register`, {
            method: 'POST',
            body: JSON.stringify(data),
            auth: false
        });
    }

    async login(email, password) {
        return this.request(`${API_CONFIG.AUTH_SERVICE}/auth/login`, {
            method: 'POST',
            body: JSON.stringify({ email, password }),
            auth: false
        });
    }

    async getCurrentUser() {
        return this.request(`${API_CONFIG.AUTH_SERVICE}/auth/me`);
    }

    // Catalog Service
    async getProducts() {
        return this.request(`${API_CONFIG.CATALOG_SERVICE}/products`);
    }

    async getProduct(id) {
        return this.request(`${API_CONFIG.CATALOG_SERVICE}/products/${id}`);
    }

    async searchProducts(term) {
        return this.request(`${API_CONFIG.CATALOG_SERVICE}/products/search?term=${encodeURIComponent(term)}`);
    }

    async getCategories() {
        return this.request(`${API_CONFIG.CATALOG_SERVICE}/categories`);
    }

    async createProduct(data) {
        return this.request(`${API_CONFIG.CATALOG_SERVICE}/products`, {
            method: 'POST',
            body: JSON.stringify(data)
        });
    }

    async updateProduct(id, data) {
        return this.request(`${API_CONFIG.CATALOG_SERVICE}/products/${id}`, {
            method: 'PUT',
            body: JSON.stringify(data)
        });
    }

    async deleteProduct(id) {
        return this.request(`${API_CONFIG.CATALOG_SERVICE}/products/${id}`, {
            method: 'DELETE'
        });
    }

    async createCategory(data) {
        return this.request(`${API_CONFIG.CATALOG_SERVICE}/categories`, {
            method: 'POST',
            body: JSON.stringify(data)
        });
    }

    // Cart Service
    async getCart() {
        return this.request(`${API_CONFIG.CART_SERVICE}/cart`);
    }

    async addToCart(item) {
        return this.request(`${API_CONFIG.CART_SERVICE}/cart/items`, {
            method: 'POST',
            body: JSON.stringify(item)
        });
    }

    async updateCartItem(productId, quantity) {
        return this.request(`${API_CONFIG.CART_SERVICE}/cart/items/${productId}`, {
            method: 'PUT',
            body: JSON.stringify({ quantity })
        });
    }

    async removeFromCart(productId) {
        return this.request(`${API_CONFIG.CART_SERVICE}/cart/items/${productId}`, {
            method: 'DELETE'
        });
    }

    async clearCart() {
        return this.request(`${API_CONFIG.CART_SERVICE}/cart/clear`, {
            method: 'DELETE'
        });
    }

    // Order Service
    async getOrders() {
        return this.request(`${API_CONFIG.ORDER_SERVICE}/orders`);
    }

    async getOrder(id) {
        return this.request(`${API_CONFIG.ORDER_SERVICE}/orders/${id}`);
    }

    async createOrder(items) {
        return this.request(`${API_CONFIG.ORDER_SERVICE}/orders`, {
            method: 'POST',
            body: JSON.stringify({ items })
        });
    }

    async updateOrderStatus(id, status) {
        return this.request(`${API_CONFIG.ORDER_SERVICE}/orders/${id}/status`, {
            method: 'PUT',
            body: JSON.stringify({ status })
        });
    }

    // Payment Service
    async processPayment(data) {
        return this.request(`${API_CONFIG.PAYMENT_SERVICE}/payments/process`, {
            method: 'POST',
            body: JSON.stringify(data),
            auth: false
        });
    }
}

const api = new ApiService();

