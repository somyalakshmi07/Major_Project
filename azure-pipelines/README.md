# Azure DevOps Pipelines Setup

## 🚨 Fixing "Variable Group Not Found" Error

### Quick Fix Applied

The pipeline files have been updated to **not require variable groups** initially. You can:

1. **Run the pipeline immediately** - It will work without variable groups
2. **Set pipeline variables** - In pipeline settings, add:
   - `ACR_NAME` = your ACR name
   - `RESOURCE_GROUP` = your resource group name
3. **Or use variable groups later** - Uncomment the variable group lines after creating them

---

## 📝 Setting Up Pipeline Variables

### Method 1: In Pipeline Settings (Easiest)

1. Go to your pipeline in Azure DevOps
2. Click **"Edit"** or **"..."** → **"Settings"**
3. Click **"Variables"** tab
4. Click **"+ New variable"**
5. Add:
   - **Name:** `ACR_NAME`
   - **Value:** Your ACR name (e.g., `ecomacr12345`)
   - **Keep this value secret:** Unchecked
6. Add another:
   - **Name:** `RESOURCE_GROUP`
   - **Value:** Your resource group name
7. **Save**

### Method 2: Edit YAML Directly

Edit `azure-pipelines/auth-ci.yml` and replace:
```yaml
- name: acrName
  value: '$(ACR_NAME)'  # Set in pipeline variables
```

With:
```yaml
- name: acrName
  value: 'YOUR_ACTUAL_ACR_NAME'  # e.g., 'ecomacr12345'
```

---

## 🔧 Service Connection Setup

Before Docker stage works, create service connection:

1. **Go to:** Project Settings → Service Connections
2. **Click:** "+ New service connection"
3. **Select:** "Docker Registry"
4. **Registry type:** "Azure Container Registry"
5. **Subscription:** Select your subscription
6. **Azure container registry:** Select your ACR
7. **Service connection name:** `ACR-Connection` (must match exactly)
8. **Click:** "Save"
9. **Verify and grant permissions** when prompted

---

## ✅ Testing the Pipeline

1. **Edit pipeline YAML** - Remove or comment out variable group lines
2. **Set pipeline variables** - Add ACR_NAME and RESOURCE_GROUP
3. **Create service connection** - ACR-Connection
4. **Click "Run"** - Pipeline should work now

---

## 📋 Pipeline Files

- `auth-ci.yml` - CI pipeline (updated, no variable groups required)
- `auth-ci-simple.yml` - Even simpler version
- `auth-cd.yml` - CD pipeline (still needs variable groups for AKS)

---

## 🎯 Current Status

✅ **CI Pipeline:** Fixed - works without variable groups  
⚠️ **CD Pipeline:** Still needs variable groups (create them or update similarly)

