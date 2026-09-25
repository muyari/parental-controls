# ============================================
# Create Credential for Parental Control Toggle
# ============================================

$target = "PARENTAL_CONTROL_TOGGLE"

Write-Host "Checking for CredentialManager module..."

# Check if module is installed
if (-not (Get-Module -ListAvailable -Name CredentialManager)) {
    Write-Host "CredentialManager module not found. Installing..."
    try {
        Install-Module -Name CredentialManager -Force -Scope CurrentUser
    } catch {
        Write-Host "Failed to install CredentialManager module. Run PowerShell as Administrator and try again."
        exit
    }
} else {
    Write-Host "CredentialManager module already installed."
}

# Import the module
Import-Module CredentialManager -ErrorAction Stop
Write-Host "CredentialManager module loaded."

# Prompt for password
$password = Read-Host "Enter parental control password" -AsSecureString

# Convert secure password to plain text for storage
$plain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
         )

# Create credential
try {
    New-StoredCredential -Target $target -UserName "admin" -Password $plain -Persist LocalMachine
    Write-Host "Parental control password stored securely."
} catch {
    Write-Host "Failed to create credential. Error:"
    Write-Host $_
}
