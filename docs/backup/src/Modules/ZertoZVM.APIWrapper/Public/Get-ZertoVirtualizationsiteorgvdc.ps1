function Get-ZertoVirtualizationsiteorgvdc {
    <#
    .SYNOPSIS
        Get the list of organization VDC at the site (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/virtualizationsites/{siteIdentifier}/orgvdcs
        OperationId: getVirtualizationSiteOrgVdcAll
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Siteidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "virtualizationsites/$Siteidentifier/orgvdcs" -Method 'Get'  
    }
}
