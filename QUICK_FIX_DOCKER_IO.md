# Quick Fix for Docker I/O Error - Move to D: Drive

## Problem
Your C: drive is **completely full (0 bytes)**, causing Docker I/O errors when extracting image layers.

## Solution: Move Docker to D: Drive

Since D: drive has **220GB free space**, we'll move Docker's storage there.

### Method 1: Using Script (Recommended)

1. **Run PowerShell as Administrator:**
   - Right-click PowerShell
   - Select "Run as Administrator"

2. **Run the script:**
   ```powershell
   cd "C:\Users\Dell\Desktop\All_proj\clz\Myweb"
   .\move-docker-to-d-drive.ps1
   ```

3. **Configure Docker Desktop:**
   - Open Docker Desktop
   - Settings (gear icon) > Resources > Advanced
   - Change "Disk image location" to: `D:\DockerData`
   - Click "Apply & Restart"

### Method 2: Manual Configuration

1. **Stop Docker Desktop:**
   - Close Docker Desktop completely
   - Check Task Manager to ensure all Docker processes are stopped

2. **Open Docker Desktop Settings:**
   - Open Docker Desktop
   - Click Settings (gear icon)
   - Go to Resources > Advanced

3. **Change Disk Image Location:**
   - Find "Disk image location"
   - Click "Change"
   - Select or create folder: `D:\DockerData`
   - Click "Apply & Restart"

4. **Wait for Docker to move files:**
   - Docker will move all data to D: drive
   - This may take several minutes
   - Wait until Docker Desktop shows "Docker Desktop is running"

### Method 3: Complete Docker Reset (If Above Doesn't Work)

1. **Uninstall Docker Desktop:**
   - Settings > Apps > Docker Desktop > Uninstall

2. **Delete Docker Data:**
   - Delete: `C:\Users\YourUsername\AppData\Local\Docker`
   - Delete: `C:\Users\YourUsername\AppData\Roaming\Docker`

3. **Install Docker Desktop to D: Drive:**
   - Download Docker Desktop installer
   - Install to: `D:\Program Files\Docker\`

4. **Configure Storage:**
   - Settings > Resources > Advanced
   - Set "Disk image location" to: `D:\DockerData`

## After Moving Docker to D: Drive

1. **Verify Docker is working:**
   ```powershell
   docker ps
   ```

2. **Clean up any corrupted images:**
   ```powershell
   docker system prune -a -f
   ```

3. **Try docker-compose again:**
   ```powershell
   docker-compose up -d
   ```

## Still Having Issues?

### Free Up C: Drive Space First

1. **Run Disk Cleanup:**
   ```powershell
   cleanmgr.exe /d C:
   ```

2. **Delete Temporary Files:**
   - Delete: `C:\Users\YourUsername\AppData\Local\Temp\*`
   - Delete: `C:\Windows\Temp\*`

3. **Uninstall Unused Programs:**
   - Settings > Apps > Uninstall large unused applications

4. **Move Large Files:**
   - Move Downloads, Videos, Documents to D: drive

## Prevention

- **Keep at least 20GB free on C: drive**
- **Store Docker data on D: drive**
- **Regularly clean temporary files**
- **Monitor disk space regularly**

## Verify Disk Space

```powershell
Get-PSDrive C, D | Select-Object Name, Used, Free, @{Name="FreeGB";Expression={[math]::Round($_.Free/1GB,2)}}
```


