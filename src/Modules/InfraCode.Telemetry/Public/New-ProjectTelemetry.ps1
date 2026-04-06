function New-ProjectTelemetry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Hostname,
        [Parameter(Mandatory = $true)]
        [string]$Username,
        [Parameter(Mandatory = $true)]
        [string]$BusinessUnit
    )
    process {
        Write-Verbose "Initializing telemetry for $Hostname ($Username) under $BusinessUnit"
        $global:TelemetrySession = [ordered]@{
            SessionId = [Guid]::NewGuid().ToString()
            StartTime = [DateTime]::UtcNow
            Hostname  = $Hostname
            Username  = $Username
            BU        = $BusinessUnit
            KPIs      = @{}
        }
    }
}
