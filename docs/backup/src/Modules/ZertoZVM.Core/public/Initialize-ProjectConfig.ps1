<#
.SYNOPSIS
Initializes the global project configuration.

.DESCRIPTION
Loads the primary config.json file into the global $Config variable.

.PARAMETER ConfigPath
The relative or absolute path to the config.json file. Defaults to ".\config.json" on the repo root.
#>
function Initialize-ProjectConfig {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$ConfigPath = ".\config.json"
    )

    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'

    if (-not (Test-Path -Path $ConfigPath)) {
        throw "Configuration file path does not exist: $ConfigPath"
    }

    $rawContent = Get-Content -Path $ConfigPath -Raw -Encoding UTF8
    $parsedConfig = ConvertFrom-Json -InputObject $rawContent -Depth 10

    if (-not $parsedConfig) {
        throw "Failed to parse JSON configuration from: $ConfigPath"
    }

    $global:Config = $parsedConfig
    return $global:Config
}
