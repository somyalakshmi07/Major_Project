# Fix Docker I/O Error - Disk Space Issue
# Run this script as Administrator

Write-Host "=== Docker I/O Error Fix Script ===" -ForegroundColor Cyan
Write-Host ""

# Check disk space
Write-Host "Checking disk space..." -ForegroundColor Yellow
$cDrive = Get-PSDrive C
$freeSpaceGB = [math]::Round($cDrive.Free / 1GB, 2)
Write-Host "C: Drive Free Space: $freeSpaceGB GB" -ForegroundColor $(if ($freeSpaceGB -lt 5) { "Red" } else { "Green" })

if ($freeSpaceGB -lt 5) {
    Write-Host "WARNING: C: drive has less than 5GB free space!" -ForegroundColor Red
    Write-Host "This is causing the Docker I/O error." -ForegroundColor Red
    Write-Host ""
}

# Stop Docker Desktop
Write-Host "Stopping Docker Desktop..." -ForegroundColor Yellow
Stop-Process -Name "Docker Desktop" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3

# Clean Windows Temp files
Write-Host "Cleaning Windows Temp files..." -ForegroundColor Yellow
Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:LOCALAPPDATA\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

# Clean Windows Update files
Write-Host "Cleaning Windows Update files..." -ForegroundColor Yellow
Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
Start-Service -Name wuauserv -ErrorAction SilentlyContinue

# Clean Docker data (if accessible)
Write-Host "Attempting to clean Docker data..." -ForegroundColor Yellow
$dockerDataPath = "$env:LOCALAPPDATA\Docker"
if (Test-Path $dockerDataPath) {
    Write-Host "Docker data found at: $dockerDataPath" -ForegroundColor Yellow
    Write-Host "You may need to manually delete Docker data or reset Docker Desktop" -ForegroundColor Yellow
}

# Run Disk Cleanup
Write-Host ""
Write-Host "Running Windows Disk Cleanup..." -ForegroundColor Yellow
Write-Host "This will open Disk Cleanup - select all options and click OK" -ForegroundColor Cyan
Start-Process cleanmgr.exe -ArgumentList "/d C:" -Wait

Write-Host ""
Write-Host "=== Next Steps ===" -ForegroundColor Cyan
Write-Host "1. Free up at least 10GB on C: drive" -ForegroundColor Yellow
Write-Host "2. Restart Docker Desktop" -ForegroundColor Yellow
Write-Host "3. If issue persists, reset Docker Desktop:" -ForegroundColor Yellow
Write-Host "   - Open Docker Desktop" -ForegroundColor White
Write-Host "   - Settings > Troubleshoot > Reset to factory defaults" -ForegroundColor White
Write-Host ""
Write-Host "Alternative: Move Docker storage to D: drive (has $([math]::Round((Get-PSDrive D).Free / 1GB, 2)) GB free)" -ForegroundColor Cyan
Write-Host ""


