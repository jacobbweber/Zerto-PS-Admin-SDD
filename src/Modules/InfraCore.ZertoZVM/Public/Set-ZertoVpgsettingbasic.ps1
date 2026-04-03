function Set-ZertoVpgsettingbasic {
    <#
    .SYNOPSIS
        Edit VPG settings with basic settings (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for PUT /v1/vpgSettings/{vpgSettingsIdentifier}/basic
        OperationId: editVpgSettingBasic
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgsettingsidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgSettings/$Vpgsettingsidentifier/basic" -Method 'Put'  -Body $Body
    }
}
