function Start-ZertoVpgmovecommit {
    <#
    .SYNOPSIS
        Commits the VPG. Returns the TaskIdentifier of the operation, which can be used to monitor the operation. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/vpgs/{vpgIdentifier}/MoveCommit
        OperationId: startVpgMoveCommit
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgs/$Vpgidentifier/MoveCommit" -Method 'Post'  -Body $Body
    }
}
