# Quick Data Seeding
Write-Host "Seeding data..." -ForegroundColor Green

# Login
$loginData = @{email="admin@example.com";password="Admin123!"} | ConvertTo-Json
$loginResponse = Invoke-RestMethod -Uri "http://localhost:5001/api/auth/login" -Method POST -ContentType "application/json" -Body $loginData
$token = $loginResponse.token
$headers = @{"Authorization"="Bearer $token";"Content-Type"="application/json"}

Write-Host "Logged in successfully" -ForegroundColor Green

# Create Categories
$categories = @(
    @{name="Electronics";description="Electronic devices"},
    @{name="Clothing";description="Apparel and fashion"},
    @{name="Books";description="Books and reading"},
    @{name="Home & Garden";description="Home improvement"},
    @{name="Sports";description="Sports equipment"}
)

$categoryIds = @()
foreach ($cat in $categories) {
    try {
        $catData = $cat | ConvertTo-Json
        $response = Invoke-RestMethod -Uri "http://localhost:5002/api/categories" -Method POST -Headers $headers -Body $catData
        $categoryIds += $response.id
        Write-Host "Created category: $($cat.name)" -ForegroundColor Green
    } catch {
        # Try to get existing
        $existing = Invoke-RestMethod -Uri "http://localhost:5002/api/categories"
        $found = $existing | Where-Object { $_.name -eq $cat.name }
        if ($found) { $categoryIds += $found.id; Write-Host "Category exists: $($cat.name)" -ForegroundColor Yellow }
    }
}

# Get all categories if needed
if ($categoryIds.Count -eq 0) {
    $existing = Invoke-RestMethod -Uri "http://localhost:5002/api/categories"
    $categoryIds = $existing | ForEach-Object { $_.id }
}

# Create Products
$products = @(
    @{name="Laptop Pro 15";description="High-performance laptop";price=1299.99;stock=50;categoryId=$categoryIds[0];imageUrl="https://via.placeholder.com/300?text=Laptop"},
    @{name="Wireless Mouse";description="Ergonomic wireless mouse";price=29.99;stock=200;categoryId=$categoryIds[0];imageUrl="https://via.placeholder.com/300?text=Mouse"},
    @{name="Smartphone X";description="Latest smartphone";price=899.99;stock=75;categoryId=$categoryIds[0];imageUrl="https://via.placeholder.com/300?text=Phone"},
    @{name="Cotton T-Shirt";description="Comfortable cotton t-shirt";price=19.99;stock=150;categoryId=$categoryIds[1];imageUrl="https://via.placeholder.com/300?text=T-Shirt"},
    @{name="Jeans Classic";description="Classic fit jeans";price=49.99;stock=100;categoryId=$categoryIds[1];imageUrl="https://via.placeholder.com/300?text=Jeans"},
    @{name="Programming Book";description="Complete programming guide";price=39.99;stock=80;categoryId=$categoryIds[2];imageUrl="https://via.placeholder.com/300?text=Book"},
    @{name="Garden Tools Set";description="Complete garden tools";price=79.99;stock=40;categoryId=$categoryIds[3];imageUrl="https://via.placeholder.com/300?text=Tools"},
    @{name="Basketball";description="Professional basketball";price=24.99;stock=60;categoryId=$categoryIds[4];imageUrl="https://via.placeholder.com/300?text=Basketball"}
)

$count = 0
foreach ($prod in $products) {
    try {
        $prodData = $prod | ConvertTo-Json
        Invoke-RestMethod -Uri "http://localhost:5002/api/products" -Method POST -Headers $headers -Body $prodData | Out-Null
        $count++
        Write-Host "Created product: $($prod.name)" -ForegroundColor Green
    } catch {
        Write-Host "Error: $($prod.name)" -ForegroundColor Yellow
    }
}

Write-Host "`nDone! Created $count products. Refresh http://localhost:3000" -ForegroundColor Cyan

