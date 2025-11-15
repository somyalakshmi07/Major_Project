# Data Seeding Script for E-Commerce Microservices
# This script seeds initial data into the Catalog Service

Write-Host "Seeding initial data..." -ForegroundColor Green

# Wait for services to be ready
Write-Host "Waiting for services to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# If no admin user exists, create one first
Write-Host "`nCreating admin user..." -ForegroundColor Cyan
$adminCreated = $false
try {
    $registerBody = @{
        username = "admin"
        email = "admin@example.com"
        password = "Admin123!"
        role = "admin"
    } | ConvertTo-Json

    $registerResponse = Invoke-WebRequest -Uri "http://localhost:5001/api/auth/register" `
        -Method POST `
        -ContentType "application/json" `
        -Body $registerBody `
        -ErrorAction Stop

    if ($registerResponse.StatusCode -eq 200) {
        Write-Host "  Admin user created successfully" -ForegroundColor Green
        $adminCreated = $true
    }
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    if ($statusCode -eq 400) {
        Write-Host "  Admin user already exists" -ForegroundColor Yellow
    } else {
        Write-Host "  Error creating admin user: $_" -ForegroundColor Red
        Write-Host "  Status: $statusCode" -ForegroundColor Red
    }
}

# Login as admin
Write-Host "`nLogging in as admin..." -ForegroundColor Cyan
$token = $null
try {
    $loginBody = @{
        email = "admin@example.com"
        password = "Admin123!"
    } | ConvertTo-Json

    $loginResponse = Invoke-WebRequest -Uri "http://localhost:5001/api/auth/login" `
        -Method POST `
        -ContentType "application/json" `
        -Body $loginBody `
        -ErrorAction Stop

    if ($loginResponse.StatusCode -eq 200) {
        $authData = $loginResponse.Content | ConvertFrom-Json
        $token = $authData.token
        Write-Host "  Login successful" -ForegroundColor Green
    } else {
        Write-Host "  Login failed with status: $($loginResponse.StatusCode)" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "  Login error: $_" -ForegroundColor Red
    Write-Host "  Make sure Auth Service is running on http://localhost:5001" -ForegroundColor Yellow
    exit 1
}

if (-not $token) {
    Write-Host "  Failed to obtain authentication token" -ForegroundColor Red
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# Define Categories
$categories = @(
    @{
        name = "Electronics"
        description = "Electronic devices and gadgets"
    },
    @{
        name = "Clothing"
        description = "Apparel and fashion items"
    },
    @{
        name = "Books"
        description = "Books and reading materials"
    },
    @{
        name = "Home & Garden"
        description = "Home improvement and garden supplies"
    },
    @{
        name = "Sports"
        description = "Sports equipment and accessories"
    }
)

# Create Categories
Write-Host "`nCreating categories..." -ForegroundColor Cyan
$categoryIds = @()

foreach ($category in $categories) {
    try {
        $body = $category | ConvertTo-Json
        $response = Invoke-WebRequest -Uri "http://localhost:5002/api/categories" `
            -Method POST `
            -Headers $headers `
            -Body $body `
            -ErrorAction Stop
        
        if ($response.StatusCode -eq 201) {
            $catData = $response.Content | ConvertFrom-Json
            $categoryIds += $catData.id
            Write-Host "  ✓ Created category: $($category.name)" -ForegroundColor Green
        }
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        if ($statusCode -eq 400) {
            Write-Host "  - Category '$($category.name)' may already exist" -ForegroundColor Yellow
        } else {
            Write-Host "  ✗ Error creating category $($category.name): Status $statusCode" -ForegroundColor Red
        }
    }
}

# If no categories were created, try to get existing ones
if ($categoryIds.Count -eq 0) {
    Write-Host "`nFetching existing categories..." -ForegroundColor Cyan
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:5002/api/categories" -UseBasicParsing
        $existingCategories = $response.Content | ConvertFrom-Json
        $categoryIds = $existingCategories | ForEach-Object { $_.id }
        Write-Host "  Found $($categoryIds.Count) existing categories" -ForegroundColor Green
    } catch {
        Write-Host "  Could not fetch categories" -ForegroundColor Red
    }
}

# Create Products
Write-Host "`nCreating products..." -ForegroundColor Cyan

$products = @(
    @{
        name = "Laptop Pro 15"
        description = "High-performance laptop with 16GB RAM and 512GB SSD"
        price = 1299.99
        stock = 50
        categoryId = $categoryIds[0]
        imageUrl = "https://via.placeholder.com/300?text=Laptop"
    },
    @{
        name = "Wireless Mouse"
        description = "Ergonomic wireless mouse with long battery life"
        price = 29.99
        stock = 200
        categoryId = $categoryIds[0]
        imageUrl = "https://via.placeholder.com/300?text=Mouse"
    },
    @{
        name = "Smartphone X"
        description = "Latest smartphone with advanced camera system"
        price = 899.99
        stock = 75
        categoryId = $categoryIds[0]
        imageUrl = "https://via.placeholder.com/300?text=Phone"
    },
    @{
        name = "Cotton T-Shirt"
        description = "Comfortable 100% cotton t-shirt"
        price = 19.99
        stock = 150
        categoryId = $categoryIds[1]
        imageUrl = "https://via.placeholder.com/300?text=T-Shirt"
    },
    @{
        name = "Jeans Classic"
        description = "Classic fit denim jeans"
        price = 49.99
        stock = 100
        categoryId = $categoryIds[1]
        imageUrl = "https://via.placeholder.com/300?text=Jeans"
    },
    @{
        name = "Programming Book"
        description = "Complete guide to modern programming"
        price = 39.99
        stock = 80
        categoryId = $categoryIds[2]
        imageUrl = "https://via.placeholder.com/300?text=Book"
    },
    @{
        name = "Garden Tools Set"
        description = "Complete set of garden tools"
        price = 79.99
        stock = 40
        categoryId = $categoryIds[3]
        imageUrl = "https://via.placeholder.com/300?text=Tools"
    },
    @{
        name = "Basketball"
        description = "Professional basketball"
        price = 24.99
        stock = 60
        categoryId = $categoryIds[4]
        imageUrl = "https://via.placeholder.com/300?text=Basketball"
    }
)

$productCount = 0
foreach ($product in $products) {
    try {
        $body = $product | ConvertTo-Json
        $response = Invoke-WebRequest -Uri "http://localhost:5002/api/products" `
            -Method POST `
            -Headers $headers `
            -Body $body `
            -ErrorAction Stop
        
        if ($response.StatusCode -eq 201) {
            $productCount++
            Write-Host "  Created product: $($product.name)" -ForegroundColor Green
        }
    } catch {
        Write-Host "  Error creating product $($product.name): $_" -ForegroundColor Yellow
    }
}

Write-Host "`nSeeding completed!" -ForegroundColor Green
Write-Host "  Categories created: $($categoryIds.Count)" -ForegroundColor Cyan
Write-Host "  Products created: $productCount" -ForegroundColor Cyan
Write-Host "`nYou can now access the frontend at http://localhost:3000" -ForegroundColor Yellow

