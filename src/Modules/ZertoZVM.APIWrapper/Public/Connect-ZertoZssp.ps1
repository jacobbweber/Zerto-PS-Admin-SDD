function Connect-ZertoZssp {
    <#
    .SYNOPSIS
        Create a ZSSP session. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/zsspsessions
        OperationId: connectZssp
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint 'zsspsessions' -Method 'Post'  -Body $Body
    }
}
