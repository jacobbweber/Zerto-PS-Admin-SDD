function Start-ZertoVpgmove {
    <#
    .SYNOPSIS
        Starts a Move of a VPG using a checkpoint. Returns the TaskIdentifier of the operation, which can be used to monitor the operation. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/vpgs/{vpgIdentifier}/Move
        OperationId: startVpgMove
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgs/$Vpgidentifier/Move" -Method 'Post'  -Body $Body
    }
}
