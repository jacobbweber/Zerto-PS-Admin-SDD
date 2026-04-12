function Get-ZertoLtrcatalogfullretentionsets {
    <#
    .SYNOPSIS
        Get a list of full Retention sets (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/ltr/catalog/fullretentionsets
        OperationId: GetLtrCatalogFullRetentionSets
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string] $Repositoryidentifier,

        [Parameter()]
        [string] $Vpgidentifier,

        [Parameter()]
        [string] $Zorgidentifier
    )

    process {
    $query = @{}
        if ($Repositoryidentifier) { $query['repositoryIdentifier'] = $Repositoryidentifier }
        if ($Vpgidentifier) { $query['vpgIdentifier'] = $Vpgidentifier }
        if ($Zorgidentifier) { $query['zorgIdentifier'] = $Zorgidentifier }

        Invoke-ZertoRequest -Endpoint 'ltr/catalog/fullretentionsets' -Method 'Get' -QueryParameters $query 
    }
}
