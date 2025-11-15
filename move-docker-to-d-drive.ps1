# Move Docker Storage to D: Drive
# Run this script as Administrator

Write-Host "=== Move Docker Storage to D: Drive ===" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

# Stop Docker Desktop
Write-Host "Stopping Docker Desktop..." -ForegroundColor Yellow
Stop-Process -Name "Docker Desktop" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "com.docker.backend" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 5

# Docker data paths
$dockerLocalPath = "$env:LOCALAPPDATA\Docker"
$dockerAppDataPath = "$env:APPDATA\Docker"
$newDockerPath = "D:\DockerData"

# Check D: drive space
$dDrive = Get-PSDrive D -ErrorAction SilentlyContinue
if (-not $dDrive) {
    Write-Host "ERROR: D: drive not found!" -ForegroundColor Red
    exit 1
}

$freeSpaceGB = [math]::Round($dDrive.Free / 1GB, 2)
Write-Host "D: Drive Free Space: $freeSpaceGB GB" -ForegroundColor Green
Write-Host ""

# Create new Docker data directory
Write-Host "Creating Docker data directory on D: drive..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path $newDockerPath -Force | Out-Null

# Move Docker data if it exists
if (Test-Path $dockerLocalPath) {
    Write-Host "Moving Docker data from $dockerLocalPath to $newDockerPath..." -ForegroundColor Yellow
    Write-Host "This may take several minutes..." -ForegroundColor Yellow
    
    # Use robocopy for better reliability
    $result = Start-Process -FilePath "robocopy" -ArgumentList "`"$dockerLocalPath`" `"$newDockerPath`" /E /MOVE /R:3 /W:5" -Wait -PassThru -NoNewWindow
    
    if ($result.ExitCode -le 7) {
        Write-Host "Docker data moved successfully!" -ForegroundColor Green
    } else {
        Write-Host "Warning: robocopy exit code: $($result.ExitCode)" -ForegroundColor Yellow
        Write-Host "Some files may not have been moved. Continuing..." -ForegroundColor Yellow
    }
}

# Create symbolic link
Write-Host "Creating symbolic link..." -ForegroundColor Yellow
if (Test-Path $dockerLocalPath) {
    Remove-Item -Path $dockerLocalPath -Force -Recurse -ErrorAction SilentlyContinue
}

try {
    New-Item -ItemType SymbolicLink -Path $dockerLocalPath -Target $newDockerPath -Force | Out-Null
    Write-Host "Symbolic link created successfully!" -ForegroundColor Green
} catch {
    Write-Host "Warning: Could not create symbolic link. You may need to configure Docker Desktop manually." -ForegroundColor Yellow
    Write-Host "Error: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Next Steps ===" -ForegroundColor Cyan
Write-Host "1. Open Docker Desktop" -ForegroundColor Yellow
Write-Host "2. Go to Settings (gear icon)" -ForegroundColor Yellow
Write-Host "3. Go to Resources > Advanced" -ForegroundColor Yellow
Write-Host "4. Change 'Disk image location' to: D:\DockerData" -ForegroundColor Yellow
Write-Host "5. Click 'Apply & Restart'" -ForegroundColor Yellow
Write-Host ""
Write-Host "Alternative: If symbolic link worked, just restart Docker Desktop" -ForegroundColor Cyan
Write-Host ""


