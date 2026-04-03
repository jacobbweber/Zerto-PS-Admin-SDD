function Get-ZertoRepository {
    <#
    .SYNOPSIS
        Get Repository By Id (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/ltr/repositories/{repositoryId}
        OperationId: getRepositoryById
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Repositoryid
    )

    process {

        Invoke-ZertoRequest -Endpoint "ltr/repositories/$Repositoryid" -Method 'Get'  
    }
}
