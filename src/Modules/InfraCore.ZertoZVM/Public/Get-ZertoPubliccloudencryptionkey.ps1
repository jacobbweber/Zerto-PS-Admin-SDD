function Get-ZertoPubliccloudencryptionkey {
    <#
    .SYNOPSIS
        Get an EncryptionKey object based on the given EncryptionKeyId (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/virtualizationsites/{siteIdentifier}/publiccloud/encryptionkeys/{encryptionKeyId}
        OperationId: getPublicCloudEncryptionKey
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Siteidentifier,

        [Parameter(Mandatory)]
        [string] $Encryptionkeyid
    )

    process {

        Invoke-ZertoRequest -Endpoint "virtualizationsites/$Siteidentifier/publiccloud/encryptionkeys/$Encryptionkeyid" -Method 'Get'  
    }
}
