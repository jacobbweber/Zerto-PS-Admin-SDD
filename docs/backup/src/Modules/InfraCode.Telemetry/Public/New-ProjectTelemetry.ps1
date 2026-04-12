function New-ProjectTelemetry {
    <#
    .SYNOPSIS
        Initializes a structured telemetry session object aligned with the Dynatrace Metric Ingestion Protocol.

    .DESCRIPTION
        Creates and returns a [PSCustomObject] representing the telemetry baseline for a script execution.
        The object wraps a Namespace, an ordered Dimensions hashtable for common tags, and a
        Generic.List for individual metric events. This object is passed by reference through
        controller functions; callers use .Add() on the Metrics list directly, avoiding the need
        to return and reassign the object.

    .PARAMETER Namespace
        The Dynatrace metric key prefix (e.g. "zerto.vpg"). Applied to every metric on submission.
        Must follow Dynatrace naming rules: [a-zA-Z0-9._-]+, starting with a letter or underscore.

    .PARAMETER BaseDimensions
        A hashtable of key=value pairs applied as common dimensions on every metric emitted.
        Typical keys: env, site, source, target_zvm. Keys and values must not contain spaces or quotes.

    .OUTPUTS
        [PSCustomObject] with properties: Namespace, Dimensions ([ordered]hashtable),
        Metrics ([System.Collections.Generic.List[pscustomobject]]), Created (ISO-8601 UTC string).

    .EXAMPLE
        $Telemetry = New-ProjectTelemetry -Namespace "zerto.vpg" -BaseDimensions @{
            env  = "prod"
            site = "NewYork"
        }
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory)]
        [ValidatePattern('^[a-zA-Z_][a-zA-Z0-9._-]*$')]
        [string]$Namespace,

        [Parameter(Mandatory)]
        [hashtable]$BaseDimensions
    )

    process {
        Write-Verbose "Initializing telemetry session — Namespace: '$Namespace'"

        # [ordered] cast only applies to hash literals; convert explicitly for runtime variables
        $OrderedDimensions = [System.Collections.Specialized.OrderedDictionary]::new()
        foreach ($Key in ($BaseDimensions.Keys | Sort-Object)) {
            $OrderedDimensions[$Key] = $BaseDimensions[$Key]
        }

        return [PSCustomObject]@{
            Namespace  = $Namespace
            Dimensions = $OrderedDimensions
            Metrics    = [System.Collections.Generic.List[pscustomobject]]::new()
            Created    = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
        }
    }
}
