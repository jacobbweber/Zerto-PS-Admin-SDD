function Get-ZertoVirtualizationsiteorgvdcnetwork {
    <#
    .SYNOPSIS
        Get list of virtualization site networks for a specified org vDc (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/virtualizationsites/{siteIdentifier}/orgvdcs/{orgVdcIdentifier}/networks
        OperationId: getVirtualizationSiteOrgVdcNetworkAll
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Siteidentifier,

        [Parameter(Mandatory)]
        [string] $Orgvdcidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "virtualizationsites/$Siteidentifier/orgvdcs/$Orgvdcidentifier/networks" -Method 'Get'  
    }
}
