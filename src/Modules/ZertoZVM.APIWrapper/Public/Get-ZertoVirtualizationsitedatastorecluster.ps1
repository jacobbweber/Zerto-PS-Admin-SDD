function Get-ZertoVirtualizationsitedatastorecluster {
    <#
    .SYNOPSIS
        Get the list of datastore clusters for the site (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/virtualizationsites/{siteIdentifier}/datastoreclusters
        OperationId: getVirtualizationSiteDatastoreClusterAll
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Siteidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "virtualizationsites/$Siteidentifier/datastoreclusters" -Method 'Get'  
    }
}
