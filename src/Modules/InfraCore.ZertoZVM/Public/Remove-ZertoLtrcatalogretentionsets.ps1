function Remove-ZertoLtrcatalogretentionsets {
    <#
    .SYNOPSIS
        Delete Retention sets (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/ltr/catalog/deleteretentionsets
        OperationId: DeleteLtrCatalogRetentionSets
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint 'ltr/catalog/deleteretentionsets' -Method 'Post'  -Body $Body
    }
}
