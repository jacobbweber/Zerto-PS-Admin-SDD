function Start-ZertoVpgresume {
    <#
    .SYNOPSIS
        Resume the protection of the VPG. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/vpgs/{vpgIdentifier}/resume
        OperationId: startVpgResume
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgs/$Vpgidentifier/resume" -Method 'Post'  -Body $Body
    }
}
