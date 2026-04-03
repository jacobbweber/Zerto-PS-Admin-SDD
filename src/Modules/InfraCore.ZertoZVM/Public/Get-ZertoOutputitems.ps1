function Get-ZertoOutputitems {
    <#
    .SYNOPSIS
        Get a list of items (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/recoveryScripts/output/items
        OperationId: listOutputItems
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string] $Path,

        [Parameter()]
        [string] $Search
    )

    process {
    $query = @{}
        if ($Path) { $query['path'] = $Path }
        if ($Search) { $query['search'] = $Search }

        Invoke-ZertoRequest -Endpoint 'recoveryScripts/output/items' -Method 'Get' -QueryParameters $query 
    }
}
