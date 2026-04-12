function Copy-ZertoVpgsetting {
    <#
    .SYNOPSIS
        Create a new VPG settings object from an existing VPG, returns the settings object identifier (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/vpgSettings/copyVpgSettings
        OperationId: copyVpgSetting
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint 'vpgSettings/copyVpgSettings' -Method 'Post'  -Body $Body
    }
}
