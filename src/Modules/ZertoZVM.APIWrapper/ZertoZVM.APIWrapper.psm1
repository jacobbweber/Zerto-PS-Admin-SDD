#Requires -Version 7.0

<#
.SYNOPSIS
    ZertoZVM.APIWrapper — PowerShell API Wrapper for the Zerto ZVM REST API.

.DESCRIPTION
    Provides a clean, session-based interface to the Zerto ZVM REST API (v1).
    All functions use a shared module-scoped session (populated by Connect-ZertoZVM)
    so that base URI, API version, and auth headers never need to be passed explicitly.

    Architecture:
        - $script:ZertoSession  : Module-scoped session state
        - Private/              : Internal helpers (not exported)
        - Public/               : User-facing cmdlets (exported)

.NOTES
    Module Name : ZertoZVM.APIWrapper
    Author      : InfraCode
    Version     : 1.0.0
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# =============================================================================
# 1. Module-Scoped Session State
# =============================================================================
$script:ZertoSession = @{
    BaseUri              = [string]::Empty
    ApiVersion           = 'v1'
    Headers              = @{}
    SkipCertificateCheck = $false
    Connected            = $false
    TokenTimestamp       = [DateTime]::MinValue
    CachedCredential     = $null
}

$script:ModuleRoot = $PSScriptRoot
if (-not (Test-Path "$script:ModuleRoot\Private" -ErrorAction SilentlyContinue)) {
    if ($PSCommandPath) {
        $script:ModuleRoot = Split-Path -Parent $PSCommandPath
    } elseif ($MyInvocation.MyCommand.Path) {
        $script:ModuleRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
    } else {
        $script:ModuleRoot = "$pwd\src\Modules\ZertoZVM.APIWrapper"
    }
}
$script:PrivatePath = Join-Path $script:ModuleRoot 'Private'
$script:PublicPath = Join-Path $script:ModuleRoot 'Public'

# =============================================================================
# 2. Dot-Source Private Helpers
# =============================================================================
if (Test-Path $script:PrivatePath) {
    foreach ($file in Get-ChildItem -Path $script:PrivatePath -Filter '*.ps1' -Recurse -ErrorAction SilentlyContinue) {
        try {
            . $file.FullName
            Write-Verbose "ZertoZVM.APIWrapper: Loaded private function '$($file.BaseName)'"
        }
        catch {
            Write-Error "ZertoZVM.APIWrapper: Failed to load private function '$($file.FullName)': $_"
        }
    }
}

# =============================================================================
# 3. Dot-Source Public Cmdlets
# =============================================================================
if (Test-Path $script:PublicPath) {
    foreach ($file in Get-ChildItem -Path $script:PublicPath -Filter '*.ps1' -Recurse -ErrorAction SilentlyContinue) {
        try {
            . $file.FullName
            Write-Verbose "ZertoZVM.APIWrapper: Loaded public function '$($file.BaseName)'"
        }
        catch {
            Write-Error "ZertoZVM.APIWrapper: Failed to load public function '$($file.FullName)': $_"
        }
    }
}

# =============================================================================
# 4. Export Public Functions
# =============================================================================
$publicFunctions = if (Test-Path $script:PublicPath) {
    (Get-ChildItem -Path $script:PublicPath -Filter '*.ps1' -Recurse -ErrorAction SilentlyContinue).BaseName
}
else { @() }

if ($publicFunctions.Count -gt 0) {
    Export-ModuleMember -Function $publicFunctions
    Write-Verbose "ZertoZVM.APIWrapper: Exported $($publicFunctions.Count) public function(s)."
}
