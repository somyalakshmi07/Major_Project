# IMMEDIATE FIX - Docker I/O Error

## ⚠️ CRITICAL: C: Drive is Full

Your C: drive has **0 bytes free**, causing all Docker I/O errors.

## 🚀 FASTEST SOLUTION (Choose One)

### Option A: Configure Docker Desktop to Use D: Drive (5 minutes)

1. **Open Docker Desktop**
2. **Click Settings (gear icon)**
3. **Go to Resources > Advanced**
4. **Click "Change" next to "Disk image location"**
5. **Select:** `D:\DockerData` (create folder if needed)
6. **Click "Apply & Restart"**
7. **Wait for Docker to move files** (5-10 minutes)

This will move Docker's storage from C: to D: drive automatically.

### Option B: Free Up C: Drive Space (10-15 minutes)

1. **Run Disk Cleanup:**
   - Press `Win + R`
   - Type: `cleanmgr.exe /d C:`
   - Select ALL options
   - Click OK

2. **Delete Temp Files:**
   - Press `Win + R`
   - Type: `%TEMP%`
   - Select all (Ctrl+A) and Delete (Skip locked files)

3. **Empty Recycle Bin**

4. **Uninstall Unused Programs:**
   - Settings > Apps
   - Sort by Size
   - Uninstall large unused apps

5. **Move Files to D: Drive:**
   - Move Downloads folder to D:
   - Move Videos to D:
   - Move Documents to D:

## ✅ After Fix

1. **Restart Docker Desktop**
2. **Test:**
   ```powershell
   docker ps
   ```
3. **Run docker-compose:**
   ```powershell
   docker-compose up -d
   ```

## 📋 Quick Check

Run this to see current space:
```powershell
Get-PSDrive C | Select-Object Free, @{Name="FreeGB";Expression={[math]::Round($_.Free/1GB,2)}}
```

**You need at least 10GB free on C: for Docker to work properly.**


