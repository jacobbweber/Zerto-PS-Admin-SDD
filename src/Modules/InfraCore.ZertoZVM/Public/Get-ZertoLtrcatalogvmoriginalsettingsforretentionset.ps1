function Get-ZertoLtrcatalogvmoriginalsettingsforretentionset {
    <#
    .SYNOPSIS
        Get the original settings for a VM in a Retention set (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/ltr/catalog/vms/{vmIdentifier}/retentionsets/{retentionSetIdentifier}/settings
        OperationId: GetLtrCatalogVmOriginalSettingsForRetentionSet
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vmidentifier,

        [Parameter(Mandatory)]
        [string] $Retentionsetidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "ltr/catalog/vms/$Vmidentifier/retentionsets/$Retentionsetidentifier/settings" -Method 'Get'  
    }
}
