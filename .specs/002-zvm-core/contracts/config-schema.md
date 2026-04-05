# Feature Contract: ZertoZVM.Core

## Interface: `Write-Log`
Provides dual stream writing to disk without breaking application pathways.

**Signature:**
```powershell
function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('Info', 'Warn', 'Error', 'Debug')]
        [string]$Level,
        
        [Parameter(Mandatory)]
        [string]$Message,
        
        [Parameter(Mandatory)]
        [string]$LogPath,
        
        [Parameter(Mandatory)]
        [string]$SyslogFileName,
        
        [Parameter(Mandatory)]
        [string]$DevLogFileName
    )
}
```

## Interface: `Initialize-ProjectConfig` & `Test-ProjectConfig`

**Signatures:**
```powershell
function Initialize-ProjectConfig {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Path = '.\config.json'
    )
    # Output: Populates $Global:Config
}

function Test-ProjectConfig {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [psobject]$Config
    )
    # Output: [bool] $true or throws a terminating action if missing critical paths.
}
```
