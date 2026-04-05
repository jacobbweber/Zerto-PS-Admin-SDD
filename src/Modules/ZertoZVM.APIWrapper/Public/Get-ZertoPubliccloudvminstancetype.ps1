function Get-ZertoPubliccloudvminstancetype {
    <#
    .SYNOPSIS
        Get the list of virtual machine instance types at the site (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/virtualizationsites/{siteIdentifier}/publiccloud/vmInstanceTypes
        OperationId: getPublicCloudVmInstanceTypeAll
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Siteidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "virtualizationsites/$Siteidentifier/publiccloud/vmInstanceTypes" -Method 'Get'  
    }
}
