# Quickstart: ZertoZVM.APIWrapper

## Connecting
```powershell
# Authenticates and caches credentials for silent refresh
$Cred = Get-Credential
Connect-ZertoZVM -Hostname "zvm01.corp.local" -Credential $Cred -SkipCertificateCheck
```

## Reading Data
```powershell
# Fetch objects (automatically bound to active session)
$Vpgs = Get-ZertoVPG -Name "AppVPG*"
```

## Mutating State
```powershell
# Mutable actions are explicitly guarded with PowerShell's default ShouldProcess flags
Start-ZertoFailover -VpgIdentifier "abc-123" -WhatIf
```

## Disconnecting
```powershell
# Securely invalidates token with ZVM via REST and purges PowerShell Process CachedCredential
Disconnect-ZertoZVM
```
