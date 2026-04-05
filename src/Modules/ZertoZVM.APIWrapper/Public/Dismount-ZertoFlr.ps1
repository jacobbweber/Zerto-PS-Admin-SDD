function Dismount-ZertoFlr {
    <#
    .SYNOPSIS
        Unmount a previously mounted disk. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for DELETE /v1/flrs/{flrSessionIdentifier}
        OperationId: dismountFlr
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Flrsessionidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "flrs/$Flrsessionidentifier" -Method 'Delete'  
    }
}
