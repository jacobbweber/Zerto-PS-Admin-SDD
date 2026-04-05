function Get-ZertoPublicclouddiskencryptionkeys {
    <#
    .SYNOPSIS
        Get the list of DiskEncryptionKeys. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/virtualizationsites/{siteIdentifier}/publiccloud/diskencryptionkeys
        OperationId: getPublicCloudDiskEncryptionKeys
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Siteidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "virtualizationsites/$Siteidentifier/publiccloud/diskencryptionkeys" -Method 'Get'  
    }
}
