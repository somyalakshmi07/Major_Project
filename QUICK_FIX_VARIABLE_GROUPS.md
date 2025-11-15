# Quick Fix: Variable Group Error

## 🔴 The Problem
Your pipeline failed with: **"Variable group was not found or is not authorized for use"**

## ✅ Quick Solution (Choose One)

### Option 1: Create Variable Groups (Recommended)

**Step 1: Create Variable Group**
1. Go to: **Pipelines** → **Library**
2. Click **"+ Variable group"**
3. **Name:** `devops-vars`
4. **Add Variables:**
   - `acrName` = `<YOUR_ACR_NAME>`
   - `aksName` = `<YOUR_AKS_NAME>`
   - `resourceGroup` = `<YOUR_RESOURCE_GROUP>`
5. **Click "Save"**
6. **Click "Pipeline permissions"** → **"Grant access permission to all pipelines"**
7. **Click "Save"**

**Step 2: Create Second Variable Group (Optional)**
1. Click **"+ Variable group"** again
2. **Name:** `secrets-vars`
3. **Leave empty for now**
4. **Click "Save"** and authorize it

**Step 3: Re-run Pipeline**
- Click **"Run new"** button

---

### Option 2: Use Simplified Pipeline (No Variable Groups)

**Step 1: Update Pipeline File**
1. In your repository, edit the pipeline YAML file
2. Replace it with: `azure-pipelines/auth-ci-simple.yml`
3. **Update line 18:** Change `<YOUR_ACR_NAME>` to your actual ACR name
4. Commit and push

**Step 2: Re-run Pipeline**

---

### Option 3: Remove Variable Groups from Existing Pipeline

Edit your `azure-pipelines/auth-ci.yml` and change:

**FROM:**
```yaml
variables:
  - group: devops-vars
  - group: secrets-vars
  - name: serviceName
    value: 'auth-service'
```

**TO:**
```yaml
variables:
  - name: serviceName
    value: 'auth-service'
  - name: acrName
    value: '<YOUR_ACR_NAME>'  # UPDATE THIS
  - name: aksName
    value: '<YOUR_AKS_NAME>'  # UPDATE THIS
  - name: resourceGroup
    value: '<YOUR_RESOURCE_GROUP>'  # UPDATE THIS
```

---

## 🎯 Fastest Fix Right Now

**If you want to get the pipeline working immediately:**

1. **Edit your pipeline YAML** in Azure DevOps
2. **Remove these lines:**
   ```yaml
   - group: devops-vars
   - group: secrets-vars
   ```
3. **Add hardcoded values:**
   ```yaml
   - name: acrName
     value: 'YOUR_ACTUAL_ACR_NAME'
   ```
4. **Save and run**

---

## 📝 How to Find Your ACR Name

If you deployed infrastructure, run:
```bash
az acr list --query "[].name" -o tsv
```

Or check: Azure Portal → Resource Groups → Your Resource Group → Container registries

---

## ✅ After Fixing

1. Click **"Run new"** in the pipeline
2. Pipeline should load successfully
3. Build stage should start

---

## 🔄 Later: Set Up Variable Groups Properly

Once the pipeline works, you can:
1. Create variable groups properly
2. Move hardcoded values to variable groups
3. Update pipeline to use variable groups again

This way you can test the pipeline first, then improve it.

