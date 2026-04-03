function Get-ZertoVirtualizationsitedatastore {
    <#
    .SYNOPSIS
        Get information about datastores at the site (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/virtualizationsites/{siteIdentifier}/datastores
        OperationId: getVirtualizationSiteDatastoreAll
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Siteidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "virtualizationsites/$Siteidentifier/datastores" -Method 'Get'  
    }
}
