function Get-ZertoPointsintime {
    <#
    .SYNOPSIS
        Get all the relevant points in time for the VM. VpgId may be required if the VM is protected in more than one VPG. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/vms/{vmIdentifier}/pointsInTime
        OperationId: pointsInTime
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vmidentifier,

        [Parameter()]
        [string] $Vpgidentifier,

        [Parameter()]
        [string] $Startdate,

        [Parameter()]
        [string] $Enddate
    )

    process {
    $query = @{}
        if ($Vpgidentifier) { $query['vpgIdentifier'] = $Vpgidentifier }
        if ($Startdate) { $query['startDate'] = $Startdate }
        if ($Enddate) { $query['endDate'] = $Enddate }

        Invoke-ZertoRequest -Endpoint "vms/$Vmidentifier/pointsInTime" -Method 'Get' -QueryParameters $query 
    }
}
