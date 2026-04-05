function Get-ZertoVirtualizationsitenetwork {
    <#
    .SYNOPSIS
        Get the list of networks (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/virtualizationsites/{siteIdentifier}/networks
        OperationId: getVirtualizationSiteNetworkAll
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Siteidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "virtualizationsites/$Siteidentifier/networks" -Method 'Get'  
    }
}
