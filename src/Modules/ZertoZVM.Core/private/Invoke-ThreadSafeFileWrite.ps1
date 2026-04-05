Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Invoke-ThreadSafeFileWrite {
    <#
    .SYNOPSIS
        Appends lines to a file using thread-safe System.IO methods with exponential backoff.
    .DESCRIPTION
        To prevent concurrent file stream locking in high-throughput runspaces, this function attempts
        to utilize native [System.IO.File]::AppendAllLines to write lines to a file. If locked, it exponentially
        backs off and retries up to MaxRetries before throwing the resulting error.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$FilePath,
        
        [Parameter(Mandatory)]
        [string[]]$Lines,
        
        [Parameter()]
        [int]$MaxRetries = 10,
        
        [Parameter()]
        [int]$DelayMilliseconds = 50
    )
    
    $retries = 0
    $success = $false
    
    while (-not $success -and $retries -lt $MaxRetries) {
        try {
            [System.IO.File]::AppendAllLines($FilePath, $Lines)
            $success = $true
        }
        catch [System.IO.IOException], [System.UnauthorizedAccessException] {
            $retries++
            if ($retries -ge $MaxRetries) {
                # Bubble the terminating constraint error up per Constitution failure boundaries
                throw
            }
            $sleepTime = $DelayMilliseconds * $retries
            Start-Sleep -Milliseconds $sleepTime
        }
    }
}
