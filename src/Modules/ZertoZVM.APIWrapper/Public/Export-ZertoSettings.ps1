function Export-ZertoSettings {
    <#
    .SYNOPSIS
        Export all current VPGs settings. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/vpgSettings/exportSettings
        OperationId: exportSettings
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint 'vpgSettings/exportSettings' -Method 'Post'  -Body $Body
    }
}
