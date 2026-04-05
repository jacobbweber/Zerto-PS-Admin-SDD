function Get-ZertoEvent {
    <#
    .SYNOPSIS
        Retrieves events from the Zerto ZVM event log.

    .DESCRIPTION
        Returns ZVM events (audit log entries) that record user actions and system
        events. Supports date-range and type filtering.

    .PARAMETER StartDate
        Return only events on or after this datetime (ISO 8601 / PowerShell DateTime).

    .PARAMETER EndDate
        Return only events on or before this datetime.

    .PARAMETER EventType
        Filter by event type string (e.g. 'UpdateProtection').

    .PARAMETER VpgName
        Filter events related to the specified VPG name.

    .EXAMPLE
        Get-ZertoEvent

    .EXAMPLE
        Get-ZertoEvent -StartDate (Get-Date).AddDays(-7)

    .OUTPUTS
        PSCustomObject[]
    #>
    [CmdletBinding(DefaultParameterSetName = 'All')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ById', ValueFromPipelineByPropertyName)]
        [string] $EventIdentifier,

        [Parameter(ParameterSetName = 'All')]
        [datetime] $StartDate,

        [Parameter(ParameterSetName = 'All')]
        [datetime] $EndDate,

        [Parameter(ParameterSetName = 'All')]
        [string] $EventType,

        [Parameter(ParameterSetName = 'All')]
        [string] $VpgName
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            Invoke-ZertoRequest -Endpoint "events/$EventIdentifier"
        }
        else {
            $query = @{}
            if ($StartDate) { $query.startDate = $StartDate.ToString('o') }
            if ($EndDate) { $query.endDate = $EndDate.ToString('o') }
            if ($EventType) { $query.eventType = $EventType }
            if ($VpgName) { $query.vpgName = $VpgName }
            Invoke-ZertoRequest -Endpoint 'events' -QueryParameters $query
        }
    }



}
