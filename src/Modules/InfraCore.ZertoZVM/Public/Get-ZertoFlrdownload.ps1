function Get-ZertoFlrdownload {
    <#
    .SYNOPSIS
        Get URL link to download all the files from the specified paths. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/flrs/{flrSessionIdentifier}/download
        OperationId: getFlrDownload
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Flrsessionidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "flrs/$Flrsessionidentifier/download" -Method 'Post'  -Body $Body
    }
}
