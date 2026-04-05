function Start-ZertoVpgtaggedcheckpointinsert {
    <#
    .SYNOPSIS
        Create a tagged checkpoint for the VPG. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/vpgs/{vpgIdentifier}/checkpoints
        OperationId: startVpgTaggedCheckpointInsert
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgs/$Vpgidentifier/checkpoints" -Method 'Post'  -Body $Body
    }
}
