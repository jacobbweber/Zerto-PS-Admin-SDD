function Get-ZertoPointsintimestats {
    <#
    .SYNOPSIS
        Get the earliest and latest points in time for the VM. VpgId may be required if the VM is protected by more than one VPG. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/vms/{vmIdentifier}/pointsInTime/stats
        OperationId: pointsInTimeStats
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vmidentifier,

        [Parameter()]
        [string] $Vpgidentifier
    )

    process {
    $query = @{}
        if ($Vpgidentifier) { $query['vpgIdentifier'] = $Vpgidentifier }

        Invoke-ZertoRequest -Endpoint "vms/$Vmidentifier/pointsInTime/stats" -Method 'Get' -QueryParameters $query 
    }
}
