function Get-ZertoPubliccloudencryptionkeys {
    <#
    .SYNOPSIS
        Get the list of CMKs for the specified site and keys container. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/virtualizationsites/{siteIdentifier}/publiccloud/encryptionkeys
        OperationId: getPublicCloudEncryptionKeysAll
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Siteidentifier,

        [Parameter(Mandatory)]
        [string] $Keyscontainerid
    )

    process {
    $query = @{}
        if ($Keyscontainerid) { $query['keysContainerId'] = $Keyscontainerid }

        Invoke-ZertoRequest -Endpoint "virtualizationsites/$Siteidentifier/publiccloud/encryptionkeys" -Method 'Get' -QueryParameters $query 
    }
}
