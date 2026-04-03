function Start-ZertoVpgpause {
    <#
    .SYNOPSIS
        Pause the protection of the VPG. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/vpgs/{vpgIdentifier}/pause
        OperationId: startVpgPause
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgs/$Vpgidentifier/pause" -Method 'Post'  -Body $Body
    }
}
