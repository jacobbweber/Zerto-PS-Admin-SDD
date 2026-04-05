function Disconnect-ZertoZssp {
    <#
    .SYNOPSIS
        Delete a ZSSP session. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for DELETE /v1/zsspsessions/{zsspSessionIdentifier}
        OperationId: disconnectZssp
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Zsspsessionidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "zsspsessions/$Zsspsessionidentifier" -Method 'Delete'  
    }
}
