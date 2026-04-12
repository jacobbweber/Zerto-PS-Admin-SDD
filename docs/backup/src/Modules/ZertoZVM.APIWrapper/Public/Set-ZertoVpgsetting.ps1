function Set-ZertoVpgsetting {
    <#
    .SYNOPSIS
        Edit the VPG settings. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for PUT /v1/vpgSettings/{vpgSettingsIdentifier}
        OperationId: editVpgSetting
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgsettingsidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgSettings/$Vpgsettingsidentifier" -Method 'Put'  -Body $Body
    }
}
