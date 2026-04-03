function Get-ZertoLtrcatalogvmretentionsets {
    <#
    .SYNOPSIS
        Get a list of the available Retention sets for a VM in all Repositories in the site (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/ltr/catalog/vms/{vmIdentifier}/retentionsets
        OperationId: GetLtrCatalogVmRetentionSets
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vmidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "ltr/catalog/vms/$Vmidentifier/retentionsets" -Method 'Get'  
    }
}
