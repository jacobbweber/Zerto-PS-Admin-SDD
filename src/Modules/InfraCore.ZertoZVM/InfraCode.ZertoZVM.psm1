#Requires -Version 7.0

<#
.SYNOPSIS
    InfraCode.ZertoZVM — PowerShell API Wrapper for the Zerto ZVM REST API.

.DESCRIPTION
    Provides a clean, session-based interface to the Zerto ZVM REST API (v1).
    All functions use a shared module-scoped session (populated by Connect-ZertoZVM)
    so that base URI, API version, and auth headers never need to be passed explicitly.

    Architecture:
        - $script:ZertoSession  : Module-scoped session state
        - Private/              : Internal helpers (not exported)
        - Public/               : User-facing cmdlets (exported)

.NOTES
    Module Name : InfraCode.ZertoZVM
    Author      : InfraCode
    Version     : 1.0.0
#>

# =============================================================================
# 1. Module-Scoped Session State
# =============================================================================
$script:ZertoSession = @{
    BaseUri              = $null   # e.g. "https://zvm.example.com:9669"
    ApiVersion           = 'v1'
    Headers              = @{}     # Contains x-zerto-session token after Connect-ZertoZVM
    SkipCertificateCheck = $false
    Connected            = $false
}

$script:ModuleRoot = $PSScriptRoot
$script:PrivatePath = Join-Path $PSScriptRoot 'Private'
$script:PublicPath = Join-Path $PSScriptRoot 'Public'

# =============================================================================
# 2. Dot-Source Private Helpers
# =============================================================================
if (Test-Path $script:PrivatePath) {
    foreach ($file in Get-ChildItem -Path $script:PrivatePath -Filter '*.ps1' -Recurse -ErrorAction SilentlyContinue) {
        try {
            . $file.FullName
            Write-Verbose "InfraCode.ZertoZVM: Loaded private function '$($file.BaseName)'"
        }
        catch {
            Write-Error "InfraCode.ZertoZVM: Failed to load private function '$($file.FullName)': $_"
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
            Write-Verbose "InfraCode.ZertoZVM: Loaded public function '$($file.BaseName)'"
        }
        catch {
            Write-Error "InfraCode.ZertoZVM: Failed to load public function '$($file.FullName)': $_"
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
    Write-Verbose "InfraCode.ZertoZVM: Exported $($publicFunctions.Count) public function(s)."
}
