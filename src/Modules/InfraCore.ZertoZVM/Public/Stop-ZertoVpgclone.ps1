function Stop-ZertoVpgclone {
    <#
    .SYNOPSIS
        Abort cloning of the VPG (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/vpgs/{vpgIdentifier}/CloneAbort
        OperationId: stopVpgClone
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgs/$Vpgidentifier/CloneAbort" -Method 'Post'  -Body $Body
    }
}
