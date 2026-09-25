# ============================================
# AdGuard Home Auto Installer (Windows)
# ============================================

Write-Host "Starting AdGuard Home installation..."

# --------------------------------------------
# 1. Define paths
# --------------------------------------------
$downloadUrl = "https://static.adguard.com/adguardhome/release/AdGuardHome_windows_amd64.zip"
$tempZip = "$env:TEMP\AdGuardHome.zip"
$installDir = "C:\AdGuardHome"
$adguardExe = "$installDir\AdGuardHome\AdGuardHome.exe"

# --------------------------------------------
# 2. Download AdGuard Home
# --------------------------------------------
Write-Host "Downloading AdGuard Home..."
try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $tempZip -UseBasicParsing
} catch {
    Write-Host "ERROR: Failed to download AdGuard Home."
    Write-Host $_
    return
}

# --------------------------------------------
# 3. Extract ZIP
# --------------------------------------------
Write-Host "Extracting AdGuard Home..."

if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir | Out-Null
}

try {
    Expand-Archive -Path $tempZip -DestinationPath $installDir -Force
} catch {
    Write-Host "ERROR: Failed to extract AdGuard Home ZIP."
    Write-Host $_
    return
}

# --------------------------------------------
# 4. Install AdGuard Home as a service
# --------------------------------------------
if (-not (Test-Path $adguardExe)) {
    Write-Host "ERROR: AdGuardHome.exe not found after extraction."
    return
}

Write-Host "Installing AdGuard Home service..."
Set-Location "$installDir\AdGuardHome"

try {
    .\AdGuardHome.exe -s install
} catch {
    Write-Host "ERROR: Failed to install AdGuard Home service."
    Write-Host $_
    return
}

# --------------------------------------------
# 5. Start the service
# --------------------------------------------
Write-Host "Starting AdGuard Home service..."

try {
    Start-Service AdGuardHome
} catch {
    Write-Host "ERROR: Could not start AdGuard Home service."
    Write-Host $_
    return
}

Start-Sleep -Seconds 2

# --------------------------------------------
# 6. Verify service status
# --------------------------------------------
$svc = Get-Service AdGuardHome -ErrorAction SilentlyContinue

if ($svc -and $svc.Status -eq "Running") {
    Write-Host "`n🟢 AdGuard Home is installed and running."
    Write-Host "Open the setup wizard at: http://localhost:3000"
} else {
    Write-Host "`n🔴 AdGuard Home service is NOT running."
    Write-Host "Try: Start-Service AdGuardHome"
}

Write-Host "`nInstallation complete."
