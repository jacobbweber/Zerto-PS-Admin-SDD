function Get-ZertoPubliccloudmanagedidentities {
    <#
    .SYNOPSIS
        Get the list of managed identities. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/virtualizationsites/{siteIdentifier}/publiccloud/managedidentities
        OperationId: getPublicCloudManagedIdentities
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Siteidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "virtualizationsites/$Siteidentifier/publiccloud/managedidentities" -Method 'Get'  
    }
}
