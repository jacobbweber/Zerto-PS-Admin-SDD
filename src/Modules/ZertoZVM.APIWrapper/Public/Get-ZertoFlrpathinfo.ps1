function Get-ZertoFlrpathinfo {
    <#
    .SYNOPSIS
        Browse a list of files and folders in a specific path in the mounted disk. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/flrs/{flrSessionIdentifier}/browse
        OperationId: getFlrPathInfo
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Flrsessionidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "flrs/$Flrsessionidentifier/browse" -Method 'Post'  -Body $Body
    }
}
