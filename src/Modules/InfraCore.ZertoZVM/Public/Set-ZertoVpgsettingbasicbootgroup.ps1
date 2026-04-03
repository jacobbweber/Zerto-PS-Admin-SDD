function Set-ZertoVpgsettingbasicbootgroup {
    <#
    .SYNOPSIS
        Edit VPG settings with Bootgroups settings (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for PUT /v1/vpgSettings/{vpgSettingsIdentifier}/bootgroup
        OperationId: editVpgSettingBasicBootGroup
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgsettingsidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgSettings/$Vpgsettingsidentifier/bootgroup" -Method 'Put'  -Body $Body
    }
}
