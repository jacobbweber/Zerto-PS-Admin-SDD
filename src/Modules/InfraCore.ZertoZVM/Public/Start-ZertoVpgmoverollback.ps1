function Start-ZertoVpgmoverollback {
    <#
    .SYNOPSIS
        Rolls back the VPG after Move. Returns the TaskIdentifier of the operation, which can be used to monitor the operation. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/vpgs/{vpgIdentifier}/moveRollback
        OperationId: startVpgMoveRollback
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgs/$Vpgidentifier/moveRollback" -Method 'Post'  -Body $Body
    }
}
