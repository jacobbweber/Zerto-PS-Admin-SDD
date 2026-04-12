Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Test-ProjectConfig {
    <#
    .SYNOPSIS
        Validates the properties and schema pathways of the configuration payload.
    .DESCRIPTION
        Ensure the mandatory keys required by the Zerto Automation Constitution exist and that
        any defined directory paths are accessible BEFORE execution proceeds.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [psobject]$Config
    )
    
    # Verify core property mapping structures exist
    if (-not $Config.base) { throw "Invalid Configuration Schema: Missing 'base' root." }
    if (-not $Config.base.logging) { throw "Invalid Configuration Schema: Missing 'base.logging'." }
    if (-not $Config.base.logging.paths) { throw "Invalid Configuration Schema: Missing 'base.logging.paths'." }
    if (-not $Config.base.auth) { throw "Invalid Configuration Schema: Missing 'base.auth'." }
    
    # Extract directories
    $directories = @(
        $Config.base.logging.paths.logdir,
        $Config.base.logging.paths.archive,
        $Config.base.logging.paths.state,
        $Config.base.logging.paths.telemetry
    )
    
    # Extract file paths (validate parent directory)
    $files = @(
        $Config.base.logging.paths.syslog,
        $Config.base.logging.paths.devlog,
        $Config.base.auth.vmware_user,
        $Config.base.auth.vmware_password
    )
    
    foreach ($dir in $directories) {
        if (-not [string]::IsNullOrWhiteSpace($dir) -and -not (Test-Path -Path $dir)) {
            throw "Configuration Path Validation Failed: Target directory '$dir' is missing or inaccessible."
        }
    }
    
    foreach ($file in $files) {
        if (-not [string]::IsNullOrWhiteSpace($file)) {
            $parent = Split-Path -Path $file -Parent
            # If the path points directly to root (like C:\) Parent is empty. So we just rely on parent test.
            if (-not [string]::IsNullOrWhiteSpace($parent) -and -not (Test-Path -Path $parent)) {
                throw "Configuration Path Validation Failed: Parent directory '$parent' for file '$file' is missing or inaccessible."
            }
        }
    }
    
    return $true
}
