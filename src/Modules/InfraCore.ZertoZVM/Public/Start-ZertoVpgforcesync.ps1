function Start-ZertoVpgforcesync {
    <#
    .SYNOPSIS
        Force synchronization of the VPG. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/vpgs/{vpgIdentifier}/forcesync
        OperationId: startVpgForceSync
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgs/$Vpgidentifier/forcesync" -Method 'Post'  -Body $Body
    }
}
