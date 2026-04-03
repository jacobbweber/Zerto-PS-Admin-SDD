function Get-ZertoRecoveryReport {
    <#
    .SYNOPSIS
        Retrieves recovery (journal) reports from the Zerto ZVM.

    .DESCRIPTION
        Returns a list of recovery operation reports. Useful for auditing
        failover tests, live failovers, and moves. Supports date and VPG filtering.

    .PARAMETER StartDate
        Return only reports from on or after this datetime.

    .PARAMETER EndDate
        Return only reports up to and including this datetime.

    .PARAMETER VpgName
        Filter reports for the specified VPG name.

    .EXAMPLE
        Get-ZertoRecoveryReport

    .EXAMPLE
        Get-ZertoRecoveryReport -VpgName 'ProdVPG' -StartDate (Get-Date).AddDays(-30)

    .OUTPUTS
        PSCustomObject[]
    #>
    [CmdletBinding(DefaultParameterSetName = 'All')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ById', ValueFromPipelineByPropertyName)]
        [string] $RecoveryOperationIdentifier,

        [Parameter(ParameterSetName = 'All')]
        [datetime] $StartDate,

        [Parameter(ParameterSetName = 'All')]
        [datetime] $EndDate,

        [Parameter(ParameterSetName = 'All')]
        [string] $VpgName
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            Invoke-ZertoRequest -Endpoint "reports/recovery/$RecoveryOperationIdentifier"
        }
        else {
            $query = @{}
            if ($StartDate) { $query.startDate = $StartDate.ToString('o') }
            if ($EndDate) { $query.endDate = $EndDate.ToString('o') }
            if ($VpgName) { $query.vpgName = $VpgName }
            Invoke-ZertoRequest -Endpoint 'reports/recovery' -QueryParameters $query
        }
    }



}
