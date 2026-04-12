function Get-ZertoVolume {
    <#
    .SYNOPSIS
        Get a list of volumes info in the current site. For ZSSP users, the information retrieved is for Protected entities only. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/volumes
        OperationId: getVolumeAll
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string] $Volumetype,

        [Parameter()]
        [string] $Vpgidentifier,

        [Parameter()]
        [string] $Datastoreidentifier,

        [Parameter()]
        [string] $Protectedvmidentifier,

        [Parameter()]
        [string] $Owningvmidentifier
    )

    process {
    $query = @{}
        if ($Volumetype) { $query['volumeType'] = $Volumetype }
        if ($Vpgidentifier) { $query['vpgIdentifier'] = $Vpgidentifier }
        if ($Datastoreidentifier) { $query['datastoreIdentifier'] = $Datastoreidentifier }
        if ($Protectedvmidentifier) { $query['protectedVmIdentifier'] = $Protectedvmidentifier }
        if ($Owningvmidentifier) { $query['owningVmIdentifier'] = $Owningvmidentifier }

        Invoke-ZertoRequest -Endpoint 'volumes' -Method 'Get' -QueryParameters $query 
    }
}
