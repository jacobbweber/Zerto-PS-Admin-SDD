function Get-ZertoPubliccloudnetwork {
    <#
    .SYNOPSIS
        Get the list of virtual networks at the site (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/virtualizationsites/{siteIdentifier}/publiccloud/virtualNetworks
        OperationId: getPublicCloudNetworkAll
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Siteidentifier,

        [Parameter()]
        [string] $Virtualnetworkidentifier
    )

    process {
    $query = @{}
        if ($Virtualnetworkidentifier) { $query['virtualNetworkIdentifier'] = $Virtualnetworkidentifier }

        Invoke-ZertoRequest -Endpoint "virtualizationsites/$Siteidentifier/publiccloud/virtualNetworks" -Method 'Get' -QueryParameters $query 
    }
}
