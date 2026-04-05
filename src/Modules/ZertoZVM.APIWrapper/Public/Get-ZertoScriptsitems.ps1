function Get-ZertoScriptsitems {
    <#
    .SYNOPSIS
        Get a list of items (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/recoveryScripts/repository/items
        OperationId: listScriptsItems
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

        Invoke-ZertoRequest -Endpoint 'recoveryScripts/repository/items' -Method 'Get' -QueryParameters $query 
    }
}
