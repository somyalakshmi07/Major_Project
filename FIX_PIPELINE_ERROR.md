# Fix Pipeline Error: Variable Group Not Found

## 🔴 Error Message
```
Variable group was not found or is not authorized for use
```

## ✅ Solution Steps

### Step 1: Create Variable Groups

1. **Go to Azure DevOps:**
   - Navigate to: **Pipelines** → **Library**
   - Click **"+ Variable group"**

2. **Create `devops-vars` Variable Group:**
   - **Name:** `devops-vars`
   - **Description:** "DevOps variables for all services"
   - **Add Variables:**
     - `acrName` = `<YOUR_ACR_NAME>` (e.g., `ecomacr12345`)
     - `aksName` = `<YOUR_AKS_NAME>` (e.g., `ecom-aks-12345`)
     - `resourceGroup` = `<YOUR_RESOURCE_GROUP>` (e.g., `ecom-rg-12345`)
     - `keyVaultName` = `<YOUR_KEY_VAULT_NAME>` (e.g., `ecom-kv-12345`)
   - **Click:** "Save"

3. **Create `secrets-vars` Variable Group (Optional for now):**
   - **Name:** `secrets-vars`
   - **Description:** "Secrets from Key Vault"
   - **Leave empty for now** (or add Key Vault task later)
   - **Click:** "Save"

### Step 2: Authorize Variable Groups for Pipelines

**IMPORTANT:** After creating variable groups, you must authorize them for use in pipelines.

1. **Go to:** Pipelines → Library
2. **Click on:** `devops-vars` variable group
3. **Click:** "Pipeline permissions" (or "Security" tab)
4. **Click:** "Grant access permission to all pipelines" 
   - OR manually add your pipeline
5. **Repeat for:** `secrets-vars` if you created it

### Step 3: Update Pipeline YAML (If Needed)

If you want to make variable groups optional initially, you can modify the pipeline:

**Option A: Comment out variable groups temporarily**
```yaml
# variables:
#   - group: devops-vars
#   - group: secrets-vars
variables:
  - name: serviceName
    value: 'auth-service'
  # Add hardcoded values for testing
  - name: acrName
    value: '<YOUR_ACR_NAME>'  # Replace with actual value
```

**Option B: Use pipeline variables instead**
```yaml
variables:
  - name: serviceName
    value: 'auth-service'
  - name: acrName
    value: '<YOUR_ACR_NAME>'  # Set in pipeline settings
  - name: dockerfilePath
    value: 'auth-service/Dockerfile'
```

### Step 4: Quick Fix - Minimal Pipeline

If you want to test the pipeline without variable groups first, use this minimal version:

```yaml
# Minimal CI Pipeline (for testing)
trigger:
  branches:
    include:
      - main

pool:
  vmImage: 'ubuntu-latest'

variables:
  - name: serviceName
    value: 'auth-service'
  - name: acrName
    value: '<YOUR_ACR_NAME>'  # UPDATE THIS
  - name: imageTag
    value: '$(Build.BuildId)'

stages:
- stage: Build
  displayName: 'Build and Test'
  jobs:
  - job: BuildJob
    displayName: 'Build .NET Application'
    steps:
    - task: UseDotNet@2
      displayName: 'Use .NET 8.0 SDK'
      inputs:
        packageType: 'sdk'
        version: '8.0.x'
    
    - task: DotNetCoreCLI@2
      displayName: 'Restore packages'
      inputs:
        command: 'restore'
        projects: '**/*.csproj'
    
    - task: DotNetCoreCLI@2
      displayName: 'Build solution'
      inputs:
        command: 'build'
        projects: '**/*.csproj'
        arguments: '--configuration Release'
```

## 🎯 Recommended Approach

### For First-Time Setup:

1. **Create variable groups** (Step 1 above)
2. **Authorize them** (Step 2 above)
3. **Re-run the pipeline**

### For Quick Testing:

1. **Temporarily remove variable group references** from YAML
2. **Add hardcoded values** for testing
3. **Once working, switch back to variable groups**

## 📝 Step-by-Step: Create Variable Group

1. In Azure DevOps, click **Pipelines** → **Library**
2. Click **"+ Variable group"**
3. **Name:** `devops-vars`
4. **Add these variables:**
   ```
   acrName = ecomacr12345
   aksName = ecom-aks-12345
   resourceGroup = ecom-rg-12345
   keyVaultName = ecom-kv-12345
   ```
   *(Replace with your actual values from infrastructure deployment)*
5. **Click "Save"**
6. **Click "Pipeline permissions"** → **"Grant access permission to all pipelines"**
7. **Click "Save"**

## 🔍 How to Find Your Resource Names

If you deployed infrastructure, get the names:

```bash
# Get ACR name
az acr list --query "[].name" -o tsv

# Get AKS name
az aks list --query "[].name" -o tsv

# Get Resource Group
az group list --query "[].name" -o tsv

# Get Key Vault name
az keyvault list --query "[].name" -o tsv
```

Or check Azure Portal → Resource Group → Your resources

## ✅ After Fixing

1. **Re-run the pipeline:**
   - Click **"Run new"** button
   - Or click **"Rerun failed jobs"**

2. **Verify:**
   - Pipeline should load without variable group error
   - Build stage should start

## 🚨 Still Having Issues?

If variable groups still don't work:

1. **Check permissions:**
   - Project Settings → Security
   - Verify your user has "Variable group administrator" role

2. **Use pipeline variables instead:**
   - Edit pipeline → Variables tab
   - Add variables there (less secure but works for testing)

3. **Check YAML syntax:**
   - Verify indentation is correct
   - Check variable group name matches exactly

