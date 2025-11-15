# Deployment Verification Script (PowerShell)
# Purpose: Verifies all components are deployed and functioning correctly

param(
    [string]$ResourceGroup = "",
    [string]$AksName = "",
    [string]$AcrName = "",
    [string]$FrontendUrl = ""
)

$ErrorActionPreference = "Continue"
$errors = 0

Write-Host "=== Deployment Verification ===" -ForegroundColor Green
Write-Host ""

if ([string]::IsNullOrEmpty($ResourceGroup) -or [string]::IsNullOrEmpty($AksName)) {
    Write-Host "Please provide ResourceGroup and AksName parameters" -ForegroundColor Yellow
    exit 1
}

# 1. Check AKS Cluster
Write-Host "1. Checking AKS cluster..." -ForegroundColor Yellow
try {
    $nodes = kubectl get nodes --no-headers 2>$null
    if ($LASTEXITCODE -eq 0) {
        $nodeCount = ($nodes | Measure-Object -Line).Lines
        Write-Host "   ✓ kubectl configured" -ForegroundColor Green
        Write-Host "   ✓ AKS nodes running: $nodeCount" -ForegroundColor Green
    } else {
        Write-Host "   ✗ kubectl not configured" -ForegroundColor Red
        $errors++
    }
} catch {
    Write-Host "   ✗ Error checking AKS: $_" -ForegroundColor Red
    $errors++
}

# 2. Check Pods
Write-Host "2. Checking pods..." -ForegroundColor Yellow
$namespaces = @("default", "production")
foreach ($ns in $namespaces) {
    try {
        $pods = kubectl get pods -n $ns --no-headers 2>$null
        $notRunning = $pods | Where-Object { $_ -notmatch "Running" }
        if ($notRunning.Count -eq 0) {
            Write-Host "   ✓ All pods running in namespace: $ns" -ForegroundColor Green
        } else {
            Write-Host "   ✗ Some pods not running in namespace: $ns" -ForegroundColor Red
            $notRunning | ForEach-Object { Write-Host "      $_" }
            $errors++
        }
    } catch {
        Write-Host "   ⚠ Could not check namespace: $ns" -ForegroundColor Yellow
    }
}

# 3. Check ACR
Write-Host "3. Checking ACR..." -ForegroundColor Yellow
if (-not [string]::IsNullOrEmpty($AcrName)) {
    try {
        $repos = az acr repository list --name $AcrName --output tsv 2>$null
        if ($LASTEXITCODE -eq 0) {
            $repoCount = ($repos | Measure-Object -Line).Lines
            Write-Host "   ✓ ACR accessible with $repoCount repositories" -ForegroundColor Green
        } else {
            Write-Host "   ✗ Cannot access ACR" -ForegroundColor Red
            $errors++
        }
    } catch {
        Write-Host "   ✗ Error checking ACR: $_" -ForegroundColor Red
        $errors++
    }
}

# 4. Check Application Insights
Write-Host "4. Checking Application Insights..." -ForegroundColor Yellow
try {
    $ai = az resource list --resource-group $ResourceGroup --resource-type "Microsoft.Insights/components" --query "[0].name" -o tsv 2>$null
    if ($ai) {
        Write-Host "   ✓ Application Insights found: $ai" -ForegroundColor Green
    } else {
        Write-Host "   ⚠ Application Insights not found" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ⚠ Could not check Application Insights" -ForegroundColor Yellow
}

# 5. Check Frontend
Write-Host "5. Checking frontend..." -ForegroundColor Yellow
if (-not [string]::IsNullOrEmpty($FrontendUrl)) {
    try {
        $response = Invoke-WebRequest -Uri $FrontendUrl -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            Write-Host "   ✓ Frontend accessible: $FrontendUrl" -ForegroundColor Green
        } else {
            Write-Host "   ✗ Frontend returned status: $($response.StatusCode)" -ForegroundColor Red
            $errors++
        }
    } catch {
        Write-Host "   ✗ Frontend not accessible: $_" -ForegroundColor Red
        $errors++
    }
}

# 6. Test Authentication
Write-Host "6. Testing authentication..." -ForegroundColor Yellow
if (-not [string]::IsNullOrEmpty($FrontendUrl)) {
    try {
        $authUrl = "$FrontendUrl/api/auth/login"
        $body = @{
            email = "admin@example.com"
            password = "Admin123!"
        } | ConvertTo-Json
        
        $response = Invoke-RestMethod -Uri $authUrl -Method POST -ContentType "application/json" -Body $body -ErrorAction Stop
        if ($response.token) {
            Write-Host "   ✓ Authentication working" -ForegroundColor Green
        } else {
            Write-Host "   ✗ Authentication failed - no token received" -ForegroundColor Red
            $errors++
        }
    } catch {
        Write-Host "   ✗ Authentication test failed: $_" -ForegroundColor Red
        $errors++
    }
}

# Summary
Write-Host ""
if ($errors -eq 0) {
    Write-Host "=== Verification Complete: All checks passed ===" -ForegroundColor Green
    exit 0
} else {
    Write-Host "=== Verification Complete: $errors error(s) found ===" -ForegroundColor Red
    exit 1
}

