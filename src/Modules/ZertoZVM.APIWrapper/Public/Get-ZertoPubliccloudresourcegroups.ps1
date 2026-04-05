function Get-ZertoPubliccloudresourcegroups {
    <#
    .SYNOPSIS
        Get the list of resource groups at the site (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/virtualizationsites/{siteIdentifier}/publiccloud/resourceGroups
        OperationId: getPublicCloudResourceGroupsAll
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Siteidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "virtualizationsites/$Siteidentifier/publiccloud/resourceGroups" -Method 'Get'  
    }
}
