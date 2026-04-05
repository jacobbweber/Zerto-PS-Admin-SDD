function Remove-ZertoRepository {
    <#
    .SYNOPSIS
        Delete existing repository (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for DELETE /v1/ltr/repositories/{repositoryIdentifier}
        OperationId: removeRepository
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Repositoryidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "ltr/repositories/$Repositoryidentifier" -Method 'Delete'  
    }
}
