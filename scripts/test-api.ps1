# API Testing Script
# Tests all microservice endpoints

Write-Host "Testing E-Commerce Microservices API" -ForegroundColor Green
Write-Host "=====================================`n" -ForegroundColor Green

$baseUrls = @{
    Auth = "http://localhost:5001"
    Catalog = "http://localhost:5002"
    Cart = "http://localhost:5003"
    Order = "http://localhost:5004"
    Payment = "http://localhost:5005"
}

# Test Auth Service
Write-Host "1. Testing Auth Service..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "$($baseUrls.Auth)/swagger/index.html" -UseBasicParsing -ErrorAction Stop
    Write-Host "   ✓ Auth Service is running" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Auth Service is not accessible" -ForegroundColor Red
}

# Test Catalog Service
Write-Host "`n2. Testing Catalog Service..." -ForegroundColor Cyan
try {
    $products = Invoke-WebRequest -Uri "$($baseUrls.Catalog)/api/products" -UseBasicParsing -ErrorAction Stop
    $productsData = $products.Content | ConvertFrom-Json
    Write-Host "   ✓ Catalog Service is running" -ForegroundColor Green
    Write-Host "   ✓ Products endpoint: $($productsData.Count) products found" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Catalog Service error: $_" -ForegroundColor Red
}

try {
    $categories = Invoke-WebRequest -Uri "$($baseUrls.Catalog)/api/categories" -UseBasicParsing -ErrorAction Stop
    $categoriesData = $categories.Content | ConvertFrom-Json
    Write-Host "   ✓ Categories endpoint: $($categoriesData.Count) categories found" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Categories endpoint error: $_" -ForegroundColor Red
}

# Test Cart Service
Write-Host "`n3. Testing Cart Service..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "$($baseUrls.Cart)/swagger/index.html" -UseBasicParsing -ErrorAction Stop
    Write-Host "   ✓ Cart Service is running" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Cart Service is not accessible" -ForegroundColor Red
}

# Test Order Service
Write-Host "`n4. Testing Order Service..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "$($baseUrls.Order)/swagger/index.html" -UseBasicParsing -ErrorAction Stop
    Write-Host "   ✓ Order Service is running" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Order Service is not accessible" -ForegroundColor Red
}

# Test Payment Service
Write-Host "`n5. Testing Payment Service..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "$($baseUrls.Payment)/swagger/index.html" -UseBasicParsing -ErrorAction Stop
    Write-Host "   ✓ Payment Service is running" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Payment Service is not accessible" -ForegroundColor Red
}

# Test Frontend
Write-Host "`n6. Testing Frontend..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -ErrorAction Stop
    Write-Host "   ✓ Frontend is running" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Frontend is not accessible" -ForegroundColor Red
}

Write-Host "`n=====================================" -ForegroundColor Green
Write-Host "Testing completed!" -ForegroundColor Green
Write-Host "`nAccess points:" -ForegroundColor Yellow
Write-Host "  Frontend: http://localhost:3000" -ForegroundColor White
Write-Host "  Auth Swagger: http://localhost:5001/swagger" -ForegroundColor White
Write-Host "  Catalog Swagger: http://localhost:5002/swagger" -ForegroundColor White
Write-Host "  Cart Swagger: http://localhost:5003/swagger" -ForegroundColor White
Write-Host "  Order Swagger: http://localhost:5004/swagger" -ForegroundColor White
Write-Host "  Payment Swagger: http://localhost:5005/swagger" -ForegroundColor White

