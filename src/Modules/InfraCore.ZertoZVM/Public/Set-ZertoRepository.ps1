function Set-ZertoRepository {
    <#
    .SYNOPSIS
        Edit existing repository (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for PUT /v1/ltr/repositories/{repositoryIdentifier}
        OperationId: editRepository
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Repositoryidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "ltr/repositories/$Repositoryidentifier" -Method 'Put'  -Body $Body
    }
}
