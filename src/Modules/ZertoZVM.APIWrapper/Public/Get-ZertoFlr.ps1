function Get-ZertoFlr {
    <#
    .SYNOPSIS
        Get all mounted volumes. Results can be filtered by a VM identifier. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/flrs
        OperationId: getFlrAll
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string] $Vmidentifier
    )

    process {
    $query = @{}
        if ($Vmidentifier) { $query['vmIdentifier'] = $Vmidentifier }

        Invoke-ZertoRequest -Endpoint 'flrs' -Method 'Get' -QueryParameters $query 
    }
}
