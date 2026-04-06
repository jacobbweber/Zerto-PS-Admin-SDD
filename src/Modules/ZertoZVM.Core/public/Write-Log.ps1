Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Log {
    <#
    .SYNOPSIS
        Outputs a standardized log string gracefully branching to Syslog and Developer logs simultaneously.
    .DESCRIPTION
        Thread-safe logger enforcing Constitution IV guidelines.
        Developer Stream gets everything.
        Audit/Syslog stream excludes Debug.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('Information', 'Warning', 'Error', 'Debug')]
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
    
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logLine = "[$timestamp] [$($Level.ToUpper())] $Message"
    
    $devPath = Join-Path -Path $LogPath -ChildPath $DevLogFileName
    $sysPath = Join-Path -Path $LogPath -ChildPath $SyslogFileName
    
    # Always append to Developer Log
    Invoke-ThreadSafeFileWrite -FilePath $devPath -Lines @($logLine)
    
    # Conditionally append to Syslog
    if ($Level -ne 'Debug') {
        Invoke-ThreadSafeFileWrite -FilePath $sysPath -Lines @($logLine)
    }
}
