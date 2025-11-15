const routes = {
    'home': 'pages/home.js',
    'login': 'pages/login.js',
    'register': 'pages/register.js',
    'product': 'pages/product-details.js',
    'cart': 'pages/cart.js',
    'checkout': 'pages/checkout.js',
    'payment': 'pages/payment.js',
    'orders': 'pages/orders.js',
    'admin': 'pages/admin.js',
    'admin-products': 'pages/admin-products.js',
    'admin-orders': 'pages/admin-orders.js'
};

function loadPage(pageName, params = []) {
    const mainContent = document.getElementById('main-content');
    window.location.hash = `#${pageName}${params.length > 0 ? '/' + params.join('/') : ''}`;
    
    if (routes[pageName] && window[pageName + 'Page']) {
        window[pageName + 'Page'](params);
    } else {
        mainContent.innerHTML = '<div class="container"><h1>Page not found</h1></div>';
    }
}

function initRouter() {
    window.addEventListener('hashchange', () => {
        const hash = window.location.hash.substring(1);
        const [page, ...params] = hash.split('/');
        loadPage(page || 'home', params);
    });

    const hash = window.location.hash.substring(1);
    const [page, ...params] = hash.split('/');
    loadPage(page || 'home', params);
}

