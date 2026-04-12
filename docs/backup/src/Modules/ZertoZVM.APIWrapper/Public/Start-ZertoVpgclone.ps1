function Start-ZertoVpgclone {
    <#
    .SYNOPSIS
        Clone a VPG using a specific checkpoint or the latest checkpoint if one is not (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/vpgs/{vpgIdentifier}/CloneStart
        OperationId: startVpgClone
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgs/$Vpgidentifier/CloneStart" -Method 'Post'  -Body $Body
    }
}
