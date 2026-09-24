# INSTALL.md — Parental Control Toggle Setup Guide

This guide explains how to install and configure the Parental Control Toggle system using AdGuard Home, Windows Firewall QUIC blocking, and a secure password stored in Windows Credential Manager.

The ZIP archive:

PARENTAL_CONTROL_TOGGLE.zip

contains all required scripts.

---

## Files Included

| File | Purpose |
|------|----------|
| INSTALL_ADGUARD.ps1 | Downloads and installs AdGuard Home as a Windows service |
| PARENTAL_CONTROL_TOGGLE_PASSWORD.ps1 | Creates the secure password in Windows Credential Manager |
| PARENTAL_CONTROL_TOGGLE.ps1 | Main parental control toggle (Block/Allow YouTube) |

---

## Prerequisites

- Windows 10 or Windows 11  
- PowerShell 5+  
- Administrator privileges  
- Internet access (for AdGuard Home download)

---

## Step‑by‑Step Setup

1. **Download the ZIP from GitHub**
   - Open your GitHub repository.
   - Click *Download ZIP*.
   - Save the file `PARENTAL_CONTROL_TOGGLE.zip`.

2. **Extract the ZIP to `C:\Scripts`**
   - Create the folder if it does not exist.
   - Extract all contents into `C:\Scripts`.

   After extraction, you should have:

   - C:\Scripts\INSTALL_ADGUARD.ps1
   - C:\Scripts\PARENTAL_CONTROL_TOGGLE_PASSWORD.ps1
   - C:\Scripts\PARENTAL_CONTROL_TOGGLE.ps1

3. **Install AdGuard Home**
- Open PowerShell **as Administrator**.
- Run:
  ```powershell
  C:\Scripts\INSTALL_ADGUARD.ps1
  ```
- The script will download AdGuard Home, install it as a service, and start it.
- When complete, open the setup wizard at:
  ```
  http://localhost:3000
  ```

4. **Create the Parental Control Password**
- Run:
  ```powershell
  C:\Scripts\PARENTAL_CONTROL_TOGGLE_PASSWORD.ps1
  ```
- Enter your desired password when prompted.
- The password is stored securely in Windows Credential Manager under:
  ```
  PARENTAL_CONTROL_TOGGLE
  ```

5. **Use the Parental Control Toggle**
- Run:
  ```powershell
  C:\Scripts\PARENTAL_CONTROL_TOGGLE.ps1
  ```
- Enter your password.
- Choose:
  - `1` — Enable parental controls (block YouTube)
  - `2` — Disable parental controls (allow YouTube)

The script will:
- Add or remove AdGuard Home rules
- Toggle QUIC firewall blocking
- Restart AdGuard Home
- Flush DNS
- Close browsers to enforce the change

---

## Optional: Create a Desktop Shortcut

1. Right‑click the desktop → **New → Shortcut**
2. Enter: powershell.exe -ExecutionPolicy Bypass -File "C:\Scripts\PARENTAL_CONTROL_TOGGLE.ps1"

Double‑clicking the shortcut will launch the toggle script.

Done.
