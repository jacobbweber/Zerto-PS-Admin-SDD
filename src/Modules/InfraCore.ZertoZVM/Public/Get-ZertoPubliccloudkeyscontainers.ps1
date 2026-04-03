function Get-ZertoPubliccloudkeyscontainers {
    <#
    .SYNOPSIS
        Get the list of KeysContainers for the specified site. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/virtualizationsites/{siteIdentifier}/publiccloud/keyscontainers
        OperationId: getPublicCloudKeysContainers
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Siteidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "virtualizationsites/$Siteidentifier/publiccloud/keyscontainers" -Method 'Get'  
    }
}
