function Get-ZertoVirtualizationsiterepository {
    <#
    .SYNOPSIS
        Get the list of Repositories at the site (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/virtualizationsites/{siteIdentifier}/repositories
        OperationId: getVirtualizationSiteRepositoryAll
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Siteidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "virtualizationsites/$Siteidentifier/repositories" -Method 'Get'  
    }
}
