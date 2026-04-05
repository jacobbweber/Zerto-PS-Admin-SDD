function Get-ZertoVirtualizationsitefolder {
    <#
    .SYNOPSIS
        Get the list of folders for the site (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/virtualizationsites/{siteIdentifier}/folders
        OperationId: getVirtualizationSiteFolderAll
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Siteidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "virtualizationsites/$Siteidentifier/folders" -Method 'Get'  
    }
}
