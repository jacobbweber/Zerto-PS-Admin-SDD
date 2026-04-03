function New-ZertoRepository {
    <#
    .SYNOPSIS
        Create new repository (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/ltr/repositories
        OperationId: newRepository
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint 'ltr/repositories' -Method 'Post'  -Body $Body
    }
}
