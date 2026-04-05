function Start-ZertoVpgdelete {
    <#
    .SYNOPSIS
        Delete the VPG (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for DELETE /v1/vpgs/{vpgIdentifier}
        OperationId: startVpgDelete
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgs/$Vpgidentifier" -Method 'Delete'  
    }
}
