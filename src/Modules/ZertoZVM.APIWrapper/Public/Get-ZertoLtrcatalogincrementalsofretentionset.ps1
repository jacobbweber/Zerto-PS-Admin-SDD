function Get-ZertoLtrcatalogincrementalsofretentionset {
    <#
    .SYNOPSIS
        Get a list of incremental Retention sets (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/ltr/catalog/fullretentionsets/{retentionSetIdentifier}/incrementals
        OperationId: GetLtrCatalogIncrementalsOfRetentionSet
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Retentionsetidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "ltr/catalog/fullretentionsets/$Retentionsetidentifier/incrementals" -Method 'Get'  
    }
}
