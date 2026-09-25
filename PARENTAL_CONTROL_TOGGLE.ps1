# ============================================
# Load CredentialManager Module
# ============================================

if (-not (Get-Module -ListAvailable -Name CredentialManager)) {
    try {
        Install-Module -Name CredentialManager -Force -ErrorAction Stop
    } catch {
        Write-Host "ERROR: CredentialManager module missing and cannot be installed."
        Read-Host "Press Enter to exit..."
        exit
    }
}

Import-Module CredentialManager

# ============================================
# Password Protection (Credential Manager)
# ============================================

$target = "PARENTAL_CONTROL_TOGGLE"

try {
    $cred = Get-StoredCredential -Target $target
} catch {
    Write-Host "Credential '$target' not found. Exiting..."
    Read-Host "Press Enter to exit..."
    exit
}

if (-not $cred) {
    Write-Host "Credential '$target' not found. Exiting..."
    Read-Host "Press Enter to exit..."
    exit
}

# Convert stored secure password to plain text
$storedPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
                   [Runtime.InteropServices.Marshal]::SecureStringToBSTR($cred.Password)
               )

# Ask user for password
$input = Read-Host "Enter parental control password" -AsSecureString
$plainInput = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
                [Runtime.InteropServices.Marshal]::SecureStringToBSTR($input)
              )

# Compare correctly
if ($plainInput -ne $storedPlain) {
    Write-Host "Incorrect password. Exiting..."
    Read-Host "Press Enter to exit..."
    exit
}

# ============================================
# CONFIGURATION
# ============================================

$yamlPath = "C:\AdGuardHome\AdGuardHome\AdGuardHome.yaml"
$ruleName = "Block QUIC UDP 443"

# ============================================
# YAML REWRITE FUNCTION (WORKING)
# ============================================

function Set-UserRules {
    param([string[]]$rules)

    $yaml = Get-Content $yamlPath -Raw

    # Build new user_rules block
    $newBlock = "user_rules:`r`n"
    foreach ($r in $rules) {
        $newBlock += "  - '$r'`r`n"
    }

    # Replace entire user_rules section
    $yaml = $yaml -replace "(?s)user_rules:.*?(?=\r?\n\S)", $newBlock

    Set-Content $yamlPath $yaml
}

# ============================================
# BLOCK / ALLOW FUNCTIONS
# ============================================

function Add-YouTubeRules {
    Stop-Service AdGuardHome

    $rules = @(
        "||youtube.com^",
        "||youtubei.googleapis.com^",
        "||googlevideo.com^",
        "||ytimg.com^"
    )

    Set-UserRules -rules $rules

    Start-Service AdGuardHome
    Write-Host "🔴 YouTube blocking enabled."
}

function Remove-YouTubeRules {
    Stop-Service AdGuardHome

    Set-UserRules -rules @()

    Start-Service AdGuardHome
    Write-Host "🟢 YouTube blocking disabled."
}

# ============================================
# QUIC TOGGLE
# ============================================

function Toggle-QUIC {
    param([string]$mode)

    if ($mode -eq "Block") {
        if (-not (Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue)) {
            New-NetFirewallRule -DisplayName $ruleName -Direction Outbound -Action Block -Protocol UDP -RemotePort 443 -Profile Any -Enabled True
        } else {
            Set-NetFirewallRule -DisplayName $ruleName -Enabled True
        }
    } else {
        if (Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue) {
            Set-NetFirewallRule -DisplayName $ruleName -Enabled False
        }
    }
}

# ============================================
# MAIN LOGIC
# ============================================

Write-Host "`nParental Control Toggle:"
Write-Host "1 = Block YouTube"
Write-Host "2 = Allow YouTube"
$choice = Read-Host "Enter 1 or 2"

switch ($choice) {
    "1" {
        Add-YouTubeRules
        Toggle-QUIC "Block"
        Write-Host "`n🔴 Parental Controls ENABLED — YouTube is BLOCKED.`n"
    }
    "2" {
        Remove-YouTubeRules
        Toggle-QUIC "Allow"
        Write-Host "`n🟢 Parental Controls DISABLED — YouTube is ALLOWED.`n"
    }
    default {
        Write-Host "Invalid choice. No changes made."
    }
}

Read-Host "Press Enter to exit..."
