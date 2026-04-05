function Mount-ZertoFlr {
    <#
    .SYNOPSIS
        Create a new Mount Session. Mount a disk with specified parameters. Get the FLR session identifier. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/flrs
        OperationId: mountFlr
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint 'flrs' -Method 'Post'  -Body $Body
    }
}
