function Import-ZertoVpg {
    <#
    .SYNOPSIS
        Import VPGs. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/vpgSettings/import
        OperationId: importVpg
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint 'vpgSettings/import' -Method 'Post'  -Body $Body
    }
}
