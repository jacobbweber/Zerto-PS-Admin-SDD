# Contract: Credential Map — `credentialmappaths.psd1` Schema

**Version**: 1.0.0
**Authority**: ZAF Constitution §VIII
**Status**: Canonical

---

## Overview

`credentialmappaths.psd1` is a PowerShell Data File (`.psd1`) that maps logical **account names** to physical **AES-encrypted credential file paths** on disk. It is the lookup table used by `Resolve-ZertoCredential` in `ZertoZVM.Utilities` when no explicit `$Credential` parameter is provided.

**File Location**: `.\src\config\credentialmappaths.psd1`
**AES Credential Files Location**: `E:\script\aescreds\`

---

## File Schema

```powershell
# credentialmappaths.psd1
# Schema Version: 1.0.0
# Last Updated: YYYY-MM-DD
#
# Format:
#   [Logical_Account_Name] = @{
#       PasswordFile = 'E:\script\aescreds\[account]_password.txt'   # AES-encrypted password blob
#       KeyFile      = 'E:\script\aescreds\[account]_aes.key'        # 256-bit AES key
#       Username     = '[domain\user or UPN]'                         # Plaintext identity
#       Description  = 'Human-readable description'
#   }

@{
    # -------------------------------------------------------------------------
    # Zerto Service Accounts
    # -------------------------------------------------------------------------
    Zerto_Service_Account = @{
        PasswordFile = 'E:\script\aescreds\zerto_svc_password.txt'
        KeyFile      = 'E:\script\aescreds\zerto_svc_aes.key'
        Username     = 'DOMAIN\zerto_svc'
        Description  = 'Primary Zerto ZVM automation service account'
    }

    Zerto_ReadOnly = @{
        PasswordFile = 'E:\script\aescreds\zerto_ro_password.txt'
        KeyFile      = 'E:\script\aescreds\zerto_ro_aes.key'
        Username     = 'DOMAIN\zerto_ro'
        Description  = 'Read-only ZVM auditing account'
    }

    # -------------------------------------------------------------------------
    # VMware Accounts
    # -------------------------------------------------------------------------
    VMware_Service_Account = @{
        PasswordFile = 'E:\script\aescreds\vmware_svc_password.txt'
        KeyFile      = 'E:\script\aescreds\vmware_svc_aes.key'
        Username     = 'DOMAIN\vmware_svc'
        Description  = 'VMware vCenter automation service account'
    }

    # -------------------------------------------------------------------------
    # ServiceNow Accounts (Planned — ZertoZVM.Snow)
    # -------------------------------------------------------------------------
    <#
    ServiceNow_API_User = @{
        PasswordFile = 'E:\script\aescreds\snow_api_password.txt'
        KeyFile      = 'E:\script\aescreds\snow_api_aes.key'
        Username     = 'snow_api_user'
        Description  = 'ServiceNow API integration account'
    }
    #>
}
```

---

## Key Field Definitions

| Field | Type | Required | Description |
|---|---|---|---|
| `PasswordFile` | `string` (path) | ✅ Yes | Full path to the AES-encrypted password text file. Contains the Base64-encoded ciphertext. |
| `KeyFile` | `string` (path) | ✅ Yes | Full path to the 256-bit AES key file used to decrypt `PasswordFile`. |
| `Username` | `string` | ✅ Yes | The plaintext username identity. Used to construct a `[PSCredential]` object. |
| `Description` | `string` | Recommended | Human-readable description for documentation and audit purposes. |

---

## Naming Conventions for Account Keys

Account key names (e.g., `Zerto_Service_Account`) MUST:
- Use `PascalCase` with underscores as separators
- Match the account name used in the intake form's **Credentials** integration checkbox exactly
- Be unique within the file

AES file names MUST follow the pattern: `[logical_account_name_lowercase]_password.txt` and `[logical_account_name_lowercase]_aes.key`.

---

## `Resolve-ZertoCredential` Function Contract

The function in `ZertoZVM.Utilities` that consumes this file:

```powershell
function Resolve-ZertoCredential {
    [CmdletBinding()]
    [OutputType([PSCredential])]
    param(
        # Explicit credential (Priority 1). If provided, AES lookup is skipped.
        [Parameter(Mandatory = $false)]
        [PSCredential]$Credential,

        # Logical account name from credentialmappaths.psd1 (Priority 2)
        [Parameter(Mandatory = $true)]
        [string]$AccountName,

        # Path to credentialmappaths.psd1
        [Parameter(Mandatory = $false)]
        [string]$CredMapPath = '.\src\config\credentialmappaths.psd1'
    )
    ...
}
```

### Resolution Logic

```powershell
# Resolution order (from ZertoZVM.Utilities\Resolve-ZertoCredential.ps1)

# Priority 1: Explicit $Credential passed by caller
if ($null -ne $Credential) {
    return $Credential  # CredSource = "Explicit"
}

# Priority 2: AES lookup from credentialmappaths.psd1
[hashtable]$CredMap = Import-PowerShellDataFile -Path $CredMapPath
if (-not $CredMap.ContainsKey($AccountName)) {
    throw "Account '$AccountName' not found in credential map at '$CredMapPath'."
}

[hashtable]$Entry   = $CredMap[$AccountName]
[byte[]]$AesKey     = Get-Content -Path $Entry.KeyFile -Encoding Byte
[string]$CipherText = Get-Content -Path $Entry.PasswordFile
[securestring]$SecurePass = $CipherText | ConvertTo-SecureString -Key $AesKey

return [PSCredential]::new($Entry.Username, $SecurePass)  # CredSource = "AES"
```

---

## AES Key Generation (One-Time Setup)

To generate a new AES key/credential pair for a new account:

```powershell
# 1. Generate AES key
[byte[]]$AesKey = New-Object byte[] 32
[System.Security.Cryptography.RNGCryptoServiceProvider]::new().GetBytes($AesKey)
$AesKey | Set-Content -Path 'E:\script\aescreds\new_account_aes.key' -Encoding Byte

# 2. Encrypt password
[string]$PlaintextPassword = 'supersecretpassword'  # Replace with actual; NEVER commit
[securestring]$SecurePass  = ConvertTo-SecureString $PlaintextPassword -AsPlainText -Force
ConvertFrom-SecureString -SecureString $SecurePass -Key $AesKey |
    Set-Content -Path 'E:\script\aescreds\new_account_password.txt'

# 3. Add entry to credentialmappaths.psd1
# 4. Destroy plaintext variable
Remove-Variable PlaintextPassword, SecurePass
```

> **Security Rule**: The `E:\script\aescreds\` directory MUST be ACL-restricted to the automation service account only. AES key files MUST never be committed to source control.

---

## Intake Form Integration

In an intake form, credential requirements appear as:

```markdown
## Integrations
- [X] Credentials: Zerto_Service_Account
```

The string `Zerto_Service_Account` MUST match a key in `credentialmappaths.psd1` exactly. The generated controller MUST pass this name to `Resolve-ZertoCredential`:

```powershell
[PSCredential]$ZertoContext.State.Credential = Resolve-ZertoCredential @{
    Credential   = $Credential    # From controller's $Credential parameter
    AccountName  = 'Zerto_Service_Account'
    CredMapPath  = Join-Path -Path $PSScriptRoot -ChildPath '..\..\src\config\credentialmappaths.psd1'
}
```

---

*Contract: credential-map.md — ZAF Constitution §VIII*
