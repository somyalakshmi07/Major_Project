# Complete API Endpoints Reference

## 🔗 Base URLs

- **Auth Service:** http://localhost:5001
- **Catalog Service:** http://localhost:5002
- **Cart Service:** http://localhost:5003
- **Order Service:** http://localhost:5004
- **Payment Service:** http://localhost:5005
- **Frontend:** http://localhost:3000

---

## 🔐 Auth Service (Port 5001)

### Base URL: `http://localhost:5001/api/auth`

#### Register User
- **URL:** http://localhost:5001/api/auth/register
- **Method:** `POST`
- **Auth Required:** No
- **Body:**
```json
{
  "username": "string",
  "email": "string",
  "password": "string",
  "role": "user" | "admin"
}
```

#### Login
- **URL:** http://localhost:5001/api/auth/login
- **Method:** `POST`
- **Auth Required:** No
- **Body:**
```json
{
  "email": "string",
  "password": "string"
}
```

#### Validate Token
- **URL:** http://localhost:5001/api/auth/validate
- **Method:** `POST`
- **Auth Required:** No
- **Body:**
```json
{
  "token": "string"
}
```

#### Get Current User
- **URL:** http://localhost:5001/api/auth/me
- **Method:** `GET`
- **Auth Required:** Yes (Bearer Token)

#### Swagger UI
- **URL:** http://localhost:5001/swagger

---

## 📦 Catalog Service (Port 5002)

### Base URL: `http://localhost:5002/api`

#### Get All Products
- **URL:** http://localhost:5002/api/products
- **Method:** `GET`
- **Auth Required:** No

#### Get Product by ID
- **URL:** http://localhost:5002/api/products/{id}
- **Method:** `GET`
- **Auth Required:** No
- **Example:** http://localhost:5002/api/products/82fa519e-016b-47f1-b53b-b1038b2967ff

#### Search Products
- **URL:** http://localhost:5002/api/products/search?term={searchTerm}
- **Method:** `GET`
- **Auth Required:** No
- **Example:** http://localhost:5002/api/products/search?term=laptop

#### Get Products by Category
- **URL:** http://localhost:5002/api/products/category/{categoryId}
- **Method:** `GET`
- **Auth Required:** No
- **Example:** http://localhost:5002/api/products/category/82fa519e-016b-47f1-b53b-b1038b2967ff

#### Create Product (Admin Only)
- **URL:** http://localhost:5002/api/products
- **Method:** `POST`
- **Auth Required:** Yes (Admin Role)
- **Body:**
```json
{
  "name": "string",
  "description": "string",
  "price": 0.00,
  "stock": 0,
  "categoryId": "string",
  "imageUrl": "string"
}
```

#### Update Product (Admin Only)
- **URL:** http://localhost:5002/api/products/{id}
- **Method:** `PUT`
- **Auth Required:** Yes (Admin Role)
- **Body:** Same as Create Product

#### Delete Product (Admin Only)
- **URL:** http://localhost:5002/api/products/{id}
- **Method:** `DELETE`
- **Auth Required:** Yes (Admin Role)

#### Get All Categories
- **URL:** http://localhost:5002/api/categories
- **Method:** `GET`
- **Auth Required:** No

#### Get Category by ID
- **URL:** http://localhost:5002/api/categories/{id}
- **Method:** `GET`
- **Auth Required:** No

#### Create Category (Admin Only)
- **URL:** http://localhost:5002/api/categories
- **Method:** `POST`
- **Auth Required:** Yes (Admin Role)
- **Body:**
```json
{
  "name": "string",
  "description": "string"
}
```

#### Swagger UI
- **URL:** http://localhost:5002/swagger

---

## 🛒 Cart Service (Port 5003)

### Base URL: `http://localhost:5003/api/cart`

#### Get User Cart
- **URL:** http://localhost:5003/api/cart
- **Method:** `GET`
- **Auth Required:** Yes (Bearer Token)

#### Add Item to Cart
- **URL:** http://localhost:5003/api/cart/items
- **Method:** `POST`
- **Auth Required:** Yes (Bearer Token)
- **Body:**
```json
{
  "productId": "string",
  "productName": "string",
  "price": 0.00,
  "quantity": 1,
  "imageUrl": "string"
}
```

#### Update Item Quantity
- **URL:** http://localhost:5003/api/cart/items/{productId}
- **Method:** `PUT`
- **Auth Required:** Yes (Bearer Token)
- **Body:**
```json
{
  "quantity": 1
}
```

#### Remove Item from Cart
- **URL:** http://localhost:5003/api/cart/items/{productId}
- **Method:** `DELETE`
- **Auth Required:** Yes (Bearer Token)

#### Clear Cart
- **URL:** http://localhost:5003/api/cart/clear
- **Method:** `DELETE`
- **Auth Required:** Yes (Bearer Token)

#### Swagger UI
- **URL:** http://localhost:5003/swagger

---

## 📋 Order Service (Port 5004)

### Base URL: `http://localhost:5004/api/orders`

#### Get Orders
- **URL:** http://localhost:5004/api/orders
- **Method:** `GET`
- **Auth Required:** Yes (Bearer Token)
- **Note:** Returns user's own orders (or all orders if admin)

#### Get Order by ID
- **URL:** http://localhost:5004/api/orders/{id}
- **Method:** `GET`
- **Auth Required:** Yes (Bearer Token)
- **Example:** http://localhost:5004/api/orders/82fa519e-016b-47f1-b53b-b1038b2967ff

#### Create Order
- **URL:** http://localhost:5004/api/orders
- **Method:** `POST`
- **Auth Required:** Yes (Bearer Token)
- **Body:**
```json
{
  "items": [
    {
      "productId": "string",
      "productName": "string",
      "price": 0.00,
      "quantity": 1
    }
  ]
}
```

#### Update Order Status (Admin Only)
- **URL:** http://localhost:5004/api/orders/{id}/status
- **Method:** `PUT`
- **Auth Required:** Yes (Admin Role)
- **Body:**
```json
{
  "status": "Pending" | "Processing" | "Shipped" | "Delivered" | "Cancelled"
}
```

#### Swagger UI
- **URL:** http://localhost:5004/swagger

---

## 💳 Payment Service (Port 5005)

### Base URL: `http://localhost:5005/api/payments`

#### Process Payment
- **URL:** http://localhost:5005/api/payments/process
- **Method:** `POST`
- **Auth Required:** No
- **Body:**
```json
{
  "orderId": "string",
  "amount": 0.00,
  "paymentMethod": "string"
}
```

#### Swagger UI
- **URL:** http://localhost:5005/swagger

---

## 🌐 Frontend Application

### Main Application
- **URL:** http://localhost:3000

### Frontend Routes
- **Home:** http://localhost:3000/#home
- **Login:** http://localhost:3000/#login
- **Register:** http://localhost:3000/#register
- **Cart:** http://localhost:3000/#cart
- **Orders:** http://localhost:3000/#orders
- **Admin:** http://localhost:3000/#admin (Admin only)

---

## 🔑 Authentication

### How to Get a Token

1. **Register a new user:**
```powershell
$register = @{
    username = "testuser"
    email = "test@example.com"
    password = "Test123!"
    role = "user"
} | ConvertTo-Json

Invoke-RestMethod -Uri http://localhost:5001/api/auth/register `
    -Method POST `
    -ContentType "application/json" `
    -Body $register
```

2. **Login to get token:**
```powershell
$login = @{
    email = "test@example.com"
    password = "Test123!"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri http://localhost:5001/api/auth/login `
    -Method POST `
    -ContentType "application/json" `
    -Body $login

$token = $response.token
```

3. **Use token in requests:**
```powershell
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

Invoke-RestMethod -Uri http://localhost:5003/api/cart `
    -Method GET `
    -Headers $headers
```

---

## 📝 Quick Test Commands

### Test Products Endpoint
```powershell
Invoke-RestMethod -Uri http://localhost:5002/api/products
```

### Test Categories Endpoint
```powershell
Invoke-RestMethod -Uri http://localhost:5002/api/categories
```

### Test Auth (Login)
```powershell
$login = @{email="admin@example.com";password="Admin123!"} | ConvertTo-Json
Invoke-RestMethod -Uri http://localhost:5001/api/auth/login -Method POST -ContentType "application/json" -Body $login
```

---

## 🎯 Default Admin Credentials

- **Email:** admin@example.com
- **Password:** Admin123!
- **Role:** admin

---

## 📚 Swagger Documentation

All services have Swagger UI for interactive API testing:

- **Auth Service:** http://localhost:5001/swagger
- **Catalog Service:** http://localhost:5002/swagger
- **Cart Service:** http://localhost:5003/swagger
- **Order Service:** http://localhost:5004/swagger
- **Payment Service:** http://localhost:5005/swagger

---

## 🔄 Complete User Flow Example

1. **Register:** http://localhost:5001/api/auth/register
2. **Login:** http://localhost:5001/api/auth/login (get token)
3. **Browse Products:** http://localhost:5002/api/products
4. **Add to Cart:** http://localhost:5003/api/cart/items (with token)
5. **View Cart:** http://localhost:5003/api/cart (with token)
6. **Create Order:** http://localhost:5004/api/orders (with token)
7. **Process Payment:** http://localhost:5005/api/payments/process
8. **View Orders:** http://localhost:5004/api/orders (with token)

---

## 📞 All Endpoints Summary

### Public Endpoints (No Auth)
- `GET http://localhost:5002/api/products`
- `GET http://localhost:5002/api/products/{id}`
- `GET http://localhost:5002/api/products/search?term={term}`
- `GET http://localhost:5002/api/products/category/{categoryId}`
- `GET http://localhost:5002/api/categories`
- `GET http://localhost:5002/api/categories/{id}`
- `POST http://localhost:5001/api/auth/register`
- `POST http://localhost:5001/api/auth/login`
- `POST http://localhost:5001/api/auth/validate`
- `POST http://localhost:5005/api/payments/process`

### Protected Endpoints (Require Auth)
- `GET http://localhost:5001/api/auth/me`
- `GET http://localhost:5003/api/cart`
- `POST http://localhost:5003/api/cart/items`
- `PUT http://localhost:5003/api/cart/items/{productId}`
- `DELETE http://localhost:5003/api/cart/items/{productId}`
- `DELETE http://localhost:5003/api/cart/clear`
- `GET http://localhost:5004/api/orders`
- `GET http://localhost:5004/api/orders/{id}`
- `POST http://localhost:5004/api/orders`

### Admin Only Endpoints
- `POST http://localhost:5002/api/products`
- `PUT http://localhost:5002/api/products/{id}`
- `DELETE http://localhost:5002/api/products/{id}`
- `POST http://localhost:5002/api/categories`
- `PUT http://localhost:5004/api/orders/{id}/status`

