function Get-ZertoAllrepositories {
    <#
    .SYNOPSIS
        Get All Repositories (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/ltr/repositories
        OperationId: getAllRepositories
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string] $Connectiontype,

        [Parameter()]
        [string] $Repositoryname
    )

    process {
    $query = @{}
        if ($Connectiontype) { $query['connectionType'] = $Connectiontype }
        if ($Repositoryname) { $query['repositoryName'] = $Repositoryname }

        Invoke-ZertoRequest -Endpoint 'ltr/repositories' -Method 'Get' -QueryParameters $query 
    }
}
