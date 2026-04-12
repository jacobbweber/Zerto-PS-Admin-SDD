function Add-TelemetryMetric {
    <#
    .SYNOPSIS
        Appends a single metric event to an existing telemetry session.

    .DESCRIPTION
        Provides a validated, verb-noun wrapper around the direct .Metrics.Add() pattern.
        Callers inside Core orchestration functions or controller scripts should use this
        function rather than calling .Add() directly, to guarantee schema consistency on
        every metric event appended to the session.

        Valid Dynatrace payload types:
          - gauge        : Point-in-time measurement (CPU, memory, duration).
          - count,delta  : Cumulative increment/decrement (errors, successes).

    .PARAMETER Session
        The [PSCustomObject] returned by New-ProjectTelemetry. Passed by reference;
        the Metrics list is mutated in place — no return value is needed.

    .PARAMETER Key
        The metric identifier appended to the session Namespace on submission.
        Example: "provisioning_time_seconds" → emitted as "zerto.vpg.provisioning_time_seconds".
        Must match: [a-zA-Z_][a-zA-Z0-9._-]*

    .PARAMETER Value
        The numeric measurement. Doubles and integers are both accepted.

    .PARAMETER Type
        Dynatrace payload type. Defaults to 'gauge'.
        Use 'count,delta' to represent a cumulative delta counter.

    .EXAMPLE
        Add-TelemetryMetric -Session $Telemetry -Key "provisioning_time_seconds" -Value 45

    .EXAMPLE
        Add-TelemetryMetric -Session $Telemetry -Key "vpg_failures" -Value 1 -Type "count,delta"
    #>
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter(Mandatory)]
        [PSCustomObject]$Session,

        [Parameter(Mandatory)]
        [ValidatePattern('^[a-zA-Z_][a-zA-Z0-9._-]*$')]
        [string]$Key,

        [Parameter(Mandatory)]
        [double]$Value,

        [Parameter()]
        [ValidateSet('gauge', 'count,delta')]
        [string]$Type = 'gauge'
    )

    process {
        if ($null -eq $Session.Metrics) {
            throw "Invalid telemetry session: Metrics list is null. Ensure the session was created with New-ProjectTelemetry."
        }

        Write-Verbose "Adding metric — Key: '$Key', Value: $Value, Type: '$Type'"

        $Session.Metrics.Add(
            [pscustomobject]@{
                Key   = $Key
                Value = $Value
                Type  = $Type
            }
        )
    }
}
