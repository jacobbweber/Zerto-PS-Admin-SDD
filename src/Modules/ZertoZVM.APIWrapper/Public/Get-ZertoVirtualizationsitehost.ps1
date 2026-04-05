function Get-ZertoVirtualizationsitehost {
    <#
    .SYNOPSIS
        Get information about hosts at the site (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/virtualizationsites/{siteIdentifier}/hosts
        OperationId: getVirtualizationSiteHostAll
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Siteidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "virtualizationsites/$Siteidentifier/hosts" -Method 'Get'  
    }
}
