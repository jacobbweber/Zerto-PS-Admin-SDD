function Get-ZertoVirtualizationsitehostcluster {
    <#
    .SYNOPSIS
        Get the list of host clusters at the site (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/virtualizationsites/{siteIdentifier}/hostclusters
        OperationId: getVirtualizationSiteHostClusterAll
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Siteidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "virtualizationsites/$Siteidentifier/hostclusters" -Method 'Get'  
    }
}
