# Complete Setup Guide

## 🚀 Quick Start (5 Minutes)

### Step 1: Start All Services
```powershell
docker-compose up -d --build
```

Wait for all containers to start (about 1-2 minutes).

### Step 2: Verify Services Are Running
```powershell
docker-compose ps
```

All services should show "Up" status.

### Step 3: Seed Initial Data
```powershell
.\scripts\seed-data.ps1
```

This creates:
- Admin user: `admin@example.com` / `Admin123!`
- 5 Categories (Electronics, Clothing, Books, Home & Garden, Sports)
- 8 Sample Products

### Step 4: Access the Application

**Main Application:**
- Frontend: http://localhost:3000

**API Documentation:**
- Auth Service: http://localhost:5001/swagger
- Catalog Service: http://localhost:5002/swagger
- Cart Service: http://localhost:5003/swagger
- Order Service: http://localhost:5004/swagger
- Payment Service: http://localhost:5005/swagger

### Step 5: Test the Application

1. **Register a New User:**
   - Go to http://localhost:3000
   - Click "Login" → "Register"
   - Fill in the registration form
   - Click "Register"

2. **Login:**
   - Use your credentials or admin: `admin@example.com` / `Admin123!`

3. **Browse Products:**
   - View products on the home page
   - Search for products
   - Filter by category

4. **Add to Cart:**
   - Click "Add to Cart" on any product
   - View cart by clicking "Cart" in navigation

5. **Place an Order:**
   - Go to Cart
   - Click "Checkout"
   - Complete the order process

6. **Admin Functions:**
   - Login as admin
   - Click "Admin" in navigation
   - Manage products and categories
   - View all orders

## 📋 Complete Project Overview

### Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Frontend (Port 3000)                   │
│              HTML/CSS/JavaScript SPA                      │
└─────────────────────────────────────────────────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
┌───────▼──────┐  ┌───────▼──────┐  ┌───────▼──────┐
│ Auth Service │  │Catalog Service│  │ Cart Service │
│  (Port 5001) │  │  (Port 5002) │  │  (Port 5003) │
│  PostgreSQL  │  │   MongoDB    │  │ Redis+Mongo  │
└──────────────┘  └──────────────┘  └──────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
┌───────▼──────┐  ┌───────▼──────┐
│Order Service │  │Payment Service│
│  (Port 5004) │  │  (Port 5005)  │
│  SQL Server  │  │   (Stateless) │
└──────────────┘  └───────────────┘
```

### Service Details

#### 1. Auth Service (Port 5001)
- **Database:** PostgreSQL
- **Features:**
  - User registration
  - User login with JWT
  - Token validation
  - Role-based access (User/Admin)
- **Endpoints:**
  - `POST /api/auth/register` - Register new user
  - `POST /api/auth/login` - Login and get JWT token
  - `POST /api/auth/validate` - Validate token
  - `GET /api/auth/me` - Get current user info

#### 2. Catalog Service (Port 5002)
- **Database:** MongoDB
- **Features:**
  - Product management
  - Category management
  - Product search
  - Category filtering
- **Endpoints:**
  - `GET /api/products` - Get all products
  - `GET /api/products/{id}` - Get product by ID
  - `GET /api/products/search?term={term}` - Search products
  - `GET /api/products/category/{categoryId}` - Get products by category
  - `POST /api/products` - Create product (Admin only)
  - `PUT /api/products/{id}` - Update product (Admin only)
  - `DELETE /api/products/{id}` - Delete product (Admin only)
  - `GET /api/categories` - Get all categories
  - `POST /api/categories` - Create category (Admin only)

#### 3. Cart Service (Port 5003)
- **Databases:** MongoDB (persistence) + Redis (cache)
- **Features:**
  - Per-user shopping cart
  - Add/remove items
  - Update quantities
  - Cart expiration (TTL)
- **Endpoints:**
  - `GET /api/cart` - Get user's cart
  - `POST /api/cart/items` - Add item to cart
  - `PUT /api/cart/items/{productId}` - Update item quantity
  - `DELETE /api/cart/items/{productId}` - Remove item
  - `DELETE /api/cart/clear` - Clear cart

#### 4. Order Service (Port 5004)
- **Database:** SQL Server
- **Features:**
  - Order creation
  - Order tracking
  - Order status management
  - User-specific orders
- **Endpoints:**
  - `GET /api/orders` - Get orders (user's own or all if admin)
  - `GET /api/orders/{id}` - Get order by ID
  - `POST /api/orders` - Create order
  - `PUT /api/orders/{id}/status` - Update order status (Admin only)

#### 5. Payment Service (Port 5005)
- **Database:** None (stateless)
- **Features:**
  - Payment processing simulation
  - Random success/failure (85% success rate)
  - Integration with Order Service
- **Endpoints:**
  - `POST /api/payments/process` - Process payment

### Frontend Application

**Location:** http://localhost:3000

**Features:**
- User registration and login
- Product browsing and search
- Shopping cart management
- Order placement
- Order history
- Admin dashboard (for admin users)

**Pages:**
- Home - Browse products
- Product Details - View product information
- Cart - Manage shopping cart
- Checkout - Place order
- Orders - View order history
- Login/Register - Authentication
- Admin - Admin dashboard (products, orders management)

## 🔧 Troubleshooting

### Services Not Starting

1. **Check Docker is running:**
   ```powershell
   docker ps
   ```

2. **Check service logs:**
   ```powershell
   docker-compose logs auth-service
   docker-compose logs catalog-service
   # etc.
   ```

3. **Restart services:**
   ```powershell
   docker-compose restart
   ```

### Database Connection Issues

1. **Verify databases are running:**
   ```powershell
   docker-compose ps | findstr postgres
   docker-compose ps | findstr mongo
   docker-compose ps | findstr redis
   docker-compose ps | findstr sqlserver
   ```

2. **Check connection strings in docker-compose.yml**

### Frontend Can't Connect to APIs

1. **Verify all services are running:**
   ```powershell
   docker-compose ps
   ```

2. **Test API endpoints:**
   ```powershell
   .\scripts\test-api.ps1
   ```

3. **Check browser console for errors (F12)**

### No Products Showing

1. **Run the seeding script:**
   ```powershell
   .\scripts\seed-data.ps1
   ```

2. **Verify Catalog Service is running:**
   ```powershell
   Invoke-WebRequest -Uri http://localhost:5002/api/products
   ```

### Authentication Issues

1. **Verify JWT secret is the same in all services** (check docker-compose.yml)

2. **Check token expiration** (default: 60 minutes)

3. **Clear browser localStorage:**
   - Open browser console (F12)
   - Run: `localStorage.clear()`
   - Refresh page

## 📊 Monitoring

### View Logs
```powershell
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f auth-service
docker-compose logs -f catalog-service
```

### Check Service Health
```powershell
# Test all APIs
.\scripts\test-api.ps1

# Check container status
docker-compose ps
```

## 🗑️ Cleanup

### Stop All Services
```powershell
docker-compose down
```

### Remove All Data (Volumes)
```powershell
docker-compose down -v
```

### Remove Images
```powershell
docker-compose down --rmi all
```

## 📝 Next Steps

1. **Customize Products:** Use admin panel to add your own products
2. **Configure Payment:** Modify payment success rate in docker-compose.yml
3. **Add Features:** Extend services with additional functionality
4. **Deploy:** Use Kubernetes manifests for production deployment

## 🆘 Need Help?

- Check service logs: `docker-compose logs <service-name>`
- Test APIs: `.\scripts\test-api.ps1`
- Review Swagger docs: http://localhost:500X/swagger
- Check browser console for frontend errors

