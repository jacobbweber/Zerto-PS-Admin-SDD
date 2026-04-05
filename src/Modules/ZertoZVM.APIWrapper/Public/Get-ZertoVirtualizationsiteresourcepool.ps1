function Get-ZertoVirtualizationsiteresourcepool {
    <#
    .SYNOPSIS
        Get the list of resource pools for the site (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/virtualizationsites/{siteIdentifier}/resourcepools
        OperationId: getVirtualizationSiteResourcePoolAll
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Siteidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "virtualizationsites/$Siteidentifier/resourcepools" -Method 'Get'  
    }
}
