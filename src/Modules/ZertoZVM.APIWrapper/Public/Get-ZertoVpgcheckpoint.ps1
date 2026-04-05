function Get-ZertoVpgcheckpoint {
    <#
    .SYNOPSIS
        Get a list of checkpoints for the VPG. You can filter the results with additional parameters. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/vpgs/{vpgIdentifier}/checkpoints
        OperationId: getVpgCheckpointAll
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgidentifier,

        [Parameter()]
        [string] $Startdate,

        [Parameter()]
        [string] $Enddate
    )

    process {
    $query = @{}
        if ($Startdate) { $query['startDate'] = $Startdate }
        if ($Enddate) { $query['endDate'] = $Enddate }

        Invoke-ZertoRequest -Endpoint "vpgs/$Vpgidentifier/checkpoints" -Method 'Get' -QueryParameters $query 
    }
}
