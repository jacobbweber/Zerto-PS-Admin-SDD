function Start-ZertoVrainstall {
    <#
    .SYNOPSIS
        Install VRA. Returns TaskIdentifier. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/vras
        OperationId: startVraInstall
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint 'vras' -Method 'Post'  -Body $Body
    }
}
