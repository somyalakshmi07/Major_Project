# Azure DevOps Pipeline Setup Guide

## 🎯 Which Pipeline Option to Use

### ✅ **RECOMMENDED: Option 5 - "Existing Azure Pipelines YAML file"**

Since we've already created complete CI/CD pipeline YAML files, use this option.

**Steps:**
1. Click **"Existing Azure Pipelines YAML file"**
2. Select your repository (e.g., `auth-service`)
3. Select branch: `main`
4. Select path: `azure-pipelines/auth-ci.yml` (for CI) or `azure-pipelines/auth-cd.yml` (for CD)
5. Click **"Continue"**

---

## 📋 Complete Setup Process

### Step 1: Create CI Pipeline (Build & Push)

1. **Go to:** Pipelines → New Pipeline
2. **Select:** "Existing Azure Pipelines YAML file"
3. **Repository:** Select your service repository (e.g., `auth-service`)
4. **Branch:** `main`
5. **Path:** `azure-pipelines/auth-ci.yml`
6. **Click:** "Continue" → "Run"

**This pipeline will:**
- Build .NET application
- Run unit tests
- Build Docker image
- Push to Azure Container Registry

---

### Step 2: Create CD Pipeline (Deploy)

1. **Go to:** Pipelines → New Pipeline
2. **Select:** "Existing Azure Pipelines YAML file"
3. **Repository:** Select your service repository
4. **Branch:** `main`
5. **Path:** `azure-pipelines/auth-cd.yml`
6. **Click:** "Continue" → "Run"

**This pipeline will:**
- Deploy to staging namespace
- Deploy to production (after approval)
- Rollback on failure

---

## ⚙️ Before Running Pipelines

### 1. Create Variable Groups

**Go to:** Pipelines → Library → Variable groups

#### Create `devops-vars`:
```
acrName = <YOUR_ACR_NAME>
aksName = <YOUR_AKS_NAME>
resourceGroup = <YOUR_RESOURCE_GROUP>
keyVaultName = <YOUR_KEY_VAULT_NAME>
```

#### Create `secrets-vars`:
- Use Azure Key Vault task to link secrets
- Or manually add variables (not recommended for secrets)

### 2. Create Service Connections

**Go to:** Project Settings → Service Connections → New service connection

#### A. Azure Container Registry (ACR)
- **Type:** Docker Registry
- **Registry type:** Azure Container Registry
- **Subscription:** Select your subscription
- **Azure container registry:** Select your ACR
- **Service connection name:** `ACR-Connection`
- **Click:** "Save"

#### B. Azure Kubernetes Service (AKS)
- **Type:** Kubernetes
- **Authentication method:** Azure Subscription
- **Subscription:** Select your subscription
- **Resource group:** Select your resource group
- **Kubernetes cluster:** Select your AKS cluster
- **Service connection name:** `AKS-Connection`
- **Click:** "Save"
- **IMPORTANT:** Click "Verify" and grant permissions when prompted

#### C. Azure Resource Manager
- **Type:** Azure Resource Manager
- **Authentication method:** Service principal (automatic)
- **Scope level:** Subscription
- **Subscription:** Select your subscription
- **Resource group:** (optional)
- **Service connection name:** `Azure-Subscription`
- **Click:** "Save"
- **IMPORTANT:** Grant permissions when prompted

---

## 🔄 Alternative: Use Option 3 (Quick Start)

If you want Azure DevOps to generate a basic pipeline:

1. **Select:** "Deploy to Azure Kubernetes Service"
2. **Follow the wizard:**
   - Select your AKS cluster
   - Select your ACR
   - Select your repository
3. **Then replace the generated YAML** with our template from `azure-pipelines/auth-ci.yml`

**Note:** This creates a basic pipeline. Our templates are more complete with testing, staging, and rollback.

---

## 📝 Pipeline File Locations

For each service, use these paths:

| Service | CI Pipeline | CD Pipeline |
|---------|-------------|-------------|
| Auth | `azure-pipelines/auth-ci.yml` | `azure-pipelines/auth-cd.yml` |
| Catalog | `azure-pipelines/catalog-ci.yml` | `azure-pipelines/catalog-cd.yml` |
| Cart | `azure-pipelines/cart-ci.yml` | `azure-pipelines/cart-cd.yml` |
| Order | `azure-pipelines/order-ci.yml` | `azure-pipelines/order-cd.yml` |
| Payment | `azure-pipelines/payment-ci.yml` | `azure-pipelines/payment-cd.yml` |
| Frontend | `azure-pipelines/frontend-ci.yml` | `azure-pipelines/frontend-cd.yml` |

---

## ✅ Quick Checklist

- [ ] Variable groups created (`devops-vars`, `secrets-vars`)
- [ ] Service connections created (`ACR-Connection`, `AKS-Connection`)
- [ ] Code pushed to Azure Repos
- [ ] CI pipeline created and tested
- [ ] CD pipeline created (with manual approval gates)
- [ ] First deployment successful

---

## 🚨 Common Issues

### "Service connection not found"
- **Solution:** Verify service connection names match exactly in YAML files
- Check: `containerRegistry: 'ACR-Connection'` matches your connection name

### "Variable group not found"
- **Solution:** Create variable groups in Pipelines → Library
- Names must match: `devops-vars` and `secrets-vars`

### "Permission denied"
- **Solution:** Click "Verify" on service connections
- Grant permissions in Azure Portal when prompted

### "Image pull error"
- **Solution:** Verify ACR secret exists in Kubernetes:
  ```bash
  kubectl get secret acr-secret -n production
  ```

---

## 🎯 Recommended Approach

**For First-Time Setup:**
1. Use **Option 5** (Existing YAML file)
2. Start with **auth-service** CI pipeline
3. Test it works before creating CD pipeline
4. Then replicate for other services

**For Quick Testing:**
- Use **Option 3** (Deploy to AKS) to get a working pipeline quickly
- Then customize with our templates later

