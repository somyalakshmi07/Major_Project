# Infrastructure Deployment Script (PowerShell)
# Purpose: Deploy all Azure resources using Bicep templates

param(
    [string]$ProjectPrefix = "ecom",
    [string]$Location = "eastus",
    [string]$SubscriptionId = "",
    [int]$AksNodeCount = 2,
    [string]$AksVmSize = "Standard_B2s"
)

$ErrorActionPreference = "Stop"

Write-Host "=== Azure Infrastructure Deployment ===" -ForegroundColor Green
Write-Host ""

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Host "Azure CLI not found. Please install it." -ForegroundColor Red
    exit 1
}

# Login check
Write-Host "Checking Azure login..." -ForegroundColor Yellow
$account = az account show 2>$null | ConvertFrom-Json
if (-not $account) {
    Write-Host "Not logged in. Running az login..." -ForegroundColor Yellow
    az login
}

# Set subscription
if ($SubscriptionId) {
    Write-Host "Setting subscription..." -ForegroundColor Yellow
    az account set --subscription $SubscriptionId
}

$currentSub = (az account show --query id -o tsv)
Write-Host "Using subscription: $currentSub" -ForegroundColor Green

# Confirm deployment
Write-Host ""
Write-Host "Deployment Configuration:" -ForegroundColor Yellow
Write-Host "  Project Prefix: $ProjectPrefix"
Write-Host "  Location: $Location"
Write-Host "  AKS Node Count: $AksNodeCount"
Write-Host "  AKS VM Size: $AksVmSize"
Write-Host ""
$confirm = Read-Host "Continue with deployment? (y/n)"
if ($confirm -ne "y") {
    exit 1
}

# Create parameters file
Write-Host "Creating parameters file..." -ForegroundColor Yellow
$paramsContent = @{
    "`$schema" = "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#"
    contentVersion = "1.0.0.0"
    parameters = @{
        projectPrefix = @{ value = $ProjectPrefix }
        location = @{ value = $Location }
        aksNodeCount = @{ value = $AksNodeCount }
        aksVmSize = @{ value = $AksVmSize }
        sqlDatabaseSku = @{ value = "Basic" }
        postgresSku = @{ value = "Standard_B1ms" }
        cosmosDbThroughput = @{ value = 400 }
        enableAppService = @{ value = $true }
    }
} | ConvertTo-Json -Depth 10

$paramsContent | Out-File -FilePath "..\bicep\params.json" -Encoding utf8

# Deploy infrastructure
Write-Host "Deploying infrastructure..." -ForegroundColor Yellow
Write-Host "This may take 15-20 minutes..."
Write-Host ""

$deploymentName = "ecommerce-infra-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

az deployment sub create `
    --location $Location `
    --name $deploymentName `
    --template-file "..\bicep\main.bicep" `
    --parameters "@..\bicep\params.json"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "=== Deployment Successful ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "Getting deployment outputs..." -ForegroundColor Yellow
    
    # Get outputs
    $rg = az deployment sub show --name $deploymentName --query "properties.outputs.resourceGroupName.value" -o tsv
    $acr = az deployment sub show --name $deploymentName --query "properties.outputs.acrName.value" -o tsv
    $aks = az deployment sub show --name $deploymentName --query "properties.outputs.aksName.value" -o tsv
    $kv = az deployment sub show --name $deploymentName --query "properties.outputs.keyVaultName.value" -o tsv
    
    Write-Host ""
    Write-Host "Deployment Outputs:" -ForegroundColor Green
    Write-Host "  Resource Group: $rg"
    Write-Host "  ACR Name: $acr"
    Write-Host "  AKS Name: $aks"
    Write-Host "  Key Vault: $kv"
    Write-Host ""
    
    # Configure kubectl
    Write-Host "Configuring kubectl..." -ForegroundColor Yellow
    az aks get-credentials --resource-group $rg --name $aks --overwrite-existing
    
    Write-Host ""
    Write-Host "=== Next Steps ===" -ForegroundColor Green
    Write-Host "1. Create Azure DevOps service connections"
    Write-Host "2. Push code to Azure Repos"
    Write-Host "3. Run CI/CD pipelines"
    Write-Host "4. Verify deployment: .\verify_deploy.ps1"
    Write-Host ""
} else {
    Write-Host "Deployment failed. Check the error messages above." -ForegroundColor Red
    exit 1
}

