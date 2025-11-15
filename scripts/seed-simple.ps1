# Simple Data Seeding Script
Write-Host "=== Seeding E-Commerce Data ===" -ForegroundColor Green
Write-Host ""

# Step 1: Create Admin User
Write-Host "Step 1: Creating admin user..." -ForegroundColor Cyan
try {
    $registerData = @{
        username = "admin"
        email = "admin@example.com"
        password = "Admin123!"
        role = "admin"
    } | ConvertTo-Json

    $registerResponse = Invoke-RestMethod -Uri "http://localhost:5001/api/auth/register" `
        -Method POST `
        -ContentType "application/json" `
        -Body $registerData `
        -ErrorAction Stop

    Write-Host "  ✓ Admin user created" -ForegroundColor Green
} catch {
    if ($_.Exception.Response.StatusCode -eq 400) {
        Write-Host "  - Admin user already exists" -ForegroundColor Yellow
    } else {
        Write-Host "  ✗ Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Step 2: Login as Admin
Write-Host "`nStep 2: Logging in as admin..." -ForegroundColor Cyan
try {
    $loginData = @{
        email = "admin@example.com"
        password = "Admin123!"
    } | ConvertTo-Json

    $loginResponse = Invoke-RestMethod -Uri "http://localhost:5001/api/auth/login" `
        -Method POST `
        -ContentType "application/json" `
        -Body $loginData `
        -ErrorAction Stop

    $token = $loginResponse.token
    Write-Host "  ✓ Login successful" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Login failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "  Make sure Auth Service is running on port 5001" -ForegroundColor Yellow
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# Step 3: Create Categories
Write-Host "`nStep 3: Creating categories..." -ForegroundColor Cyan
$categories = @(
    @{ name = "Electronics"; description = "Electronic devices" },
    @{ name = "Clothing"; description = "Apparel and fashion" },
    @{ name = "Books"; description = "Books and reading" },
    @{ name = "Home & Garden"; description = "Home improvement" },
    @{ name = "Sports"; description = "Sports equipment" }
)

$categoryIds = @()
foreach ($cat in $categories) {
    try {
        $catData = $cat | ConvertTo-Json
        $response = Invoke-RestMethod -Uri "http://localhost:5002/api/categories" `
            -Method POST `
            -Headers $headers `
            -Body $catData `
            -ErrorAction Stop
        
        $categoryIds += $response.id
        Write-Host "  ✓ Created: $($cat.name)" -ForegroundColor Green
    } catch {
        if ($_.Exception.Response.StatusCode -eq 400) {
            Write-Host "  - $($cat.name) already exists" -ForegroundColor Yellow
            # Try to get existing categories
            try {
                $existing = Invoke-RestMethod -Uri "http://localhost:5002/api/categories" -ErrorAction Stop
                $existingCat = $existing | Where-Object { $_.name -eq $cat.name }
                if ($existingCat) {
                    $categoryIds += $existingCat.id
                }
            } catch {}
        } else {
            Write-Host "  ✗ Error creating $($cat.name): $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# If no categories, try to get existing ones
if ($categoryIds.Count -eq 0) {
    Write-Host "  Fetching existing categories..." -ForegroundColor Yellow
    try {
        $existing = Invoke-RestMethod -Uri "http://localhost:5002/api/categories" -ErrorAction Stop
        $categoryIds = $existing | ForEach-Object { $_.id }
        Write-Host "  Found $($categoryIds.Count) existing categories" -ForegroundColor Green
    } catch {
        Write-Host "  ✗ Could not fetch categories" -ForegroundColor Red
    }
}

# Step 4: Create Products
Write-Host "`nStep 4: Creating products..." -ForegroundColor Cyan
$products = @(
    @{ name = "Laptop Pro 15"; description = "High-performance laptop"; price = 1299.99; stock = 50; categoryId = $categoryIds[0]; imageUrl = "https://via.placeholder.com/300?text=Laptop" },
    @{ name = "Wireless Mouse"; description = "Ergonomic wireless mouse"; price = 29.99; stock = 200; categoryId = $categoryIds[0]; imageUrl = "https://via.placeholder.com/300?text=Mouse" },
    @{ name = "Smartphone X"; description = "Latest smartphone"; price = 899.99; stock = 75; categoryId = $categoryIds[0]; imageUrl = "https://via.placeholder.com/300?text=Phone" },
    @{ name = "Cotton T-Shirt"; description = "Comfortable cotton t-shirt"; price = 19.99; stock = 150; categoryId = $categoryIds[1]; imageUrl = "https://via.placeholder.com/300?text=T-Shirt" },
    @{ name = "Jeans Classic"; description = "Classic fit jeans"; price = 49.99; stock = 100; categoryId = $categoryIds[1]; imageUrl = "https://via.placeholder.com/300?text=Jeans" },
    @{ name = "Programming Book"; description = "Complete programming guide"; price = 39.99; stock = 80; categoryId = $categoryIds[2]; imageUrl = "https://via.placeholder.com/300?text=Book" },
    @{ name = "Garden Tools Set"; description = "Complete garden tools"; price = 79.99; stock = 40; categoryId = $categoryIds[3]; imageUrl = "https://via.placeholder.com/300?text=Tools" },
    @{ name = "Basketball"; description = "Professional basketball"; price = 24.99; stock = 60; categoryId = $categoryIds[4]; imageUrl = "https://via.placeholder.com/300?text=Basketball" }
)

$productCount = 0
foreach ($product in $products) {
    try {
        $prodData = $product | ConvertTo-Json
        $response = Invoke-RestMethod -Uri "http://localhost:5002/api/products" `
            -Method POST `
            -Headers $headers `
            -Body $prodData `
            -ErrorAction Stop
        
        $productCount++
        Write-Host "  ✓ Created: $($product.name)" -ForegroundColor Green
    } catch {
        Write-Host "  ✗ Error creating $($product.name): $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# Summary
Write-Host "`n=== Seeding Complete ===" -ForegroundColor Green
Write-Host "  Categories: $($categoryIds.Count)" -ForegroundColor Cyan
Write-Host "  Products: $productCount" -ForegroundColor Cyan
Write-Host "`nAccess the application at: http://localhost:3000" -ForegroundColor Yellow
Write-Host "Admin login: admin@example.com / Admin123!" -ForegroundColor Yellow

