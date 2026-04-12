## TL;DR
The **Auth Contract** mandates a strict credential resolution hierarchy. Controllers must support optional explicit credentials via parameters, falling back to local AES-encrypted stores via `ZertoZVM.Utilities`.

---

# Auth Contract

## I. Intent
This contract ensures a uniform, secure method for handling authentication across all Controller scripts. It abstracts the complexity of credential retrieval, allowing scripts to run in both interactive (parameter-driven) and automated (AES-file-driven) environments.

## II. Implementation Requirements

### II.1 Parameter Declaration
All Controllers requiring authentication MUST include optional `PSCredential` parameters for each required integration.
```powershell
Param(
    [Parameter(Mandatory = $false)]
    [System.Management.Automation.PSCredential]$ZertoCred,

    [Parameter(Mandatory = $false)]
    [System.Management.Automation.PSCredential]$SnowCred
)
```

### II.2 Resolution Logic
Controllers MUST NOT implement manual decryption or logic for finding credential files. They MUST utilize the standard provider-based resolution via the `ZertoZVM.Utilities` module.

| Priority | Method | Source |
| :--- | :--- | :--- |
| **1. Explicit** | Passed via Parameter | User/Caller input during execution. |
| **2. Local Store** | `Resolve-ProjectCredential` | AES-Encrypted file mapped in `credentialmappaths.psd1`. |
| **3. Termination** | `Throw` | Log error and terminate if no credential is found. |

## III. Standardization & Security
- **Encryption**: Only AES-encrypted strings stored in `.aes` files are permitted for automation.
- **Provider Mapping**: The `Provider` name passed to the utility module MUST match the keys defined in the global configuration.
- **Error Handling**: Failure to resolve a credential MUST be logged as a `Critical` or `Error` level event before the script terminates.

## IV. Bootstrap Example
The following pattern is mandatory within the `Init or Bootstrap` portion of a Controller Script:
```powershell

    # Resolve Zerto Credential
    if ($null -eq $ZertoCred) {
        $ZertoCred = Resolve-ProjectCredential -Provider 'Zerto'
    }

    # Resolve ServiceNow Credential
    if ($null -eq $SnowCred) {
        $SnowCred = Resolve-ProjectCredential -Provider 'Snow'
    }

```

## V. Provider Mapping
All Controllers MUST utilize the `.\src\config\credentialmappaths.psd1` file to resolve credentials.

```powershell
@{
    # Provider: Zerto
    'Zerto' = @{
        AccountName = 'svc_zerto_automation'
        AesPath     = 'E:\script\aescreds\zerto_prod.aes'
    }

    # Provider: VMWare
    'VMWare' = @{
        AccountName = 'svc_vc_automation'
        AesPath     = 'E:\script\aescreds\vcenter_global.aes'
    }

    # Provider: Snow (ServiceNow)
    'Snow' = @{
        AccountName = 'svc_snow_api'
        AesPath     = 'E:\script\aescreds\snow_integration.aes'
    }
}
```

