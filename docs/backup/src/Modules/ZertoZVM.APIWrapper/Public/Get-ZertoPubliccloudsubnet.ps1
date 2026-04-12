function Get-ZertoPubliccloudsubnet {
    <#
    .SYNOPSIS
        Get the list of subnets at the site (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/virtualizationsites/{siteIdentifier}/publiccloud/subnets
        OperationId: getPublicCloudSubnetAll
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

        Invoke-ZertoRequest -Endpoint "virtualizationsites/$Siteidentifier/publiccloud/subnets" -Method 'Get' -QueryParameters $query 
    }
}
